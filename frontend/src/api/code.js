import axios from 'axios'

const http = axios.create({
  baseURL: 'http://localhost:8080/api',
  timeout: 30000
})

export function runCode(data) {
  return http.post('/code/run', data)
}

export function submitCode(data) {
  return http.post('/code/submit', data)
}
