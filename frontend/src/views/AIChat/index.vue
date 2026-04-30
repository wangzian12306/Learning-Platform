<template>
  <div class="ai-chat-page">
    <aside class="history-panel">
      <div class="history-header">
        <span>历史对话</span>
        <el-button type="primary" size="small" plain>新建</el-button>
      </div>
      <div class="history-list">
        <div
          v-for="item in sessions"
          :key="item.id"
          class="history-item"
          :class="{ active: item.id === activeSessionId }"
          @click="switchSession(item.id)"
        >
          <div class="title">{{ item.title }}</div>
          <div class="time">{{ item.time }}</div>
        </div>
      </div>
    </aside>

    <section class="chat-panel">
      <div class="message-list">
        <div
          v-for="msg in currentMessages"
          :key="msg.id"
          class="message-row"
          :class="msg.role === 'USER' ? 'user' : 'assistant'"
        >
          <div class="message-main">
            <div
              class="bubble"
              :class="{ 'markdown-bubble': msg.role === 'ASSISTANT' }"
              v-html="msg.role === 'ASSISTANT' ? renderMarkdown(msg.content) : msg.content"
            ></div>
          </div>
          <div class="message-actions">
            <template v-if="msg.role === 'ASSISTANT'">
              <el-tooltip content="重试回答" placement="top">
                <el-button class="op-btn" circle text @click="redoMessage(msg.id)">
                  <el-icon><RefreshRight /></el-icon>
                </el-button>
              </el-tooltip>
              <el-tooltip content="复制回答" placement="top">
                <el-button class="op-btn" circle text @click="copyText(msg.content)">
                  <el-icon><DocumentCopy /></el-icon>
                </el-button>
              </el-tooltip>
            </template>
            <template v-else>
              <el-tooltip content="复制提问" placement="top">
                <el-button class="op-btn" circle text @click="copyText(msg.content)">
                  <el-icon><DocumentCopy /></el-icon>
                </el-button>
              </el-tooltip>
              <el-tooltip content="编辑提问" placement="top">
                <el-button class="op-btn" circle text @click="editPrompt(msg.content)">
                  <el-icon><EditPen /></el-icon>
                </el-button>
              </el-tooltip>
            </template>
          </div>
        </div>
      </div>

      <div class="input-panel">
        <el-input
          v-model="inputText"
          type="textarea"
          :rows="3"
          resize="none"
          placeholder="请输入你的问题，例如：解释二叉树前中后序遍历区别"
        />
        <div class="input-actions">
          <div class="left-actions">
            <input ref="fileInputRef" type="file" class="hidden-file-input" @change="onFileChange" />
            <el-button size="small" plain @click="triggerFileSelect">附件</el-button>
            <span v-if="attachedFileName" class="file-name" :title="attachedFileName">
              {{ attachedFileName }}
              <el-button link type="danger" @click="clearAttachment">移除</el-button>
            </span>
            <span class="model-label">模型：</span>
            <el-select v-model="selectedModel" placeholder="请选择模型" size="default" style="width: 180px">
              <el-option
                v-for="item in modelOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </div>
          <div class="right-actions">
            <el-button @click="clearInput">清空</el-button>
            <el-button type="primary" :loading="isSending" @click="sendMessage">发送</el-button>
          </div>
        </div>
      </div>
    </section>
  </div>
  <el-dialog
    v-model="uploadTipDialogVisible"
    title="上传提示"
    width="420px"
    :close-on-click-modal="false"
    :show-close="false"
  >
    <p class="upload-tip-text">仅支持可按文本方式读取的文件（如代码文件）。</p>
    <p class="upload-tip-text">若文件无法读取，将提示“不支持该文件类型”。</p>
    <el-checkbox v-model="skipUploadTip">以后不再提示</el-checkbox>
    <template #footer>
      <el-button @click="uploadTipDialogVisible = false">取消</el-button>
      <el-button type="primary" @click="confirmUploadTip">确定</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { computed, ref } from 'vue'
import { DocumentCopy, EditPen, RefreshRight } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { marked } from 'marked'
import { analyzeCode, sendChatMessage } from '@/api/modules/ai.js'

const activeSessionId = ref(1)
const inputText = ref('')
const selectedModel = ref('qwen3.6-plus')
const fileInputRef = ref(null)
const attachedFileName = ref('')
const attachedFileContent = ref('')
const isSending = ref(false)
const uploadTipDialogVisible = ref(false)
const skipUploadTip = ref(false)
const currentUserId = 1
const currentSessionId = 'demo-session-1'
const SKIP_UPLOAD_TIP_KEY = 'ai-chat-skip-upload-tip'

const sessions = ref([
  { id: 1, title: '栈和队列的区别', time: '今天 16:35' },
  { id: 2, title: '快速排序复杂度分析', time: '今天 14:12' },
  { id: 3, title: '红黑树旋转示例', time: '昨天 21:18' },
])

const sessionMessages = ref({
  1: [
    { id: 1, role: 'USER', content: '请解释一下链表和数组在插入上的性能差异。' },
    {
      id: 2,
      role: 'ASSISTANT',
      content:
        '一般来说，数组在中间位置插入需要移动元素，时间复杂度为 O(n)；链表在已知插入位置前驱节点时可在 O(1) 完成插入，但查找位置仍可能是 O(n)。',
    },
    {
      id: 7,
      role: 'ASSISTANT',
      content:
        'Markdown 代码渲染测试：\n\n```cpp\n#include <iostream>\nint main() {\n  std::cout << "Hello Markdown";\n  return 0;\n}\n```\n\n行内代码示例：`O(log n)`',
    },
  ],
  2: [
    { id: 3, role: 'USER', content: '快速排序最坏情况为什么是 O(n^2)？' },
    {
      id: 4,
      role: 'ASSISTANT',
      content:
        '当每次分区都极不平衡（例如每次都选到最大/最小值作为枢轴）时，会退化成 n + (n-1) + ... + 1 的比较次数，因此是 O(n^2)。',
    },
  ],
  3: [
    { id: 5, role: 'USER', content: '红黑树左旋和右旋的核心目的是什么？' },
    {
      id: 6,
      role: 'ASSISTANT',
      content:
        '核心目的是在保持二叉搜索树中序有序性的前提下，局部调整树高与颜色冲突，恢复红黑树平衡性质。',
    },
  ],
})

const modelOptions = [
  { label: 'Qwen 3.6 Plus', value: 'qwen3.6-plus' },
  { label: 'DeepSeek V4 Flash', value: 'deepseek-v4-flash' },
]

const currentMessages = computed(() => sessionMessages.value[activeSessionId.value] || [])

const copyText = async (content) => {
  try {
    await navigator.clipboard.writeText(content)
    ElMessage.success('已复制到剪贴板')
  } catch {
    ElMessage.error('复制失败，请检查浏览器权限')
  }
}

const editPrompt = (content) => {
  inputText.value = content
  ElMessage.info('已将提问填入输入框，可继续编辑')
}

const redoMessage = (messageId) => {
  const currentIndex = currentMessages.value.findIndex((item) => item.id === messageId)
  if (currentIndex <= 0) {
    ElMessage.warning('未找到可重试的提问')
    return
  }

  const previousUserMessage = [...currentMessages.value]
    .slice(0, currentIndex)
    .reverse()
    .find((item) => item.role === 'USER')

  if (!previousUserMessage) {
    ElMessage.warning('未找到可重试的提问')
    return
  }

  inputText.value = previousUserMessage.content
  ElMessage.info('已将对应提问回填，可直接重新发送')
}

const triggerFileSelect = () => {
  if (localStorage.getItem(SKIP_UPLOAD_TIP_KEY) === '1') {
    fileInputRef.value?.click()
    return
  }
  uploadTipDialogVisible.value = true
}

const confirmUploadTip = () => {
  if (skipUploadTip.value) {
    localStorage.setItem(SKIP_UPLOAD_TIP_KEY, '1')
  }
  uploadTipDialogVisible.value = false
  fileInputRef.value?.click()
}

const detectLanguageByFileName = (fileName) => {
  const ext = fileName.split('.').pop()?.toLowerCase()
  const map = {
    py: 'Python',
    cpp: 'C++',
    c: 'C',
    java: 'Java',
    js: 'JavaScript',
    ts: 'TypeScript',
    go: 'Go',
    rs: 'Rust',
    cs: 'C#',
  }
  return map[ext] || 'PlainText'
}

const clearAttachment = () => {
  attachedFileName.value = ''
  attachedFileContent.value = ''
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
}

const onFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  try {
    const buffer = await file.arrayBuffer()
    const decoder = new TextDecoder('utf-8', { fatal: true })
    const text = decoder.decode(buffer)
    attachedFileName.value = file.name
    attachedFileContent.value = text
    if (!inputText.value.trim()) {
      inputText.value = '请分析附件代码'
    }
    ElMessage.success(`已加载文件：${file.name}`)
  } catch {
    clearAttachment()
    ElMessage.warning('不支持该文件类型，请上传可读取的文本代码文件')
  }
}

const clearInput = () => {
  inputText.value = ''
  clearAttachment()
}

const appendMessage = (role, content) => {
  if (!sessionMessages.value[activeSessionId.value]) {
    sessionMessages.value[activeSessionId.value] = []
  }
  sessionMessages.value[activeSessionId.value].push({
    id: Date.now() + Math.floor(Math.random() * 1000),
    role,
    content,
  })
}

const switchSession = (sessionId) => {
  activeSessionId.value = sessionId
}

const sendMessage = async () => {
  const question = inputText.value.trim()
  if (!question && !attachedFileContent.value) {
    ElMessage.warning('请输入问题或上传代码文件')
    return
  }

  const userMessage = question || `请分析我上传的代码文件：${attachedFileName.value || '未命名文件'}`
  appendMessage('USER', userMessage)
  isSending.value = true

  try {
    let answer = ''
    if (attachedFileContent.value) {
      const result = await analyzeCode({
        user_id: currentUserId,
        session_id: currentSessionId,
        question: question || `请分析这个代码文件：${attachedFileName.value}`,
        code: attachedFileContent.value,
        language: detectLanguageByFileName(attachedFileName.value),
        model: selectedModel.value,
      })
      answer = result?.answer || '代码分析完成。'
      clearAttachment()
    } else {
      const result = await sendChatMessage({
        user_id: currentUserId,
        session_id: currentSessionId,
        question,
        model: selectedModel.value,
      })
      answer = result?.answer || '收到。'
    }
    appendMessage('ASSISTANT', answer)
    inputText.value = ''
  } catch {
    appendMessage('ASSISTANT', '请求失败，请稍后重试。')
  } finally {
    isSending.value = false
  }
}

const renderMarkdown = (content) => marked.parse(content ?? '')
</script>

<style scoped>
.ai-chat-page {
  display: flex;
  height: calc(100vh - 140px);
  min-height: 560px;
  border: 1px solid #ebeef5;
  border-radius: 8px;
  overflow: hidden;
  background: #fff;
}

.history-panel {
  width: 14.2857%;
  min-width: 180px;
  border-right: 1px solid #ebeef5;
  display: flex;
  flex-direction: column;
  background: #fafafa;
}

.history-header {
  height: 56px;
  padding: 0 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  border-bottom: 1px solid #ebeef5;
}

.history-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
}

.history-item {
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  margin-bottom: 8px;
  border: 1px solid transparent;
}

.history-item:hover {
  background: #f0f7ff;
}

.history-item.active {
  background: #ecf5ff;
  border-color: #b3d8ff;
}

.history-item .title {
  font-size: 14px;
  color: #303133;
  line-height: 20px;
}

.history-item .time {
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
}

.chat-panel {
  width: 85.7143%;
  display: flex;
  flex-direction: column;
}

.message-list {
  flex: 1;
  padding: 16px;
  overflow-y: auto;
  background: #fff;
}

.message-row {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
}

.message-row.user {
  justify-content: flex-end;
}

.message-row.assistant {
  justify-content: flex-start;
}

.message-main {
  max-width: 70%;
}

.message-row.user .message-main {
  order: 2;
}

.message-row.user .message-actions {
  order: 1;
}

.bubble {
  line-height: 1.6;
  font-size: 14px;
  border-radius: 10px;
  padding: 10px 12px;
  white-space: pre-wrap;
}

.message-row.user .bubble {
  background: #409eff;
  color: #fff;
}

.message-row.assistant .bubble {
  background: #f4f4f5;
  color: #303133;
  white-space: normal;
}

:deep(.markdown-bubble p) {
  margin: 0 0 8px;
}

:deep(.markdown-bubble p:last-child) {
  margin-bottom: 0;
}

:deep(.markdown-bubble pre) {
  margin: 8px 0;
  padding: 10px 12px;
  border-radius: 8px;
  background: #1f2937;
  color: #f9fafb;
  overflow-x: auto;
  border: 1px solid #111827;
}

:deep(.markdown-bubble code) {
  font-family: Consolas, 'Courier New', monospace;
}

:deep(.markdown-bubble pre code) {
  display: block;
  background: transparent !important;
  color: inherit !important;
  padding: 0;
}

:deep(.markdown-bubble :not(pre) > code) {
  background: #e5e7eb;
  color: #111827;
  border-radius: 4px;
  padding: 1px 5px;
}

.message-actions {
  display: flex;
  gap: 6px;
  margin: 0 8px;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
}

.message-row:hover .message-actions {
  opacity: 1;
  pointer-events: auto;
}

:deep(.op-btn.el-button) {
  color: #c0c4cc;
  transition: color 0.2s ease, background-color 0.2s ease;
}

:deep(.op-btn.el-button:hover) {
  color: #409eff;
  background-color: #ecf5ff;
}

:deep(.op-btn .el-icon) {
  font-size: 16px;
}

.input-panel {
  border-top: 1px solid #ebeef5;
  padding: 12px;
  background: #fff;
}

.input-actions {
  margin-top: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.left-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.model-label {
  font-size: 13px;
  color: #606266;
}

.hidden-file-input {
  display: none;
}

.file-name {
  max-width: 220px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: #606266;
  font-size: 12px;
}

.right-actions {
  display: flex;
  gap: 8px;
}

.upload-tip-text {
  margin: 0 0 8px;
  color: #606266;
  line-height: 1.6;
}
</style>
