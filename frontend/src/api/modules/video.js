import http from '@/api/index.js'

const getUserHeaders = () => ({
  'X-User-Id': localStorage.getItem('userId') || '1',
})

/** 获取某知识点的视频列表；knowledgeId 为空时查询全部视频。 */
export function getVideoList(knowledgeId) {
  return http.get('/video/list', { params: { knowledgeId } })
}

/** 获取视频详情。 */
export function getVideoDetail(id) {
  return http.get(`/video/${id}`)
}

/** 根据知识图谱关联关系推荐相关视频。 */
export function getRecommendedVideos(id) {
  return http.get(`/video/${id}/recommendations`)
}

/** 查询当前用户在某个视频上的观看记录。 */
export function getWatchRecord(videoId) {
  return http.get(`/video/watch-record/${videoId}`, {
    headers: getUserHeaders(),
  })
}

/** 记录视频观看进度。 */
export function saveWatchProgress(data) {
  return http.post('/video/watch-record', data, {
    headers: getUserHeaders(),
  })
}
