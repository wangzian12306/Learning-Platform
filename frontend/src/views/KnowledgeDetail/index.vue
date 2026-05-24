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
        <div v-if="definitionContent" class="content-text" v-html="mdToHtml(definitionContent)"></div>
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
        <div class="content-text" v-html="mdToHtml(point.corePoints)"></div>
      </el-card>

      <!-- ==================== 操作原理与步骤讲解 ==================== -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">{{ sectionIndex('operation') }}</span>
            <span class="section-title">操作原理与步骤讲解</span>
          </div>
        </template>
        <div v-if="operationContents.length > 0" class="content-list">
          <div v-for="(item, i) in operationContents" :key="i" class="content-item">
            <h4 v-if="item.title" class="content-item-title">
              {{ item.title }}
              <el-tag v-if="item._fromChild" size="small" type="info" effect="plain" style="margin-left:6px;font-size:11px">子知识点</el-tag>
            </h4>
            <div class="content-text" v-html="mdToHtml(item.content)"></div>
          </div>
        </div>
        <el-empty v-else description="操作原理内容待补充" :image-size="60" />
      </el-card>

      <!-- ==================== 代码实现 ==================== -->
      <el-card class="section-card code-section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">{{ sectionIndex('code') }}</span>
            <span class="section-title">代码实现</span>
          </div>
        </template>
        <div v-if="codeExamples.length > 0" class="code-examples">
          <div v-for="(example, i) in codeExamples" :key="i" class="code-block">
            <div class="code-block-header">
              <span class="code-title">
                {{ example.title }}
                <el-tag v-if="example._fromChild" size="small" type="info" effect="plain" style="margin-left:6px;font-size:11px">子知识点</el-tag>
              </span>
              <el-button size="small" type="primary" link @click="loadToEditor(example)">
                加载到编辑器
              </el-button>
            </div>
            <p v-if="example.description" class="code-desc">{{ example.description }}</p>
            <pre class="code-pre"><code class="code-text">{{ example.code }}</code></pre>
          </div>
        </div>
        <el-empty v-else description="代码示例待补充" :image-size="60" />

        <!-- 在线编辑器区域 -->
        <div class="editor-section">
          <el-divider content-position="left">在线编辑器</el-divider>
          <div class="editor-toolbar">
            <el-select v-model="editorLanguage" size="small" style="width:110px">
              <el-option label="C++" value="c++" />
              <el-option label="C" value="c" />
              <el-option label="Python" value="python" />
            </el-select>
            <div style="flex:1" />
            <el-button size="small" @click="handleRun" :loading="runLoading">运行</el-button>
            <el-button size="small" type="primary" @click="handleSubmit" :loading="submitLoading">提交判题</el-button>
          </div>
          <div class="editor-area">
            <CodeEditor v-model="editorCode" :language="monacoLang" />
          </div>
          <div v-if="stdinRequired" class="stdin-section">
            <div class="stdin-label">标准输入 (stdin)</div>
            <el-input
              v-model="editorStdin"
              type="textarea"
              :rows="2"
              placeholder="输入测试数据，如：3 5"
              size="small"
            />
          </div>
          <div v-if="runResult || submitResult" class="result-section">
            <el-tabs v-model="resultTab">
              <el-tab-pane label="运行结果" name="run" v-if="runResult">
                <template v-if="runResult.compileError">
                  <el-alert type="error" :closable="false" title="编译错误" style="margin-bottom:8px" />
                  <pre class="error-pre">{{ runResult.compileError }}</pre>
                </template>
                <template v-else>
                  <div class="result-row">
                    <span class="result-label">输出：</span>
                    <pre class="result-pre">{{ runResult.stdout || '(无输出)' }}</pre>
                  </div>
                  <div v-if="runResult.stderr" class="result-row">
                    <span class="result-label" style="color:#f56c6c">错误输出：</span>
                    <pre class="error-pre">{{ runResult.stderr }}</pre>
                  </div>
                </template>
              </el-tab-pane>
              <el-tab-pane label="判题结果" name="submit" v-if="submitResult">
                <div class="status-banner" :class="submitResult.status?.toLowerCase()">
                  <span class="status-icon">{{ submitResult.status === 'ACCEPTED' ? '✓' : '✗' }}</span>
                  {{ submitStatusText }}
                  <span class="pass-count" v-if="submitResult.passCount != null">
                    {{ submitResult.passCount }}/{{ submitResult.totalCount }} 个测试用例通过
                  </span>
                </div>
                <div v-if="submitResult.status === 'COMPILE_ERROR'">
                  <pre class="error-pre">{{ submitResult.errorMessage }}</pre>
                </div>
                <div v-else-if="submitResult.testResults" class="test-results">
                  <div
                    v-for="(tr, i) in submitResult.testResults"
                    :key="i"
                    class="test-result-item"
                    :class="{ passed: tr.passed, failed: !tr.passed }"
                  >
                    <el-tag :type="tr.passed ? 'success' : 'danger'" size="small">
                      用例 {{ i + 1 }}：{{ tr.passed ? '通过' : '失败' }}
                    </el-tag>
                    <div v-if="!tr.passed" class="tr-detail">
                      <span class="tr-label">输入：</span><code>{{ tr.input }}</code><br>
                      <span class="tr-label">期望：</span><code>{{ tr.expectedOutput }}</code><br>
                      <span class="tr-label">实际：</span><code>{{ tr.actualOutput }}</code>
                    </div>
                  </div>
                </div>
              </el-tab-pane>
            </el-tabs>
          </div>
        </div>
      </el-card>

      <!-- ==================== 复杂度分析 ==================== -->
      <el-card class="section-card" shadow="never">
        <template #header>
          <div class="section-header">
            <span class="section-number">{{ sectionIndex('complexity') }}</span>
            <span class="section-title">时间复杂度与空间复杂度分析</span>
          </div>
        </template>
        <div v-if="complexityContents.length > 0" class="content-list">
          <div v-for="(item, i) in complexityContents" :key="i" class="content-item">
            <h4 v-if="item.title" class="content-item-title">
              {{ item.title }}
              <el-tag v-if="item._fromChild" size="small" type="info" effect="plain" style="margin-left:6px;font-size:11px">子知识点</el-tag>
            </h4>
            <div class="content-text" v-html="mdToHtml(item.content)"></div>
          </div>
        </div>
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
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue'
import { useRoute } from 'vue-router'
import { marked } from 'marked'
import {
  getKnowledgeDetail,
  getKnowledgeContents,
  getCodeExamples,
  getKnowledgeTree,
} from '@/api/modules/knowledge.js'
import { runCode, submitCode } from '@/api/modules/code.js'
import { useKnowledgeStore } from '@/stores/knowledge.js'
import { useLearningStatsStore } from '@/stores/learningStats.js'
import CodeEditor from '@/components/CodeEditor/CodeEditor.vue'

function mdToHtml(text) {
  if (!text) return ''
  return marked.parse(text)
}

const route = useRoute()
const knowledgeStore = useKnowledgeStore()
const statsStore = useLearningStatsStore()

let studyTimer = null
let studySeconds = 0

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
  '集合': '集合', '线性表': '线性表', '树': '树', '图': '图', '查找': '查找', '排序': '排序',
}
const moduleLabel = computed(() => moduleNameMap[route.params.module] || route.params.module || '')

const DEFAULT_TEMPLATES = {
  'c++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    \n    return 0;\n}',
  'c': '#include <stdio.h>\n\nint main() {\n    \n    return 0;\n}',
  'python': '# Python code\n'
}

const editorLanguage = ref('c++')
const editorCode = ref(DEFAULT_TEMPLATES['c++'])
const editorStdin = ref('')
const runLoading = ref(false)
const submitLoading = ref(false)
const runResult = ref(null)
const submitResult = ref(null)
const resultTab = ref('run')
const stdinRequired = ref(true)

const monacoLang = computed(() =>
  ({ 'c++': 'cpp', 'c': 'c', 'python': 'python' }[editorLanguage.value] || 'cpp')
)

const submitStatusText = computed(() => {
  if (!submitResult.value) return ''
  return { ACCEPTED: '通过', WRONG_ANSWER: '答案错误', COMPILE_ERROR: '编译错误', RUNTIME_ERROR: '运行错误' }[submitResult.value.status] || submitResult.value.status
})

watch(editorLanguage, (lang) => {
  editorCode.value = DEFAULT_TEMPLATES[lang] || ''
  runResult.value = null
  submitResult.value = null
})

function loadToEditor(example) {
  editorCode.value = example.code || ''
  if (example.language === 'Python') {
    editorLanguage.value = 'python'
  } else if (example.language === 'C') {
    editorLanguage.value = 'c'
  } else {
    editorLanguage.value = 'c++'
  }
  runResult.value = null
  submitResult.value = null
  const el = document.querySelector('.editor-section')
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

async function handleRun() {
  runLoading.value = true
  runResult.value = null
  resultTab.value = 'run'
  try {
    const res = await runCode({
      language: editorLanguage.value,
      code: editorCode.value,
      stdin: editorStdin.value
    })
    runResult.value = res
  } catch (e) {
    runResult.value = { compileError: '请求失败：' + (e.message || '未知错误') }
  } finally {
    runLoading.value = false
  }
}

async function handleSubmit() {
  submitLoading.value = true
  submitResult.value = null
  resultTab.value = 'submit'
  try {
    const res = await submitCode({
      language: editorLanguage.value,
      code: editorCode.value,
      testCases: []
    })
    submitResult.value = res
  } catch (e) {
    submitResult.value = { status: 'RUNTIME_ERROR', errorMessage: '请求失败：' + (e.message || '未知错误'), passCount: 0, totalCount: 0, testResults: [] }
  } finally {
    submitLoading.value = false
  }
}

// ================================================================
//  从 API 返回的 contents/codes 中取各段内容
// ================================================================
const contents = ref([])
const codes = ref([])

function findContent(type) {
  const item = contents.value.find(c => c.contentType === type)
  return item?.content || ''
}

function findContents(type) {
  return contents.value.filter(c => c.contentType === type).sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
}

const definitionContent = computed(() => {
  if (point.value?.description) return point.value.description
  return findContent('DEFINITION')
})

const operationContents = computed(() => findContents('OPERATION'))
const complexityContents = computed(() => findContents('COMPLEXITY'))
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
//  聚合子知识点内容（模块级节点无自身内容时使用）
// ================================================================
async function aggregateChildContent(parentId) {
  try {
    const tree = await getKnowledgeTree()
    let childIds = []
    function findChildren(nodes) {
      for (const n of nodes) {
        if (n.id === parentId && n.children) {
          childIds = n.children.map(c => c.id)
          return
        }
        if (n.children) findChildren(n.children)
      }
    }
    findChildren(tree)
    if (childIds.length === 0) return

    const allContents = []
    const allCodes = []
    const results = await Promise.allSettled(
      childIds.map(cid => Promise.all([
        getKnowledgeContents(cid),
        getCodeExamples(cid),
      ]))
    )
    for (const r of results) {
      if (r.status === 'fulfilled') {
        const [childContents, childCodes] = r.value
        if (childContents) {
          for (const c of childContents) {
            allContents.push({ ...c, _fromChild: true })
          }
        }
        if (childCodes) {
          for (const c of childCodes) {
            allCodes.push({ ...c, _fromChild: true })
          }
        }
      }
    }
    if (allContents.length > 0) contents.value = allContents
    if (allCodes.length > 0) codes.value = allCodes
  } catch (e) {
    console.warn('聚合子知识点内容失败:', e)
  }
}

// ================================================================
//  数据获取
// ================================================================
async function fetchDetail() {
  const id = Number(route.params.id)
  if (!id) return

  if (studyTimer) {
    clearInterval(studyTimer)
    if (studySeconds > 0) {
      statsStore.addStudyTime(String(route.params.id), studySeconds)
    }
    studySeconds = 0
  }

  loading.value = true
  point.value = null
  error.value = ''
  notFound.value = false
  contents.value = []
  codes.value = []

  const [detailRes, contentsRes, codesRes] = await Promise.allSettled([
    getKnowledgeDetail(id),
    getKnowledgeContents(id),
    getCodeExamples(id),
  ])

  const detail = detailRes.status === 'fulfilled' ? detailRes.value : null

  if (!detail) {
    error.value = detailRes.status === 'rejected'
      ? (detailRes.reason?.message || '接口请求失败')
      : ''
    if (!error.value) notFound.value = true
    loading.value = false
    return
  }

  point.value = detail
  contents.value = contentsRes.status === 'fulfilled' ? (contentsRes.value || []) : []
  codes.value = codesRes.status === 'fulfilled' ? (codesRes.value || []) : []

  if (contents.value.length === 0 && codes.value.length === 0) {
    await aggregateChildContent(id)
  }

  knowledgeStore.setCurrentNode({
    id: detail.id,
    name: detail.name,
    module: route.params.module,
    difficulty: detail.difficulty,
  })
  knowledgeStore.setCurrentModule(route.params.module)

  statsStore.recordKnowledgeVisit(id, moduleNameMap[route.params.module] || route.params.module || '')
  studySeconds = 0
  studyTimer = setInterval(() => {
    studySeconds += 10
    if (studySeconds > 0 && studySeconds % 30 === 0) {
      statsStore.addStudyTime(id, 30)
      studySeconds = 0
    }
  }, 10000)

  loading.value = false
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

onBeforeUnmount(() => {
  if (studyTimer) {
    clearInterval(studyTimer)
    if (studySeconds > 0) {
      statsStore.addStudyTime(String(route.params.id), studySeconds)
    }
    studyTimer = null
    studySeconds = 0
  }
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

:deep(.content-text table) {
  border-collapse: collapse;
  margin: 12px 0;
  width: 100%;
}

:deep(.content-text th),
:deep(.content-text td) {
  border: 1px solid #dcdfe6;
  padding: 8px 14px;
  text-align: left;
  font-size: 14px;
}

:deep(.content-text th) {
  background: #f5f7fa;
  font-weight: 600;
  color: #303133;
}

:deep(.content-text td) {
  color: #606266;
}

:deep(.content-text ul),
:deep(.content-text ol) {
  margin: 8px 0;
  padding-left: 24px;
}

:deep(.content-text li) {
  margin-bottom: 4px;
  line-height: 1.8;
}

:deep(.content-text code) {
  background: #f0f2f5;
  padding: 1px 6px;
  border-radius: 4px;
  font-family: 'Cascadia Code', 'Fira Code', 'Consolas', monospace;
  font-size: 13px;
  color: #d63384;
}

:deep(.content-text strong) {
  font-weight: 600;
  color: #303133;
}

:deep(.content-text p) {
  margin: 8px 0;
}

.content-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.content-item {
  padding-bottom: 16px;
  border-bottom: 1px dashed #e8e8e8;
}

.content-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.content-item-title {
  margin: 0 0 8px;
  font-size: 15px;
  font-weight: 600;
  color: #409eff;
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

.code-block-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  background: #f5f7fa;
  border-bottom: 1px solid #e8e8e8;
}

.code-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
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

.editor-section {
  margin-top: 16px;
}

.editor-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.editor-area {
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  overflow: hidden;
  min-height: 260px;
}

.stdin-section {
  margin-top: 8px;
}

.stdin-label {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
  font-weight: 500;
}

.result-section {
  margin-top: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  padding: 0 12px;
  max-height: 300px;
  overflow-y: auto;
}

.result-row {
  margin-bottom: 8px;
}

.result-label {
  font-size: 12px;
  color: #909399;
  font-weight: 500;
}

.result-pre {
  background: #f5f7fa;
  border: 1px solid #e4e7ed;
  border-radius: 4px;
  padding: 8px 12px;
  font-size: 13px;
  margin: 4px 0 0;
  white-space: pre-wrap;
  color: #1f2329;
}

.error-pre {
  background: #fff2f0;
  border: 1px solid #ffccc7;
  border-radius: 4px;
  padding: 8px 12px;
  font-size: 12px;
  color: #cf1322;
  margin: 4px 0;
  white-space: pre-wrap;
}

.status-banner {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border-radius: 8px;
  margin: 8px 0;
  font-weight: 600;
  font-size: 15px;
}
.status-banner.accepted { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
.status-banner.wrong_answer { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
.status-banner.compile_error { background: #fff7e6; color: #d46b08; border: 1px solid #ffd591; }
.status-banner.runtime_error { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }

.status-icon { font-size: 18px; }
.pass-count { font-size: 13px; font-weight: 400; color: #909399; margin-left: auto; }

.test-results { margin-top: 8px; }
.test-result-item {
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  padding: 8px 12px;
  margin-bottom: 6px;
  background: #fafafa;
}
.test-result-item.passed { border-color: #b7eb8f; background: #f6ffed; }
.test-result-item.failed { border-color: #ffccc7; background: #fff2f0; }

.tr-detail {
  margin-top: 6px;
  font-size: 13px;
  line-height: 1.8;
  color: #4e5969;
}
.tr-label { color: #909399; font-weight: 500; }

:deep(.el-card__header) {
  padding: 14px 20px;
}

:deep(.el-card__body) {
  padding: 20px;
}
</style>
