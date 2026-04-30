import http from '@/api/index.js'

// ----------------------------------------------------------------
// 知识点内容 API
// owner：知识点详细讲解（图文）
// ----------------------------------------------------------------

/** 获取知识点目录树（基于图谱层级） */
export function getKnowledgeTree() {
  return http.get('/knowledge/tree')
}

/** 获取知识点详情 */
export function getKnowledgeDetail(id) {
  return http.get(`/knowledge/${id}`)
}

/** 获取知识点的代码示例列表 */
export function getCodeExamples(knowledgeId) {
  return http.get(`/knowledge/${knowledgeId}/codes`)
}
