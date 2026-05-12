<template>
  <div class="learning-path-layout">
    <!-- ========== 左侧：目录树 ========== -->
    <aside class="tree-panel" :class="{ collapsed: treeCollapsed }">
      <div v-show="!treeCollapsed">
        <div class="panel-header">
          <h3 class="panel-title">目录</h3>
          <div class="panel-actions">
            <el-popover placement="bottom" :width="220" trigger="hover">
              <template #reference>
                <el-button :icon="InfoFilled" circle size="small" />
              </template>
              <div class="legend-popup">
                <div class="legend-item"><span class="dot dot-not-started"></span> 未学习</div>
                <div class="legend-item"><span class="dot dot-in-progress"></span> 学习中</div>
                <div class="legend-item"><span class="dot dot-completed"></span> 已完成</div>
                <div class="legend-item"><span class="prereq-badge">⚠</span> 有前置依赖</div>
              </div>
            </el-popover>
            <el-button :icon="DArrowLeft" text size="small" title="收起目录" @click="treeCollapsed = true" />
          </div>
        </div>

        <el-input
          v-model="searchKeyword"
          placeholder="搜索知识点..."
          :prefix-icon="Search"
          clearable
          size="small"
          class="search-input"
          @input="handleSearch"
        />

        <div class="tree-wrapper">
          <el-empty v-if="searchKeyword && filteredCount === 0" description="未找到匹配的知识点" :image-size="64" />
          <el-tree
            v-show="!(searchKeyword && filteredCount === 0)"
            ref="treeRef"
            :data="treeData"
            :props="treeProps"
            node-key="id"
            highlight-current
            :expand-on-click-node="true"
            :filter-node-method="filterNode"
            :default-expanded-keys="defaultExpandedKeys"
            accordion
            @node-click="handleNodeClick"
          >
            <template #default="{ data }">
              <div class="tree-node-content">
                <span
                  class="status-dot"
                  :class="'status-' + getStatus(data)"
                  :title="statusLabel[getStatus(data)]"
                ></span>
                <span class="node-label">{{ data.name }}</span>
                <el-tag
                  :type="difficultyTagType(data.difficulty)"
                  size="small"
                  class="difficulty-tag"
                >
                  {{ difficultyLabel[data.difficulty] || data.difficulty }}
                </el-tag>
                <el-tooltip
                  v-if="hasPrerequisites(data)"
                  placement="right"
                  :show-after="300"
                >
                  <template #content>
                    <div class="prereq-tooltip">
                      <strong>推荐学习顺序：</strong>
                      <ul>
                        <li v-for="pre in getPrerequisiteNames(data)" :key="pre">
                          需先学习「{{ pre }}」
                        </li>
                      </ul>
                    </div>
                  </template>
                  <span class="prereq-icon" title="有前置依赖">⚠</span>
                </el-tooltip>
              </div>
            </template>
          </el-tree>
        </div>
      </div>

      <div v-show="treeCollapsed" class="collapsed-strip">
        <el-tooltip content="展开目录" placement="right">
          <el-button :icon="DArrowRight" text @click="treeCollapsed = false" />
        </el-tooltip>
      </div>
    </aside>

    <!-- ========== 右侧：知识点详情 ========== -->
    <main class="detail-panel">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Search, InfoFilled, DArrowLeft, DArrowRight } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { useKnowledgeStore } from '@/stores/knowledge'
import { useLearningStore } from '@/stores/learning'

const router = useRouter()
const knowledgeStore = useKnowledgeStore()
const learningStore = useLearningStore()

const treeRef = ref(null)
const searchKeyword = ref('')
const treeCollapsed = ref(false)

// ================================================================
//  数据加载：从后端 /api/knowledge/tree 获取目录树
//  数据结构契约见同目录下的 data-requirements.json
// ================================================================
const treeData = ref([])
const loading = ref(false)

async function loadTree() {
  loading.value = true
  try {
    const { getKnowledgeTree } = await import('@/api/modules/knowledge')
    treeData.value = await getKnowledgeTree()
  } catch {
    ElMessage.warning('目录数据加载失败，请确认后端已启动')
    treeData.value = []
  } finally {
    loading.value = false
  }
}

onMounted(loadTree)

const treeProps = { children: 'children', label: 'name' }
const defaultExpandedKeys = []

const neo4jIdIndex = computed(() => {
  const map = new Map()
  function walk(nodes) {
    for (const n of nodes) {
      map.set(n.neo4jId, n)
      if (n.children) walk(n.children)
    }
  }
  walk(treeData.value)
  return map
})

// ================================================================
//  学习状态
// ================================================================
const statusLabel = { not_started: '未学习', in_progress: '学习中', completed: '已完成' }

function getStatus(data) {
  return learningStore.getProgress(data.id)
}

// ================================================================
//  难度标签
// ================================================================
const difficultyLabel = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }

function difficultyTagType(d) {
  return d === 'EASY' ? 'success' : d === 'MEDIUM' ? 'warning' : 'danger'
}

// ================================================================
//  前置依赖（路径引导）
// ================================================================
function hasPrerequisites(data) {
  return data.prerequisites && data.prerequisites.length > 0
}

function getPrerequisiteNames(data) {
  return (data.prerequisites || []).map((neo4jId) => {
    const node = neo4jIdIndex.value.get(neo4jId)
    return node ? node.name : neo4jId
  })
}

// ================================================================
//  节点点击 → 右侧展示详情
// ================================================================
function handleNodeClick(data) {
  const moduleKey = data.module.toLowerCase()
  knowledgeStore.setCurrentNode({
    id: data.id,
    name: data.name,
    module: moduleKey,
    difficulty: data.difficulty,
  })
  knowledgeStore.setCurrentModule(moduleKey)

  router.push({
    name: 'KnowledgeDetail',
    params: { module: moduleKey, id: data.id },
  })
}

// ================================================================
//  搜索过滤
// ================================================================
function handleSearch() {
  treeRef.value?.filter(searchKeyword.value)
}

function filterNode(value, data) {
  if (!value) return true
  return (
    data.name.includes(value) ||
    (data.code && data.code.toLowerCase().includes(value.toLowerCase()))
  )
}

const filteredCount = computed(() => {
  if (!searchKeyword.value) return treeData.value.length
  let count = 0
  function walk(nodes) {
    for (const n of nodes) {
      if (filterNode(searchKeyword.value, n)) count++
      if (n.children) walk(n.children)
    }
  }
  walk(treeData.value)
  return count
})


</script>

<style scoped>
.learning-path-layout {
  display: flex;
  height: calc(100vh - 56px);
  margin: -24px;
  overflow: hidden;
}

/* ========== 左侧树面板 ========== */
.tree-panel {
  width: 320px;
  background: #fff;
  border-right: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  overflow: hidden;
  transition: width 0.25s ease;
}

.tree-panel.collapsed {
  width: 44px;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 16px 0;
}

.panel-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.panel-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.search-input {
  padding: 12px 16px 0;
}

.tree-wrapper {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 8px 8px 8px 4px;
}

.collapsed-strip {
  flex: 1;
  display: flex;
  justify-content: center;
  padding-top: 12px;
}

/* ========== 右侧详情面板 ========== */
.detail-panel {
  flex: 1;
  min-width: 0;
  overflow-y: auto;
  background: #f5f7fa;
}

/* ========== 树节点 ========== */
.tree-node-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
  padding-right: 4px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.status-not_started { background: #c0c4cc; }

.status-in_progress {
  background: #409eff;
  box-shadow: 0 0 0 3px rgba(64, 158, 255, 0.2);
}

.status-completed { background: #67c23a; }

.node-label {
  font-size: 13px;
  color: #303133;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.difficulty-tag {
  flex-shrink: 0;
  margin-left: auto;
  transform: scale(0.85);
}

.prereq-icon {
  color: #e6a23c;
  font-size: 13px;
  flex-shrink: 0;
  cursor: help;
}

/* ========== 图例 ========== */
.legend-popup {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}

.dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.dot-not-started { background: #c0c4cc; }
.dot-in-progress { background: #409eff; }
.dot-completed { background: #67c23a; }

.prereq-badge { color: #e6a23c; }

/* ========== tooltip ========== */
.prereq-tooltip ul {
  margin: 4px 0 0;
  padding-left: 16px;
}

.prereq-tooltip li {
  font-size: 13px;
  line-height: 1.8;
}

/* ========== el-tree 微调 ========== */
:deep(.el-tree-node__content) {
  height: 34px;
  padding-right: 4px;
}

:deep(.el-tree-node.is-current > .el-tree-node__content) {
  background-color: #ecf5ff;
}

:deep(.el-tree-node__label) {
  flex: 1;
  min-width: 0;
}

:deep(.el-tree) {
  font-size: 13px;
}
</style>
