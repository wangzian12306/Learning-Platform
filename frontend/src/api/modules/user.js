import http from '@/api/index.js'

// ----------------------------------------------------------------
// 用户模块 API
// owner：项目仓库 + 技术架构 + 审核 PR
// ----------------------------------------------------------------

export function login(data) {
  return http.post('/user/login', data)
}

export function getUserInfo() {
  return http.get('/user/info')
}

export function register(data) {
  return http.post('/user/register', data)
}
