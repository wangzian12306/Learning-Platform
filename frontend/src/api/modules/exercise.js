import http from '@/api/index.js'

// ----------------------------------------------------------------
// 习题模块 API
// owner：习题模块
// ----------------------------------------------------------------

/** 获取某知识点的练习题列表 */
export function getExerciseList(knowledgeId, params) {
  return http.get(`/exercise/list`, { params: { knowledgeId, ...params } })
}

/** 提交答题 */
export function submitAnswer(data) {
  return http.post('/exercise/submit', data)
}

/** 获取错题记录 */
export function getWrongList() {
  return http.get('/exercise/wrong')
}
