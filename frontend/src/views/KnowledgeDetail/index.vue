<template>
  <!-- 欢迎状态：未选中知识点 -->
  <div v-if="!route.params.id" class="knowledge-welcome">
    <el-result
      icon="info"
      title="请选择一个知识点"
      sub-title="从左侧目录树中点击知识点，即可查看详细内容"
    />
  </div>

  <div v-else class="knowledge-detail" v-loading="loading">
    <template v-if="!loading && point">
      <!-- ==================== 头部：名称 + 元信息 ==================== -->
      <div class="detail-header">
        <div class="header-top">
          <h2 class="point-name">{{ point.name }}</h2>
          <div class="header-tags">
            <el-tag :type="difficultyTagType(point.difficulty)" size="small" effect="dark">
              {{ difficultyLabel[point.difficulty] || point.difficulty }}
            </el-tag>
            <el-tag type="info" size="small" effect="plain">{{ moduleLabel }}</el-tag>
            <el-tag v-if="point.level" type="info" size="small" effect="plain">
              L{{ point.level }} 级
            </el-tag>
          </div>
        </div>
      </div>

      <!-- ==================== 1. 基本定义与核心性质 ==================== -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">1</span>
            <span class="section-title">基本定义与核心性质</span>
          </div>
        </template>
        <div v-if="definitionContent" class="content-text">{{ definitionContent }}</div>
        <el-empty v-else description="暂无定义内容" :image-size="60" />
      </el-card>

      <!-- ==================== 2. 核心考点 ==================== -->
      <el-card v-if="point.corePoints" class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">2</span>
            <span class="section-title">核心考点</span>
          </div>
        </template>
        <div class="content-text">{{ point.corePoints }}</div>
      </el-card>

      <!-- ==================== 操作原理与步骤讲解 ==================== -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">{{ sectionIndex('operation') }}</span>
            <span class="section-title">操作原理与步骤讲解</span>
          </div>
        </template>
        <div v-if="operationContent" class="content-text">{{ operationContent }}</div>
        <el-empty v-else description="操作原理内容待补充" :image-size="60" />
      </el-card>

      <!-- ==================== 代码实现 ==================== -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">{{ sectionIndex('code') }}</span>
            <span class="section-title">代码实现（C++）</span>
          </div>
        </template>
        <div v-if="codeExamples.length > 0" class="code-examples">
          <div v-for="(example, i) in codeExamples" :key="i" class="code-block">
            <div class="code-title">{{ example.title }}</div>
            <p v-if="example.description" class="code-desc">{{ example.description }}</p>
            <pre class="code-pre"><code class="code-text">{{ example.code }}</code></pre>
          </div>
        </div>
        <el-empty v-else description="代码示例待补充" :image-size="60" />
      </el-card>

      <!-- ==================== 复杂度分析 ==================== -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">{{ sectionIndex('complexity') }}</span>
            <span class="section-title">时间复杂度与空间复杂度分析</span>
          </div>
        </template>
        <div v-if="complexityContent" class="content-text">{{ complexityContent }}</div>
        <el-empty v-else description="复杂度分析待补充" :image-size="60" />
      </el-card>
    </template>

    <!-- 数据不存在 -->
    <el-result
      v-else-if="!loading && notFound"
      icon="info"
      title="知识点未添加"
      :sub-title="`数据库中暂无「${moduleLabel || ''}」模块下 ID 为 ${route.params.id} 的知识点数据。`"
    />
    <!-- 加载失败 -->
    <el-result
      v-else-if="!loading && error"
      icon="error"
      title="加载失败"
      :sub-title="error"
    >
      <template #extra>
        <el-button type="primary" @click="fetchDetail">重新加载</el-button>
      </template>
    </el-result>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import {
  getKnowledgeDetail,
  getKnowledgeContents,
  getCodeExamples,
} from '@/api/modules/knowledge.js'
import { useKnowledgeStore } from '@/stores/knowledge.js'

const route = useRoute()
const knowledgeStore = useKnowledgeStore()

const point = ref(null)
const loading = ref(false)
const error = ref('')
const notFound = ref(false)

const difficultyLabel = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }
function difficultyTagType(d) {
  return d === 'EASY' ? 'success' : d === 'MEDIUM' ? 'warning' : 'danger'
}

const moduleNameMap = {
  set: '集合', 'linear-list': '线性表', ll: '线性表',
  tree: '树', graph: '图', search: '查找', sort: '排序',
}
const moduleLabel = computed(() => moduleNameMap[route.params.module] || route.params.module || '')

// ================================================================
//  从 API 返回的 contents/codes 中取各段内容
// ================================================================
const contents = ref([])
const codes = ref([])

function findContent(type) {
  const item = contents.value.find(c => c.contentType === type)
  return item?.content || ''
}

const definitionContent = computed(() => {
  if (point.value?.description) return point.value.description
  return findContent('DEFINITION')
})

const operationContent = computed(() => findContent('OPERATION'))
const complexityContent = computed(() => findContent('COMPLEXITY'))
const codeExamples = computed(() => codes.value)

// ================================================================
//  节号计算：定义=1, 考点(可选), 操作=base, 代码=base+1, 复杂度=base+2
// ================================================================
const hasCorePoints = computed(() => !!point.value?.corePoints)
const sectionBase = computed(() => hasCorePoints.value ? 3 : 2)

function sectionIndex(section) {
  const offsets = { operation: 0, code: 1, complexity: 2 }
  return sectionBase.value + offsets[section]
}

// ================================================================
//  数据获取
// ================================================================
async function fetchDetail() {
  const id = Number(route.params.id)
  if (!id) return

  loading.value = true
  error.value = ''
  notFound.value = false
  contents.value = []
  codes.value = []

  try {
    const [detail, contentList, codeList] = await Promise.all([
      getKnowledgeDetail(id),
      getKnowledgeContents(id),
      getCodeExamples(id),
    ])

    if (!detail) {
      notFound.value = true
      return
    }

    point.value = detail
    contents.value = contentList || []
    codes.value = codeList || []

    knowledgeStore.setCurrentNode({
      id: detail.id,
      name: detail.name,
      module: route.params.module,
      difficulty: detail.difficulty,
    })
    knowledgeStore.setCurrentModule(route.params.module)
  } catch (e) {
    error.value = e.message || '加载失败'
  } finally {
    loading.value = false
  }
}

watch(
  () => route.params.id,
  (newId, oldId) => {
    if (newId !== oldId) fetchDetail()
  },
)

onMounted(() => {
  fetchDetail()
})
</script>

<style scoped>
.knowledge-welcome {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.knowledge-detail {
  padding: 24px 32px;
  max-width: 900px;
  margin: 0 auto;
}

.detail-header {
  margin-bottom: 20px;
}

.header-top {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
}

.point-name {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  color: #303133;
  line-height: 1.4;
}

.header-tags {
  display: flex;
  gap: 6px;
}

.section-card {
  margin-bottom: 16px;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.section-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 26px;
  border-radius: 50%;
  background: #409eff;
  color: #fff;
  font-size: 13px;
  font-weight: 600;
  flex-shrink: 0;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.content-text {
  font-size: 15px;
  line-height: 1.85;
  color: #303133;
  white-space: pre-wrap;
}

.code-examples {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.code-block {
  border: 1px solid #e8e8e8;
  border-radius: 6px;
  overflow: hidden;
}

.code-title {
  padding: 10px 16px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  background: #f5f7fa;
  border-bottom: 1px solid #e8e8e8;
}

.code-desc {
  margin: 0;
  padding: 8px 16px 0;
  font-size: 13px;
  color: #909399;
}

.code-pre {
  margin: 0;
  padding: 16px;
  background: #1e1e1e;
  color: #d4d4d4;
  font-size: 13px;
  line-height: 1.7;
  overflow-x: auto;
}

.code-text {
  font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
  font-size: 13px;
  line-height: 1.7;
  color: #d4d4d4;
  background: transparent;
  padding: 0;
  border: none;
}

:deep(.el-card__header) {
  padding: 14px 20px;
}

:deep(.el-card__body) {
  padding: 20px;
}
</style>
