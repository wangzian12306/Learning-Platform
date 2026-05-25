<template>
  <div class="exercise-list-page">
    <div class="page-header">
      <h1>习题练习</h1>
      <p>通过练习巩固所学知识点</p>
    </div>

    <div class="exercise-list" v-loading="loading">
<!--      <div v-if="debug" class="debug-panel">-->
<!--&lt;!&ndash;        <h3>🛠️ 调试信息</h3>&ndash;&gt;-->
<!--&lt;!&ndash;        <p>加载状态: {{ loading }}</p>&ndash;&gt;-->
<!--&lt;!&ndash;        <p>数据长度: {{ exerciseList.length }}</p>&ndash;&gt;-->
<!--&lt;!&ndash;        <p>API调用: 通过 api/modules/exercise.js 调用</p>&ndash;&gt;-->
<!--&lt;!&ndash;        <p>当前页面: {{ filterForm.page }}</p>&ndash;&gt;-->
<!--&lt;!&ndash;        <p>分页大小: {{ filterForm.pageSize }}</p>&ndash;&gt;-->
<!--      </div>-->

      <!-- 搜索框 -->
      <div class="search-box">
        <el-input
            v-model="filterForm.keyword"
            placeholder="搜索习题..."
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
            style="width: 300px; margin-bottom: 20px;"
        >
          <template #append>
            <el-button :icon="Search" @click="handleSearch" />
          </template>
        </el-input>
      </div>

      <template v-if="exerciseList.length > 0">
        <div v-for="ex in exerciseList" :key="ex.id" class="exercise-item">
          <div class="item-header">
            <h3>{{ ex.id }}. {{ ex.title }}</h3>
            <el-tag :type="getDifficultyTag(ex.difficulty)" size="small">
              {{ getDifficultyText(ex.difficulty) }}
            </el-tag>
          </div>
          <p class="description">{{ ex.description }}</p>
          <div class="meta">
            <span class="knowledge">
              <el-icon><Collection /></el-icon>
              知识点: {{ ex.knowledgeName || '未分类' }}
            </span>
            <span class="pass-rate">
              <el-icon><TrendCharts /></el-icon>
              通过率: {{ ex.passRate || 0 }}%
            </span>
            <span class="time-limit">
              <el-icon><Timer /></el-icon>
              限时: {{ formatTimeLimit(ex.timeLimit, ex.type) }}
            </span>
            <span class="type">
              <el-icon><Document /></el-icon>
              题型: {{ getTypeText(ex.type) }}
            </span>
          </div>
          <div class="actions">
            <el-button type="primary" @click="startExercise(ex.id)">开始做题</el-button>
            <el-button
                type="info"
                size="small"
                @click="showAnalysis(ex)"
            >
              查看解析
            </el-button>
          </div>
        </div>

        <!-- 分页 -->
        <div class="pagination-container" v-if="total > 0">
          <el-pagination
              v-model:current-page="filterForm.page"
              v-model:page-size="filterForm.pageSize"
              :page-sizes="[10, 20, 50, 100]"
              :total="total"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="handlePageSizeChange"
              @current-change="handlePageChange"
          />
        </div>
      </template>

      <div v-else-if="!loading" class="empty-state">
        <el-empty description="暂无习题数据" />
      </div>
    </div>
  </div>
</template>

<script setup>
// import { ref, onMounted, computed } from 'vue'
// import { useRouter } from 'vue-router'
// import { Search, Collection, TrendCharts, Timer, Document } from '@element-plus/icons-vue'
// import { getExerciseList } from '@/api/modules/exercise.js'
// import { ElMessage } from 'element-plus'
//
// const router = useRouter()
//
// // 响应式数据
// const loading = ref(false)
// const exerciseList = ref([])
// const total = ref(0)
// const debug = ref(true)  // 调试模式
//
// // 筛选表单
// const filterForm = ref({
//   knowledgeId: null,
//   difficulty: null,
//   keyword: '',
//   page: 1,
//   pageSize: 20
// })
//
// // 工具函数
// const getDifficultyTag = (difficulty) => {
//   const map = { EASY: 'success', MEDIUM: 'warning', HARD: 'danger' }
//   return map[difficulty] || 'info'
// }
//
// const getDifficultyText = (difficulty) => {
//   const map = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }
//   return map[difficulty] || difficulty
// }
//
// const getTypeText = (type) => {
//   const map = {
//     SINGLE_CHOICE: '单选题',
//     MULTIPLE_CHOICE: '多选题',
//     FILL_BLANK: '填空题',
//     PROGRAMMING: '编程题'
//   }
//   return map[type] || type
// }
//
// // API调用
// const fetchExerciseList = async () => {
//   console.log('🔄 开始获取习题列表（通过API模块）')
//   loading.value = true
//
//   try {
//     // 正确：通过API模块调用，遵循框架规范
//     const response = await getExerciseList(filterForm.value.knowledgeId, {
//       page: filterForm.value.page,
//       pageSize: filterForm.value.pageSize,
//       keyword: filterForm.value.keyword || undefined,
//       difficulty: filterForm.value.difficulty || undefined
//     })
//
//     console.log('✅ API模块返回:', response)
//
//     // 注意：根据框架指南，响应已在axios拦截器中解包
//     // 所以response是后端返回的data字段，包含records和total
//     if (response && response.records) {
//       exerciseList.value = response.records || []
//       total.value = response.total || 0
//       console.log('🎉 数据加载成功:', exerciseList.value.length, '条')
//       console.log('📊 总分页数:', total.value)
//     } else {
//       console.warn('⚠️ 数据格式不符合预期:', response)
//       exerciseList.value = []
//       total.value = 0
//     }
//
//   } catch (error) {
//     console.error('❌ 加载失败:', error)
//     ElMessage.error('加载失败: ' + (error.message || '未知错误'))
//     exerciseList.value = []
//     total.value = 0
//   } finally {
//     loading.value = false
//   }
// }
//
// // 事件处理
// const handleSearch = () => {
//   filterForm.value.page = 1
//   fetchExerciseList()
// }
//
// const handlePageSizeChange = (size) => {
//   filterForm.value.pageSize = size
//   filterForm.value.page = 1
//   fetchExerciseList()
// }
//
// const handlePageChange = (page) => {
//   filterForm.value.page = page
//   fetchExerciseList()
// }
//
//
//
//
// const startExercise = (id) => {
//   console.log('跳转到习题详情:', id)
//   router.push(`/exercise/${id}`)
// }
// const showAnalysis = (exercise) => {
//   ElMessage.info(`查看解析: ${exercise.title}`)
//   console.log('习题解析:', exercise)
// }
//
// // 生命周期
// onMounted(() => {
//   console.log('🚀 组件挂载，开始加载数据')
//   fetchExerciseList()
// })
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  Search,
  Collection,
  TrendCharts,
  Timer,
  Document
} from '@element-plus/icons-vue'
import { getExerciseList } from '@/api/modules/exercise.js'
import { ElMessage } from 'element-plus'

const router = useRouter()

// 响应式数据
const loading = ref(false)
const exerciseList = ref([])
const total = ref(0)

// 筛选表单
const filterForm = ref({
  knowledgeId: null,
  difficulty: null,
  type: null,  // 新增类型筛选
  keyword: '',
  page: 1,
  pageSize: 20
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

const getTypeText = (type) => {
  const map = {
    SINGLE_CHOICE: '单选题',
    MULTIPLE_CHOICE: '多选题',
    FILL_BLANK: '填空题',
    PROGRAMMING: '编程题'
  }
  return map[type] || type
}

const getDefaultTimeLimit = (type) => {
  const map = {
    SINGLE_CHOICE: 120,
    MULTIPLE_CHOICE: 120,
    FILL_BLANK: 180,
    PROGRAMMING: 3600
  }
  return map[type] || 120
}

const formatTimeLimit = (timeLimit, type) => {
  const seconds = timeLimit || getDefaultTimeLimit(type)
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

// API调用
const fetchExerciseList = async () => {
  console.log('🔄 开始获取习题列表（通过API模块）')
  loading.value = true

  try {
    const response = await getExerciseList(filterForm.value.knowledgeId, {
      page: filterForm.value.page,
      pageSize: filterForm.value.pageSize,
      keyword: filterForm.value.keyword || undefined,
      difficulty: filterForm.value.difficulty || undefined
    })

    console.log('✅ API模块返回:', response)

    if (response && response.records) {
      exerciseList.value = response.records || []
      total.value = response.total || 0
      console.log('🎉 数据加载成功:', exerciseList.value.length, '条')
    } else {
      console.warn('⚠️ 数据格式不符合预期:', response)
      exerciseList.value = []
      total.value = 0
    }

  } catch (error) {
    console.error('❌ 加载失败:', error)
    ElMessage.error('加载失败: ' + (error.message || '未知错误'))
    exerciseList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 事件处理
const handleSearch = () => {
  filterForm.value.page = 1
  fetchExerciseList()
}

const handlePageSizeChange = (size) => {
  filterForm.value.pageSize = size
  filterForm.value.page = 1
  fetchExerciseList()
}

const handlePageChange = (page) => {
  filterForm.value.page = page
  fetchExerciseList()
}

// 修改开始做题方法，根据题型跳转到不同路由
const startExercise = (id) => {
  console.log('跳转到习题详情:', id)

  // 找到对应的习题对象
  const exercise = exerciseList.value.find(ex => ex.id === id)
  if (!exercise) {
    ElMessage.error('找不到该习题')
    return
  }

  const { type, title } = exercise

  console.log('习题类型:', type, '标题:', title)

  // 根据题型跳转到不同页面
  if (type === 'SINGLE_CHOICE' || type === 'MULTIPLE_CHOICE') {
    // 跳转到选择题页面
    router.push({
      path: `/exercise/choice/${id}`,
      query: {
        type: type === 'SINGLE_CHOICE' ? 'single' : 'multiple',
        title: encodeURIComponent(title || '选择题')
      }
    })
  } else if (type === 'FILL_BLANK') {
    // 跳转到填空题页面
    router.push({
      path: `/exercise/fill/${id}`,
      query: { title: encodeURIComponent(title || '填空题') }
    })
  } else if (type === 'PROGRAMMING') {
    // 跳转到编程题页面
    router.push({
      path: `/exercise/${id}`,
      query: { title: encodeURIComponent(title || '编程题') }
    })
  } else {
    // 默认跳转到详情页
    router.push({
      path: `/exercise/${id}`,
      query: { title: encodeURIComponent(title || '习题详情') }
    })
  }
}

const showAnalysis = (exercise) => {
  ElMessage.info(`查看解析: ${exercise.title}`)
  console.log('习题解析:', exercise)
}

// 生命周期
onMounted(() => {
  console.log('🚀 组件挂载，开始加载数据')
  fetchExerciseList()
})
</script>

<style scoped>
.exercise-list-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;
}
.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  color: #1f2329;
  margin-bottom: 8px;
}
.page-header p {
  color: #8a919f;
  font-size: 14px;
}

.debug-panel {
  background: #f0f0f0;
  padding: 15px;
  margin: 10px 0 20px 0;
  border-left: 4px solid #409eff;
  border-radius: 4px;
}
.debug-panel h3 {
  margin-top: 0;
  color: #409eff;
}
.debug-panel p {
  margin: 5px 0;
  font-size: 13px;
  color: #666;
}

.search-box {
  margin-bottom: 20px;
}

.exercise-item {
  border: 1px solid #e4e7ed;
  padding: 20px;
  margin-bottom: 16px;
  border-radius: 8px;
  background: white;
  transition: all 0.3s ease;
}
.exercise-item:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.item-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2329;
  margin: 0;
  flex: 1;
}

.description {
  color: #4e5969;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 16px;
  min-height: 22px;
}

.meta {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  font-size: 13px;
  color: #8a919f;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}
.meta span {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}
.meta .el-icon {
  font-size: 14px;
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.pagination-container {
  display: flex;
  justify-content: center;
  padding: 24px 0;
  margin-top: 20px;
  border-top: 1px solid #f0f0f0;
}

.empty-state {
  text-align: center;
  padding: 40px 0;
  color: #8a919f;
}
</style>

