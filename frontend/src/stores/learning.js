import { defineStore } from 'pinia'
import { ref } from 'vue'

/**
 * 学习进度全局状态。
 * 学习跟踪模块 owner 可在此扩展，但字段语义需与后端 learning_progress 表对齐。
 */
export const useLearningStore = defineStore('learning', () => {
  // Map<knowledgePointId, 'not_started' | 'in_progress' | 'completed'>
  const progressMap = ref({})

  function setProgress(nodeId, status) {
    progressMap.value[nodeId] = status
  }

  function getProgress(nodeId) {
    return progressMap.value[nodeId] ?? 'not_started'
  }

  function loadProgressMap(map) {
    progressMap.value = { ...map }
  }

  return { progressMap, setProgress, getProgress, loadProgressMap }
})
