import { defineStore } from 'pinia'
import { ref } from 'vue'

/**
 * 当前浏览的知识点状态。
 * 知识点详情页 owner 可在此扩展字段，但不要移除已有字段。
 */
export const useKnowledgeStore = defineStore('knowledge', () => {
  const currentNode = ref(null)   // { id, name, module, difficulty }
  const currentModule = ref('')   // 当前所在模块，如 'linear-list'

  function setCurrentNode(node) {
    currentNode.value = node
  }

  function setCurrentModule(module) {
    currentModule.value = module
  }

  function clear() {
    currentNode.value = null
    currentModule.value = ''
  }

  return { currentNode, currentModule, setCurrentNode, setCurrentModule, clear }
})
