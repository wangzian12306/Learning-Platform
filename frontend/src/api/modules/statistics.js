import http from '@/api/index.js'

// ----------------------------------------------------------------
// 学习跟踪与统计 API
// owner：学习跟踪与统计分析
// ----------------------------------------------------------------

/** 记录学习行为事件（知识点浏览、开始学习等） */
export function recordBehavior(data) {
  return http.post('/learning/record', data)
}

/** 获取当前用户全部学习进度 */
export function getLearningProgress() {
  return http.get('/learning/progress')
}

/** 更新知识点学习状态 */
export function updateProgress(data) {
  return http.put('/learning/progress', data)
}

/** 获取统计分析数据 */
export function getStatistics() {
  return http.get('/learning/statistics')
}
