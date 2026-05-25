<template>
  <div class="choice-exercise-page">
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
              <el-tag :type="type === 'single' ? 'primary' : 'warning'" size="small">
                {{ type === 'single' ? '单选题' : '多选题' }}
              </el-tag>
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
        <div class="question-text" v-html="formatQuestion(exercise.description)"></div>

        <!-- 单选题 -->
        <div v-if="type === 'single' && exerciseOptions.length > 0" class="single-choice">
          <el-radio-group v-model="selectedAnswer" class="options-list">
            <el-radio
                v-for="(option, index) in exerciseOptions"
                :key="index"
                :label="getOptionKey(index)"
                class="option-item"
                :class="{ 'selected': selectedAnswer === getOptionKey(index) }"
            >
              <span class="option-key">{{ getOptionKey(index) }}.</span>
              <span class="option-text">{{ option.text || option }}</span>
            </el-radio>
          </el-radio-group>
        </div>

        <!-- 多选题 -->
        <div v-if="type === 'multiple' && exerciseOptions.length > 0" class="multiple-choice">
          <el-checkbox-group v-model="selectedAnswers" class="options-list">
            <el-checkbox
                v-for="(option, index) in exerciseOptions"
                :key="index"
                :label="getOptionKey(index)"
                class="option-item"
                :class="{ 'selected': selectedAnswers.includes(getOptionKey(index)) }"
            >
              <span class="option-key">{{ getOptionKey(index) }}.</span>
              <span class="option-text">{{ option.text || option }}</span>
            </el-checkbox>
          </el-checkbox-group>
        </div>

        <!-- 如果没有选项，显示提示 -->
        <div v-if="exerciseOptions.length === 0" class="no-options">
          <el-alert
              title="无选项"
              type="warning"
              description="该选择题暂无选项，请联系管理员添加选项。"
              show-icon
              :closable="false"
          />
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <el-button
            type="primary"
            :loading="submitting"
            @click="handleSubmit"
            :disabled="!isAnswerSelected || isSubmitted"
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
  Check,
  Promotion,
  View
} from '@element-plus/icons-vue'
import { useLearningStatsStore } from '@/stores/learningStats.js'

const route = useRoute()
const router = useRouter()
const statsStore = useLearningStatsStore()

const id = route.params.id
const type = route.query.type || 'single'
const exerciseTitle = decodeURIComponent(route.query.title || '选择题')

// 响应式数据
const exercise = ref({})
const loading = ref(false)
const submitting = ref(false)
const selectedAnswer = ref('')
const selectedAnswers = ref([])
const remainingTime = ref(0)
const timer = ref(null)
const activeCollapse = ref([])
const isSubmitted = ref(false)
const result = ref(null)

// 计算属性
const isAnswerSelected = computed(() => {
  if (type === 'single') {
    return !!selectedAnswer.value
  } else if (type === 'multiple') {
    return selectedAnswers.value.length > 0
  }
  return false
})

const hasAnswer = computed(() => {
  if (type === 'single') {
    return !!selectedAnswer.value
  } else if (type === 'multiple') {
    return selectedAnswers.value.length > 0
  }
  return false
})

const timeLimit = computed(() => {
  return exercise.value.timeLimit || 120
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

const exerciseOptions = computed(() => {
  if (exercise.value.options) {
    try {
      // 尝试解析选项
      const options = typeof exercise.value.options === 'string'
          ? JSON.parse(exercise.value.options)
          : exercise.value.options

      // 确保是数组格式
      if (Array.isArray(options)) {
        return options
      } else if (typeof options === 'object') {
        // 如果是对象，转换为数组
        return Object.entries(options).map(([key, value]) => ({
          key: key,
          text: value
        }))
      }
    } catch (e) {
      console.error('解析选项失败:', e)
    }
  }
  return []
})

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
  return text.replace(/\n/g, '<br>')
}

const formatAnalysis = (text) => {
  if (!text) return '暂无解析'
  return text.replace(/\n/g, '<br>')
}

const getOptionKey = (index) => {
  return String.fromCharCode(65 + index) // A, B, C, D...
}

// API调用
const fetchExerciseDetail = async () => {
  loading.value = true
  try {
    const response = await getExerciseDetail(id)
    exercise.value = response || {}

    console.log('选择题详情:', exercise.value)
    console.log('选项数据:', exercise.value.options)
    console.log('解析后选项:', exerciseOptions.value)

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
  if (!isAnswerSelected.value) {
    ElMessage.warning('请先选择答案')
    return
  }

  submitting.value = true
  try {
    // 构建答案
    const answer = type === 'single' ? selectedAnswer.value : selectedAnswers.value.join(',')

    // 调用API提交答案
    const response = await submitAnswer({
      exerciseId: id,
      userAnswer: answer
    })

    result.value = response
    isSubmitted.value = true

    const isCorrect = response?.correct === true || response?.correct === 'true'
    statsStore.recordExerciseResult(
      id,
      exercise.value.knowledgePointId,
      type === 'single' ? 'SINGLE_CHOICE' : 'MULTIPLE_CHOICE',
      isCorrect,
      answer
    )

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
    ElMessageBox.alert(
        `正确答案: ${exercise.value.answer}`,
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
  selectedAnswer.value = ''
  selectedAnswers.value = []
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
.choice-exercise-page {
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
.question-text {
  font-size: 16px;
  line-height: 1.8;
  margin-bottom: 30px;
  color: #1f2329;
  white-space: pre-wrap;
}

.options-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}
.option-item {
  padding: 16px 20px;
  border: 2px solid #e4e7ed;
  border-radius: 8px;
  transition: all 0.3s;
  margin: 0 !important;
  width: 100%;
  background: white;
  cursor: pointer;
}
.option-item:hover {
  border-color: #a0cfff;
  background-color: #f5f7ff;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.1);
}
.option-item.selected {
  border-color: #409eff;
  background-color: #ecf5ff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.2);
}
.option-item.selected :deep(.el-radio__inner) {
  border-color: #409eff;
  background-color: #409eff;
}
.option-item.selected :deep(.el-checkbox__inner) {
  border-color: #409eff;
  background-color: #409eff;
}
.option-key {
  font-weight: 600;
  font-size: 16px;
  margin-right: 12px;
  min-width: 24px;
  display: inline-block;
  color: #409eff;
}
.option-text {
  flex: 1;
  font-size: 15px;
  line-height: 1.6;
  color: #1f2329;
}

.no-options {
  margin: 20px 0;
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