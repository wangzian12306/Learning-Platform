import http from '@/api/index.js'

// ----------------------------------------------------------------
// AI 辅助 API
// owner：AI 辅助功能
// ----------------------------------------------------------------

/** 发送 AI 问答消息 */
export function sendChatMessage(data) {
  return http.post('/ai/chat', data)
}

/** AI 代码分析与纠错 */
export function analyzeCode(data) {
  return http.post('/ai/code/analysis', data)
}

/** AI 代码生成 */
export function generateCode(data) {
  return http.post('/ai/code/generation', data)
}

/** 获取历史对话记录 */
export function getChatHistory(sessionId, userId, limit = 50) {
  return http.get(`/ai/sessions/${sessionId}`, { params: { user_id: userId, limit } })
}
