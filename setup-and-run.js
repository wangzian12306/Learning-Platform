#!/usr/bin/env node
/**
 * 一键启动脚本 - 数据结构学习平台（代码执行模块）
 * 用法: node setup-and-run.js
 */

const { execFileSync, spawn } = require('child_process')
const path = require('path')
const fs = require('fs')

const ROOT = path.resolve(__dirname)
const FRONTEND_DIR = path.join(ROOT, 'frontend')

// ─── 工具函数 ────────────────────────────────────────────
function run(cmd, args, opts = {}) {
  console.log(`\n▶ ${cmd} ${args.join(' ')}`)
  execFileSync(cmd, args, { stdio: 'inherit', ...opts })
}

function tryRun(cmd, args, opts = {}) {
  try { return execFileSync(cmd, args, { encoding: 'utf8', ...opts }).trim() }
  catch { return null }
}

function checkCommand(cmd) {
  return tryRun('which', [cmd]) !== null
}

function header(text) {
  console.log('\n' + '='.repeat(50))
  console.log('  ' + text)
  console.log('='.repeat(50))
}

// ─── Step 1: 检查前置工具 ────────────────────────────────
header('Step 1: 检查前置工具')

const required = ['docker', 'node', 'npm', 'mvn', 'curl']
const missing = required.filter(cmd => !checkCommand(cmd))
if (missing.length > 0) {
  console.error('\n❌ 缺少以下工具，请先安装：')
  missing.forEach(cmd => {
    const hint = {
      docker: '  → https://docs.docker.com/get-docker/',
      node:   '  → https://nodejs.org/ 或 brew install node',
      npm:    '  → 随 Node.js 一起安装',
      mvn:    '  → brew install maven 或 https://maven.apache.org/download.cgi',
      curl:   '  → macOS 自带，如缺失 brew install curl'
    }[cmd] || ''
    console.error(`  - ${cmd}${hint ? '\n' + hint : ''}`)
  })
  process.exit(1)
}
console.log('✅ 所有前置工具已就绪')

// ─── Step 2: 启动 Piston（代码执行引擎）────────────────────
header('Step 2: 启动 Piston 代码执行引擎')

const composeFile = path.join(ROOT, 'docker-compose.yml')
if (!fs.existsSync(composeFile)) {
  console.error('❌ 找不到 docker-compose.yml，请确认在项目根目录运行此脚本')
  process.exit(1)
}

console.log('正在启动 Docker 容器...')
run('docker', ['compose', '-f', composeFile, 'up', '-d'])

// 等待 Piston 就绪
console.log('\n等待 Piston 启动（最多 30 秒）...')
let pistonReady = false
for (let i = 0; i < 30; i++) {
  const result = tryRun('curl', ['-sf', 'http://localhost:2000/api/v2/runtimes'])
  if (result !== null) { pistonReady = true; break }
  execFileSync('sleep', ['1'])
  process.stdout.write('.')
}
console.log('')
if (!pistonReady) {
  console.error('❌ Piston 启动超时，请检查 Docker 是否运行正常')
  process.exit(1)
}
console.log('✅ Piston 已就绪 (http://localhost:2000)')

// ─── Step 3: 安装 Piston 语言运行时 ─────────────────────
header('Step 3: 安装代码执行语言运行时')

const runtimes = JSON.parse(
  execFileSync('curl', ['-sf', 'http://localhost:2000/api/v2/runtimes'], { encoding: 'utf8' })
)
const installed = runtimes.map(r => r.language)

function installRuntime(language, version) {
  if (installed.includes(language)) {
    console.log(`✅ ${language} ${version} 已安装，跳过`)
    return
  }
  console.log(`📦 安装 ${language} ${version}...`)
  run('curl', [
    '-sf', '-X', 'POST', 'http://localhost:2000/api/v2/packages',
    '-H', 'Content-Type: application/json',
    '-d', JSON.stringify({ language, version })
  ])
  console.log(`✅ ${language} ${version} 安装完成`)
}

installRuntime('c++', '10.2.0')
installRuntime('c', '10.2.0')
installRuntime('python', '3.10.0')

// ─── Step 4: 安装前端依赖 ─────────────────────────────────
header('Step 4: 安装前端依赖 (npm install)')

if (!fs.existsSync(path.join(FRONTEND_DIR, 'node_modules'))) {
  run('npm', ['install'], { cwd: FRONTEND_DIR })
} else {
  console.log('✅ node_modules 已存在，跳过（如需重装请删除 frontend/node_modules）')
}

// ─── Step 5: 后端编译检查 ─────────────────────────────────
header('Step 5: 后端编译 (mvn compile)')
run('mvn', ['compile', '-q'], { cwd: ROOT })
console.log('✅ 后端编译成功')

// ─── Step 6: 启动后端 & 前端 ──────────────────────────────
header('Step 6: 启动后端和前端（Ctrl+C 退出）')

console.log('\n🚀 启动 Spring Boot 后端...')
const backend = spawn('mvn', ['spring-boot:run'], {
  cwd: ROOT,
  stdio: ['ignore', 'pipe', 'pipe']
})

backend.stdout.on('data', d => {
  const s = d.toString()
  if (s.includes('Started') || s.includes('ERROR') || s.includes('Exception')) process.stdout.write(s)
})
backend.stderr.on('data', d => process.stderr.write(d.toString()))

// 等待后端启动
console.log('等待后端启动（最多 60 秒）...')
let backendReady = false
for (let i = 0; i < 60; i++) {
  const result = tryRun('curl', ['-sf', 'http://localhost:8080/api/health'])
  if (result !== null) { backendReady = true; break }
  execFileSync('sleep', ['1'])
  process.stdout.write('.')
}
console.log('')

if (!backendReady) {
  console.log('⚠️  后端健康检查超时（/api/health 未响应），但后端可能仍在启动中，继续启动前端...')
}

console.log('\n🚀 启动前端开发服务器...')
const frontend = spawn('npm', ['run', 'dev'], {
  cwd: FRONTEND_DIR,
  stdio: 'inherit'
})

// 优雅退出
process.on('SIGINT', () => {
  console.log('\n\n正在停止服务...')
  backend.kill()
  frontend.kill()
  process.exit(0)
})

frontend.on('close', code => {
  backend.kill()
  process.exit(code)
})

console.log('\n' + '='.repeat(50))
console.log('  ✅ 全部服务启动完毕！')
console.log('  前端：http://localhost:5173')
console.log('  后端：http://localhost:8080')
console.log('  测试页面：http://localhost:5173/exercise/1')
console.log('  Piston：http://localhost:2000')
console.log('  按 Ctrl+C 停止所有服务')
console.log('='.repeat(50) + '\n')
