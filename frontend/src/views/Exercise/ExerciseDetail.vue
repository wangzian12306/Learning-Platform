<template>
  <div class="exercise-detail">

    <!-- 左侧：题目描述 -->
    <div class="problem-panel">
      <el-tabs v-model="leftTab">
        <el-tab-pane label="题目描述" name="desc">
          <div class="problem-content">
            <h2>{{ exercise.title }}</h2>
            <el-tag :type="difficultyType" style="margin-bottom:12px">
              {{ exercise.difficulty }}
            </el-tag>
            <p style="white-space:pre-wrap">{{ exercise.description }}</p>

            <template v-if="exercise.testCases.length">
              <div v-for="(tc, i) in exercise.testCases.slice(0, 2)" :key="i" class="example-block">
                <p><strong>示例 {{ i + 1 }}：</strong></p>
                <pre class="example-pre">输入：{{ tc.input }}
输出：{{ tc.expectedOutput }}</pre>
              </div>
            </template>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 右侧：编辑器 + 结果 -->
    <div class="editor-panel">

      <!-- 工具栏 -->
      <div class="editor-toolbar">
        <el-select v-model="selectedLanguage" size="small" style="width:110px">
          <el-option label="C++" value="c++" />
          <el-option label="C" value="c" />
          <el-option label="Python" value="python" />
        </el-select>
        <div style="flex:1" />
        <el-button size="small" @click="onRun" :loading="running">运行</el-button>
        <el-button size="small" type="primary" @click="onSubmit" :loading="submitting">提交</el-button>
      </div>

      <!-- Monaco 编辑器 -->
      <div class="editor-area">
        <CodeEditor v-model="code" :language="monacoLanguage" />
      </div>

      <!-- 底部结果区 -->
      <div class="result-area">
        <el-tabs v-model="resultTab">
          <el-tab-pane label="测试用例" name="cases">
            <div v-if="exercise.testCases.length" class="cases-list">
              <el-button
                v-for="(_, i) in exercise.testCases.slice(0, 3)"
                :key="i"
                size="small"
                :type="activeCaseIndex === i ? 'primary' : 'default'"
                style="margin-right:6px"
                @click="activeCaseIndex = i"
              >用例 {{ i + 1 }}</el-button>
              <div v-if="exercise.testCases[activeCaseIndex]" class="case-detail">
                <p class="case-label">输入</p>
                <pre class="case-pre">{{ exercise.testCases[activeCaseIndex].input }}</pre>
                <p class="case-label">预期输出</p>
                <pre class="case-pre">{{ exercise.testCases[activeCaseIndex].expectedOutput }}</pre>
              </div>
            </div>
            <el-empty v-else description="暂无测试用例" />
          </el-tab-pane>

          <el-tab-pane label="测试结果" name="result">
            <div v-if="!runResult && !submitResult" class="empty-hint">请先运行或提交代码</div>

            <!-- 自由运行结果 -->
            <div v-if="runResult && activeResultType === 'run'" class="run-result">
              <template v-if="runResult.compileError">
                <el-alert type="error" :closable="false" title="编译错误" style="margin-bottom:8px" />
                <pre class="error-pre">{{ runResult.compileError }}</pre>
              </template>
              <template v-else>
                <p class="case-label">输出</p>
                <pre class="case-pre">{{ runResult.stdout || '(无输出)' }}</pre>
                <template v-if="runResult.stderr">
                  <p class="case-label" style="color:#f56c6c">错误输出</p>
                  <pre class="error-pre">{{ runResult.stderr }}</pre>
                </template>
              </template>
            </div>

            <!-- 提交判题结果 -->
            <div v-if="submitResult && activeResultType === 'submit'" class="submit-result">
              <div class="status-banner" :class="submitResult.status.toLowerCase()">
                <span class="status-icon">{{ submitResult.status === 'ACCEPTED' ? '✓' : '✗' }}</span>
                {{ statusText }}
                <span class="pass-count">
                  {{ submitResult.passCount }}/{{ submitResult.totalCount }} 个测试用例通过
                </span>
              </div>
              <div v-if="submitResult.status === 'COMPILE_ERROR'">
                <pre class="error-pre">{{ submitResult.errorMessage }}</pre>
              </div>
              <div v-else class="test-results">
                <div
                  v-for="(tr, i) in submitResult.testResults"
                  :key="i"
                  class="test-result-item"
                  :class="{ passed: tr.passed, failed: !tr.passed }"
                >
                  <div class="tr-header">
                    <el-tag :type="tr.passed ? 'success' : 'danger'" size="small">
                      用例 {{ i + 1 }}：{{ tr.passed ? '通过' : '失败' }}
                    </el-tag>
                  </div>
                  <div v-if="!tr.passed" class="tr-detail">
                    <span class="tr-label">输入：</span><code>{{ tr.input }}</code><br>
                    <span class="tr-label">期望：</span><code>{{ tr.expectedOutput }}</code><br>
                    <span class="tr-label">实际：</span><code>{{ tr.actualOutput }}</code>
                  </div>
                </div>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import CodeEditor from '@/components/CodeEditor/CodeEditor.vue'
import { runCode, submitCode } from '@/api/modules/code'
import { getExerciseDetail } from '@/api/modules/exercise.js'
import { useLearningStatsStore } from '@/stores/learningStats.js'

const route = useRoute()
const statsStore = useLearningStatsStore()

const DEFAULT_TEMPLATES = {
  'c++': '#include <bits/stdc++.h>\nusing namespace std;\n\nint main() {\n    int a, b;\n    cin >> a >> b;\n    cout << a + b << endl;\n    return 0;\n}',
  'c': '#include <stdio.h>\n\nint main() {\n    int a, b;\n    scanf("%d %d", &a, &b);\n    printf("%d\\n", a + b);\n    return 0;\n}',
  'python': 'a, b = map(int, input().split())\nprint(a + b)\n'
}

const LOCAL_EXERCISE = {
  id: 1,
  title: '两数之和（本地测试题）',
  difficulty: 'EASY',
  description: '输入两个整数 a 和 b，输出它们的和。\n\n这是代码运行模块的本地固定测试题，不依赖习题数据库或 Neo4j。',
  testCases: [
    { input: '3 5', expectedOutput: '8' },
    { input: '0 0', expectedOutput: '0' },
    { input: '-2 7', expectedOutput: '5' }
  ],
  initialCode: DEFAULT_TEMPLATES
}

const leftTab = ref('desc')
const resultTab = ref('cases')
const selectedLanguage = ref('c++')
const running = ref(false)
const submitting = ref(false)
const runResult = ref(null)
const submitResult = ref(null)
const activeCaseIndex = ref(0)
const activeResultType = ref(null)
const code = ref(DEFAULT_TEMPLATES['c++'])
const exercise = ref(LOCAL_EXERCISE)

function parseJsonField(value, fallback) {
  if (Array.isArray(value) || (value && typeof value === 'object')) {
    return value
  }
  if (typeof value !== 'string' || !value.trim()) {
    return fallback
  }
  try {
    return JSON.parse(value)
  } catch (e) {
    console.warn('解析习题 JSON 字段失败:', e)
    return fallback
  }
}

function normalizeTestCases(value) {
  const testCases = parseJsonField(value, [])
  return Array.isArray(testCases) ? testCases : []
}

function normalizeInitialCode(value) {
  const initialCode = parseJsonField(value, DEFAULT_TEMPLATES)
  return initialCode && typeof initialCode === 'object' ? initialCode : DEFAULT_TEMPLATES
}

async function loadExercise() {
  const id = route.params.id
  if (!id) return
  try {
    const data = await getExerciseDetail(id)
    if (data) {
      exercise.value = {
        ...LOCAL_EXERCISE,
        id: data.id,
        title: data.title,
        difficulty: data.difficulty,
        description: data.description,
        knowledgePointId: data.knowledgePointId,
        initialCode: normalizeInitialCode(data.initialCode),
        testCases: normalizeTestCases(data.testCases),
      }
      code.value = exercise.value.initialCode?.[selectedLanguage.value] || DEFAULT_TEMPLATES[selectedLanguage.value] || ''
      activeCaseIndex.value = 0
    }
  } catch (e) {
    console.warn('加载习题详情失败，使用本地习题:', e)
  }
}

onMounted(() => {
  loadExercise()
})

watch(selectedLanguage, (lang) => {
  code.value = exercise.value.initialCode?.[lang] || DEFAULT_TEMPLATES[lang] || ''
  runResult.value = null
  submitResult.value = null
  activeResultType.value = null
  resultTab.value = 'cases'
})

const monacoLanguage = computed(() =>
    ({ 'c++': 'cpp', 'c': 'c', 'python': 'python' }[selectedLanguage.value] || 'cpp')
)

const difficultyType = computed(() =>
    ({ EASY: 'success', MEDIUM: 'warning', HARD: 'danger' }[exercise.value.difficulty] || 'info')
)

const statusText = computed(() => {
  if (!submitResult.value) return ''
  return { ACCEPTED: '通过', WRONG_ANSWER: '答案错误', COMPILE_ERROR: '编译错误', RUNTIME_ERROR: '运行错误' }[submitResult.value.status] || submitResult.value.status
})

async function onRun() {
  running.value = true
  resultTab.value = 'result'
  activeResultType.value = 'run'
  try {
    const res = await runCode({
      language: selectedLanguage.value,
      code: code.value,
      stdin: exercise.value.testCases?.[activeCaseIndex.value]?.input || ''
    })
    runResult.value = res
  } catch (e) {
    runResult.value = { compileError: '请求失败：' + e.message }
  } finally {
    running.value = false
  }
}

async function onSubmit() {
  submitting.value = true
  resultTab.value = 'result'
  activeResultType.value = 'submit'
  try {
    const res = await submitCode({
      language: selectedLanguage.value,
      code: code.value,
      testCases: exercise.value.testCases || []
    })
    submitResult.value = res

    const isCorrect = res?.status === 'ACCEPTED'
    const exerciseId = route.params.id || exercise.value.id
    statsStore.recordExerciseResult(
      exerciseId,
      exercise.value.knowledgePointId,
      'PROGRAMMING',
      isCorrect,
      code.value
    )
  } catch (e) {
    submitResult.value = { status: 'RUNTIME_ERROR', errorMessage: '请求失败：' + e.message, passCount: 0, totalCount: 0, testResults: [] }
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.exercise-detail {
  display: flex;
  height: 100%;
  background: #f0f2f5;
  color: #1f2329;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  overflow: hidden;
  gap: 8px;
  padding: 8px;
}

.problem-panel {
  width: 45%;
  min-width: 320px;
  border-radius: 8px;
  overflow-y: auto;
  background: #ffffff;
  border: 1px solid #e4e7ed;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}

.problem-panel :deep(.el-tabs__header) {
  padding: 0 16px;
  margin-bottom: 0;
}

.problem-panel :deep(.el-tabs__header) {
  padding: 0 16px;
  margin-bottom: 0;
}

.problem-content {
  padding: 24px;
  line-height: 1.8;
  color: #1f2329;
}

.problem-content h2 {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 10px;
  color: #1f2329;
}

.problem-content p {
  color: #4e5969;
  font-size: 14px;
}

.example-block { margin-top: 20px; }

.example-block p strong {
  color: #1f2329;
  font-size: 14px;
}

.example-pre {
  background: #f7f8fa;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  padding: 10px 14px;
  font-size: 13px;
  line-height: 1.7;
  margin: 6px 0;
  color: #4e5969;
}

.editor-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  gap: 8px;
}

.editor-toolbar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: #ffffff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  flex-shrink: 0;
}

.editor-area {
  flex: 1;
  min-height: 0;
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e4e7ed;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}

.result-area {
  height: 240px;
  background: #ffffff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  overflow-y: auto;
  padding: 0 12px;
  flex-shrink: 0;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}

.empty-hint {
  color: #c0c4cc;
  text-align: center;
  padding: 30px 0;
  font-size: 13px;
}

.cases-list { padding: 8px 0; }
.case-detail { margin-top: 10px; }

.case-label {
  font-size: 12px;
  color: #909399;
  margin: 8px 0 4px;
  font-weight: 500;
}

.case-pre {
  background: #f5f7fa;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 13px;
  margin: 0;
  white-space: pre-wrap;
  color: #1f2329;
}

.error-pre {
  background: #fff2f0;
  border: 1px solid #ffccc7;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 12px;
  color: #cf1322;
  margin: 6px 0;
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
</style>
