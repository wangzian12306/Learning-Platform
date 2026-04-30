import http from '@/api/index.js'

// ----------------------------------------------------------------
// 知识图谱 API
// owner：知识图谱构建（数据层）+ 知识图谱交互式可视化
// ----------------------------------------------------------------

/** 获取完整图谱节点和边，用于可视化渲染 */
export function getGraphData() {
  return http.get('/graph/data')
}

/** 获取单个知识点简要信息（图谱节点点击时调用） */
export function getNodeSummary(nodeId) {
  return http.get(`/graph/node/${nodeId}`)
}

/** 搜索知识点（图谱搜索高亮） */
export function searchNodes(keyword) {
  return http.get('/graph/search', { params: { keyword } })
}
