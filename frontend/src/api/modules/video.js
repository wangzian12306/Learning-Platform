import http from '@/api/index.js'

// ----------------------------------------------------------------
// 视频模块 API
// owner：视频讲解 + 全局整合
// ----------------------------------------------------------------

/** 获取某知识点的视频列表 */
export function getVideoList(knowledgeId) {
  return http.get('/video/list', { params: { knowledgeId } })
}

/** 记录视频观看进度 */
export function saveWatchProgress(data) {
  return http.post('/video/watch', data)
}
