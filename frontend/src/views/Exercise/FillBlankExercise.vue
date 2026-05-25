<template>
  <div class="fill-blank-exercise-page">
    <!-- 页面头部 -->
    <div class="header">
      <el-page-header @back="goBack">
        <template #content>
          <div class="header-content">
            <h1>{{ exerciseTitle }}</h1>
            <div class="meta-info">
              <el-tag :type="getDifficultyTag(exercise.difficulty)" size="small">
                {{ getDifficultyText(exercise.difficulty) }}
              </el-tag>
              <el-tag type="info" size="small">填空题</el-tag>
              <span class="exercise-id">ID: {{ id }}</span>
              <span v-if="timeLimit > 0" class="time-info">
                <el-icon><Timer /></el-icon>
                限时: {{ formatTimeLimit(timeLimit) }}
              </span>
            </div>
          </div>
        </template>
      </el-page-header>

      <!-- 计时器 -->
      <div v-if="timeLimit > 0" class="timer-container">
        <el-statistic title="剩余时间" :value="formatRemainingTime(remainingTime)" />
      </div>
    </div>

    <!-- 习题卡片 -->
    <el-card class="exercise-card" v-loading="loading">
      <!-- 题目描述 -->
      <div class="question-content">
        <div class="question-text-inline">
          <template v-for="(segment, idx) in questionSegments" :key="idx">
            <span v-if="segment.type === 'text'" class="text-segment">{{ segment.text }}</span>
            <span v-else class="inline-blank-wrapper">
              <span class="blank-number">({{ segment.index }})</span>
              <el-input
                v-model="blanks[segment.index - 1].answer"
                :placeholder="`第${segment.index}空`"
                :disabled="isSubmitted"
                class="inline-blank-input"
                :maxlength="100"
                size="default"
                @keyup.enter="handleSubmit"
              />
              <el-tag
                v-if="blanks[segment.index - 1].correct !== undefined"
                :type="blanks[segment.index - 1].correct ? 'success' : 'danger'"
                size="small"
                class="inline-result-tag"
              >
                {{ blanks[segment.index - 1].correct ? '✓' : '✗' }}
              </el-tag>
            </span>
          </template>
        </div>

        <div v-if="blanks.length > 0 && isSubmitted" class="blanks-feedback-section">
          <div v-for="(blank, index) in blanks" :key="'fb-' + index" class="blank-feedback-item">
            <span class="feedback-label">第 {{ index + 1 }} 空：</span>
            <el-tag :type="blank.correct ? 'success' : 'danger'" size="small">
              {{ blank.correct ? '正确' : '错误' }}
            </el-tag>
            <span v-if="!blank.correct" class="feedback-correct-answer">
              正确答案：<strong>{{ blank.correctAnswer }}</strong>
            </span>
          </div>
        </div>

        <div v-if="blanks.length === 0" class="general-answer">
          <el-input
              v-model="generalAnswer"
              type="textarea"
              :rows="4"
              placeholder="请在此处填写你的答案..."
              clearable
              resize="none"
              :disabled="isSubmitted"
              :maxlength="500"
              show-word-limit
          />
          <div class="general-answer-hint">
            <el-icon><InfoFilled /></el-icon>
            <span>本题有多个空，请用 <strong>|</strong>（竖线）分隔各空答案，例如：答案1|答案2|答案3</span>
          </div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <el-button
            type="primary"
            :loading="submitting"
            @click="handleSubmit"
            :disabled="!isAnswerFilled || isSubmitted"
            :icon="isSubmitted ? Check : null"
        >
          {{ isSubmitted ? '已提交' : '提交答案' }}
        </el-button>
        <el-button
            @click="resetAnswer"
            :disabled="isSubmitted || !hasAnswer"
        >
          重置答案
        </el-button>
        <el-button
            type="info"
            @click="showHint"
            :icon="Promotion"
        >
          查看提示
        </el-button>
        <el-button
            type="success"
            @click="showAnswer"
            :icon="View"
        >
          查看答案
        </el-button>
      </div>
    </el-card>

    <!-- 结果展示 -->
    <el-alert
        v-if="isSubmitted"
        :title="resultTitle"
        :type="resultType"
        :description="resultMessage"
        show-icon
        :closable="false"
        class="result-alert"
    />

    <!-- 解析区域 -->
    <el-collapse v-model="activeCollapse" class="analysis-panel">
      <el-collapse-item title="题目解析" name="analysis">
        <div v-if="exercise.analysis" class="analysis-content">
          <div class="analysis-title">📖 解析：</div>
          <div v-html="formatAnalysis(exercise.analysis)"></div>
        </div>
        <div v-else class="no-analysis">暂无题目解析</div>
      </el-collapse-item>

      <el-collapse-item title="参考答案" name="answer">
        <div v-if="exercise.answer" class="reference-answer">
          <div class="answer-title">✅ 正确答案：</div>
          <pre>{{ exercise.answer }}</pre>
        </div>
        <div v-else class="no-answer">暂无参考答案</div>
      </el-collapse-item>

      <el-collapse-item title="统计信息" name="stats">
        <div class="stats-info">
          <el-descriptions :column="3" border>
            <el-descriptions-item label="总尝试次数">
              <el-tag type="info">{{ exercise.totalAttempts || 0 }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="正确次数">
              <el-tag type="success">{{ exercise.correctAttempts || 0 }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="通过率">
              <el-progress
                  :percentage="((exercise.passRate || 0) * 100)"
                  :format="(percent) => `${percent.toFixed(1)}%`"
                  :stroke-width="20"
                  :show-text="true"
              />
            </el-descriptions-item>
          </el-descriptions>
        </div>
      </el-collapse-item>
    </el-collapse>

    <!-- 知识点卡片 -->
    <el-card v-if="exercise.knowledgeName" class="knowledge-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>📚 相关知识点</span>
        </div>
      </template>
      <div class="knowledge-content">
        <el-tag type="primary" size="large">{{ exercise.knowledgeName }}</el-tag>
        <p v-if="exercise.knowledgeDescription" class="knowledge-desc">
          {{ exercise.knowledgeDescription }}
        </p>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  getExerciseDetail,
  submitAnswer
} from '@/api/modules/exercise.js'
import {
  ElMessage,
  ElMessageBox
} from 'element-plus'
import {
  Timer,
  CircleCheck,
  CircleClose,
  Check,
  Promotion,
  View,
  InfoFilled
} from '@element-plus/icons-vue'
import { useLearningStatsStore } from '@/stores/learningStats.js'

const route = useRoute()
const router = useRouter()
const statsStore = useLearningStatsStore()

const id = route.params.id
const exerciseTitle = decodeURIComponent(route.query.title || '填空题')

// 响应式数据
const exercise = ref({})
const loading = ref(false)
const submitting = ref(false)
const blanks = ref([])
const generalAnswer = ref('')
const remainingTime = ref(0)
const timer = ref(null)
const activeCollapse = ref([])
const isSubmitted = ref(false)
const userAnswer = ref('')
const result = ref(null)

// 计算属性
const isAnswerFilled = computed(() => {
  if (blanks.value.length > 0) {
    return blanks.value.every(blank => blank.answer && blank.answer.trim())
  }
  return generalAnswer.value && generalAnswer.value.trim()
})

const hasAnswer = computed(() => {
  if (blanks.value.length > 0) {
    return blanks.value.some(blank => blank.answer && blank.answer.trim())
  }
  return generalAnswer.value && generalAnswer.value.trim()
})

const timeLimit = computed(() => {
  return exercise.value.timeLimit || 180
})

const formatTimeLimit = (seconds) => {
  if (seconds >= 3600) {
    const h = Math.floor(seconds / 3600)
    const m = Math.floor((seconds % 3600) / 60)
    return m > 0 ? `${h}小时${m}分钟` : `${h}小时`
  }
  if (seconds >= 60) {
    const m = Math.floor(seconds / 60)
    const s = seconds % 60
    return s > 0 ? `${m}分${s}秒` : `${m}分钟`
  }
  return `${seconds}秒`
}

const formatRemainingTime = (seconds) => {
  if (seconds <= 0) return '00:00'
  const m = Math.floor(seconds / 60)
  const s = seconds % 60
  return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
}

const resultTitle = computed(() => {
  if (!result.value) return ''
  return result.value.correct ? '回答正确！🎉' : '回答错误'
})

const resultType = computed(() => {
  if (!result.value) return 'info'
  return result.value.correct ? 'success' : 'error'
})

const resultMessage = computed(() => {
  if (!result.value) return ''
  if (result.value.correct) {
    return '恭喜你答对了！你的答案是正确的。'
  } else {
    return '很遗憾，你的答案是错误的。请查看解析，学习正确答案。'
  }
})

// 工具函数
const getDifficultyTag = (difficulty) => {
  const map = { EASY: 'success', MEDIUM: 'warning', HARD: 'danger' }
  return map[difficulty] || 'info'
}

const getDifficultyText = (difficulty) => {
  const map = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }
  return map[difficulty] || difficulty
}

const formatQuestion = (text) => {
  if (!text) return ''
  return text.replace(/_{2,}/g, '<span class="blank-mark">______</span>')
}

const formatAnalysis = (text) => {
  if (!text) return '暂无解析'
  return text.replace(/\n/g, '<br>')
}

const questionSourceText = computed(() => {
  const desc = exercise.value.description || ''
  const title = exercise.value.title || ''
  const descBlankCount = (desc.match(/_{2,}/g) || []).length
  const titleBlankCount = (title.match(/_{2,}/g) || []).length
  if (descBlankCount > 0) return desc
  if (titleBlankCount > 0) return title
  return desc || title
})

const questionSegments = computed(() => {
  const text = questionSourceText.value
  if (!text) return []
  const parts = text.split(/_{2,}/)
  const segments = []
  parts.forEach((part, idx) => {
    if (part) {
      segments.push({ type: 'text', text: part })
    }
    if (idx < parts.length - 1) {
      segments.push({ type: 'blank', index: idx + 1 })
    }
  })
  return segments
})

const parseBlanks = (description, title) => {
  const desc = description || ''
  const titleText = title || ''
  const descBlankCount = (desc.match(/_{2,}/g) || []).length
  const titleBlankCount = (titleText.match(/_{2,}/g) || []).length
  const sourceText = descBlankCount > 0 ? desc : (titleBlankCount > 0 ? titleText : desc)
  const blankMatches = sourceText.match(/_{2,}/g) || []
  return blankMatches.map((_, index) => ({
    id: index + 1,
    label: `第 ${index + 1} 空`,
    placeholder: `第${index + 1}空`,
    answer: '',
    correct: undefined,
    correctAnswer: '',
    feedback: null
  }))
}

const parseCorrectAnswers = (answerStr, blankCount) => {
  if (!answerStr) return []
  if (answerStr.includes('|')) {
    return answerStr.split('|')
  }
  if (blankCount > 1 && answerStr.includes(',')) {
    return answerStr.split(',')
  }
  return [answerStr]
}

// API调用
const fetchExerciseDetail = async () => {
  loading.value = true
  try {
    const response = await getExerciseDetail(id)
    exercise.value = response || {}

    console.log('填空题详情:', exercise.value)

    if (exercise.value.description || exercise.value.title) {
      blanks.value = parseBlanks(exercise.value.description, exercise.value.title)
    }

    // 初始化计时器
    if (timeLimit.value > 0) {
      remainingTime.value = timeLimit.value
      startTimer()
    }

  } catch (error) {
    console.error('获取习题详情失败:', error)
    ElMessage.error('加载习题失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 计时器相关
const startTimer = () => {
  clearInterval(timer.value)
  timer.value = setInterval(() => {
    if (remainingTime.value > 0) {
      remainingTime.value--
    } else {
      clearInterval(timer.value)
      handleTimeout()
    }
  }, 1000)
}

const handleTimeout = () => {
  ElMessage.warning('时间到！将自动提交答案')
  handleSubmit()
}

// 提交答案
const handleSubmit = async () => {
  if (!isAnswerFilled.value) {
    ElMessage.warning('请先填写答案')
    return
  }

  submitting.value = true
  try {
    // 构建答案
    const answer = blanks.value.length > 0
        ? blanks.value.map(b => b.answer).join('|')
        : generalAnswer.value

    userAnswer.value = answer

    // 调用API提交答案
    const response = await submitAnswer({
      exerciseId: id,
      userAnswer: answer
    })

    result.value = response
    isSubmitted.value = true

    let isCorrect = response?.correct === true || response?.correct === 'true'
    if (blanks.value.length > 0 && exercise.value.answer) {
      const correctAnswers = parseCorrectAnswers(exercise.value.answer, blanks.value.length)
      isCorrect = blanks.value.every((blank, index) =>
        correctAnswers[index] && blank.answer.trim() === correctAnswers[index].trim()
      )
    }
    statsStore.recordExerciseResult(
      id,
      exercise.value.knowledgePointId,
      'FILL_BLANK',
      isCorrect,
      answer
    )

    if (blanks.value.length > 0 && exercise.value.answer) {
      const correctAnswers = parseCorrectAnswers(exercise.value.answer, blanks.value.length)
      blanks.value.forEach((blank, index) => {
        blank.correctAnswer = correctAnswers[index] || ''
        blank.correct = correctAnswers[index] && blank.answer.trim() === correctAnswers[index].trim()
        blank.feedback = {
          type: blank.correct ? 'success' : 'error',
          message: blank.correct ? '回答正确' : `应为: ${correctAnswers[index] || '无答案'}`
        }
      })
    }

    // 停止计时器
    if (timeLimit.value > 0) {
      clearInterval(timer.value)
    }

    // 自动展开解析
    activeCollapse.value = ['analysis', 'answer', 'stats']

  } catch (error) {
    console.error('提交答案失败:', error)
    let errorMsg = '提交失败'
    if (error.response?.data?.message) {
      errorMsg = error.response.data.message
    }
    ElMessage.error(errorMsg)
  } finally {
    submitting.value = false
  }
}

// 查看提示
const showHint = () => {
  if (exercise.value.hint) {
    ElMessageBox.alert(
        exercise.value.hint,
        '题目提示',
        {
          confirmButtonText: '我知道了',
          customClass: 'hint-dialog'
        }
    )
  } else {
    ElMessage.info('暂无提示，请仔细审题')
  }
}

// 查看答案
const showAnswer = () => {
  if (exercise.value.answer) {
    const correctAnswers = parseCorrectAnswers(exercise.value.answer, blanks.value.length)
    let displayAnswer
    if (correctAnswers.length > 1) {
      displayAnswer = correctAnswers.map((a, i) => `第${i + 1}空: ${a}`).join('\n')
    } else {
      displayAnswer = exercise.value.answer
    }
    ElMessageBox.alert(
        `正确答案:\n${displayAnswer}`,
        '查看答案',
        {
          confirmButtonText: '确定',
          customClass: 'answer-dialog'
        }
    )
  } else {
    ElMessage.info('暂无参考答案')
  }
}

// 重置答案
const resetAnswer = () => {
  blanks.value.forEach(blank => {
    blank.answer = ''
    blank.correct = undefined
    blank.feedback = null
  })
  generalAnswer.value = ''
  isSubmitted.value = false
  result.value = null
  activeCollapse.value = []

  // 重置计时器
  if (timeLimit.value > 0) {
    remainingTime.value = timeLimit.value
    if (!timer.value) {
      startTimer()
    }
  }

  ElMessage.success('答案已重置')
}

// 导航
const goBack = () => {
  router.back()
}

// 生命周期
onMounted(() => {
  fetchExerciseDetail()
})

onUnmounted(() => {
  clearInterval(timer.value)
})
</script>

<style scoped>
.fill-blank-exercise-page {
  padding: 20px;
  max-width: 1000px;
  margin: 0 auto;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  padding: 20px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
.header-content h1 {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 12px;
  color: #1f2329;
  line-height: 1.4;
}
.meta-info {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}
.exercise-id, .time-info {
  color: #8a919f;
  font-size: 13px;
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.timer-container {
  min-width: 150px;
  text-align: center;
}
.timer-container :deep(.el-statistic__content) {
  font-size: 24px;
  font-weight: bold;
  color: #409eff;
}
.timer-container :deep(.el-statistic__title) {
  font-size: 14px;
  color: #8a919f;
  margin-bottom: 4px;
}

.exercise-card {
  margin-bottom: 20px;
  border-radius: 8px;
  border: none;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.question-content {
  padding: 20px 0;
}
.question-text-inline {
  font-size: 16px;
  line-height: 2.4;
  margin-bottom: 30px;
  color: #1f2329;
  white-space: pre-wrap;
}
.text-segment {
  vertical-align: middle;
}
.inline-blank-wrapper {
  display: inline-flex;
  align-items: center;
  vertical-align: middle;
  margin: 0 4px;
  gap: 4px;
}
.blank-number {
  font-size: 12px;
  color: #409eff;
  font-weight: 600;
  background: #ecf5ff;
  border-radius: 50%;
  width: 22px;
  height: 22px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.inline-blank-input {
  width: 160px;
  vertical-align: middle;
}
.inline-blank-input :deep(.el-input__inner) {
  height: 36px;
  font-size: 14px;
  padding: 0 10px;
  border-radius: 6px;
  border: 2px solid #d9ecff;
  background: #f0f9ff;
  transition: all 0.3s;
}
.inline-blank-input :deep(.el-input__inner:focus) {
  border-color: #409eff;
  background: #fff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}
.inline-blank-input :deep(.el-input__inner:disabled) {
  background: #f5f7fa;
  border-color: #e4e7ed;
}
.inline-result-tag {
  flex-shrink: 0;
}
.blanks-feedback-section {
  margin-top: 20px;
  padding: 16px 20px;
  background: #fafafa;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
}
.blank-feedback-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 0;
  border-bottom: 1px dashed #ebeef5;
}
.blank-feedback-item:last-child {
  border-bottom: none;
}
.feedback-label {
  font-weight: 600;
  font-size: 14px;
  color: #1f2329;
  min-width: 60px;
}
.feedback-correct-answer {
  font-size: 13px;
  color: #f56c6c;
  margin-left: 8px;
}

.general-answer {
  margin-top: 20px;
}
.general-answer-hint {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 10px;
  padding: 10px 14px;
  background: #fdf6ec;
  border: 1px solid #faecd8;
  border-radius: 6px;
  font-size: 13px;
  color: #e6a23c;
  line-height: 1.6;
}
.general-answer-hint .el-icon {
  font-size: 16px;
  flex-shrink: 0;
}
.general-answer-hint strong {
  color: #d48806;
}
.general-answer :deep(.el-textarea__inner) {
  font-size: 15px;
  line-height: 1.6;
  padding: 15px;
  border-radius: 8px;
  border: 2px solid #e4e7ed;
  transition: all 0.3s;
}
.general-answer :deep(.el-textarea__inner:focus) {
  border-color: #409eff;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.2);
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 15px;
  padding: 25px 0 0;
  border-top: 1px solid #f0f0f0;
  margin-top: 20px;
}
.action-buttons .el-button {
  min-width: 120px;
  height: 40px;
  font-weight: 500;
}

.result-alert {
  margin: 20px 0;
  border-radius: 8px;
  border: none;
}
.result-alert :deep(.el-alert__title) {
  font-size: 18px;
  font-weight: 600;
}
.result-alert :deep(.el-alert__description) {
  font-size: 14px;
  line-height: 1.6;
  margin-top: 8px;
}

.analysis-panel {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
.analysis-panel :deep(.el-collapse-item__header) {
  font-size: 16px;
  font-weight: 600;
  padding: 0 20px;
  height: 60px;
  background: #f8f9fa;
  border: none;
}
.analysis-panel :deep(.el-collapse-item__wrap) {
  border: none;
}
.analysis-panel :deep(.el-collapse-item__content) {
  padding: 25px;
  font-size: 14px;
  line-height: 1.8;
  color: #4e5969;
  background: white;
}
.analysis-content, .reference-answer, .stats-info {
  line-height: 1.8;
}
.analysis-title, .answer-title {
  font-weight: 600;
  margin-bottom: 12px;
  color: #1f2329;
  font-size: 15px;
}
.no-analysis, .no-answer {
  color: #8a919f;
  text-align: center;
  padding: 20px 0;
  font-style: italic;
}
.reference-answer pre {
  background: #f5f5f5;
  padding: 20px;
  border-radius: 6px;
  font-family: 'Courier New', monospace;
  white-space: pre-wrap;
  word-break: break-all;
  margin: 0;
  font-size: 14px;
  border: 1px solid #e8e8e8;
}
.stats-info {
  padding: 10px 0;
}
.stats-info :deep(.el-descriptions__label) {
  font-weight: 600;
  width: 100px;
}
.stats-info :deep(.el-progress-bar) {
  width: 200px;
}
.stats-info :deep(.el-progress__text) {
  min-width: 60px;
  text-align: right;
}

.knowledge-card {
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  margin-bottom: 20px;
}
.knowledge-card :deep(.el-card__header) {
  border-bottom: 1px solid #f0f0f0;
  padding: 16px 20px;
  font-weight: 600;
  font-size: 16px;
  background: #f8f9fa;
}
.knowledge-content {
  padding: 20px;
}
.knowledge-content .el-tag {
  font-size: 15px;
  padding: 8px 16px;
  margin-bottom: 12px;
}
.knowledge-desc {
  color: #4e5969;
  font-size: 14px;
  line-height: 1.6;
  margin-top: 10px;
  padding-left: 8px;
  border-left: 3px solid #409eff;
  padding-left: 12px;
}
</style>

<style>
/* 全局样式 */
.hint-dialog {
  width: 500px;
  max-width: 90vw;
}
.hint-dialog .el-message-box__header {
  background: linear-gradient(135deg, #409eff, #5cb3ff);
  padding: 20px;
  border-radius: 8px 8px 0 0;
}
.hint-dialog .el-message-box__title {
  color: white;
  font-size: 18px;
  font-weight: 600;
}
.hint-dialog .el-message-box__content {
  padding: 30px 20px;
  font-size: 15px;
  line-height: 1.8;
  color: #1f2329;
  background: #f8f9fa;
}
.hint-dialog .el-message-box__btns {
  padding: 20px;
  text-align: center;
  border-top: 1px solid #f0f0f0;
}
.hint-dialog .el-button {
  min-width: 120px;
  padding: 10px 30px;
  font-weight: 500;
}

.answer-dialog {
  width: 500px;
  max-width: 90vw;
}
.answer-dialog .el-message-box__header {
  background: linear-gradient(135deg, #67c23a, #85ce61);
  padding: 20px;
  border-radius: 8px 8px 0 0;
}
.answer-dialog .el-message-box__title {
  color: white;
  font-size: 18px;
  font-weight: 600;
}
.answer-dialog .el-message-box__content {
  padding: 30px 20px;
  font-size: 15px;
  line-height: 1.8;
  color: #1f2329;
  background: #f0f9eb;
  font-weight: 500;
  text-align: center;
}
.answer-dialog .el-message-box__btns {
  padding: 20px;
  text-align: center;
  border-top: 1px solid #f0f0f0;
}
</style>

