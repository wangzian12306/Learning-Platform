<template>
  <router-view />
</template>

<script setup>
import { onMounted } from 'vue'
import { useLearningStatsStore } from '@/stores/learningStats.js'
import { getKnowledgeTree } from '@/api/modules/knowledge.js'

const statsStore = useLearningStatsStore()

onMounted(async () => {
  try {
    const tree = await getKnowledgeTree()
    statsStore.buildModuleMap(tree)
  } catch (e) {
    console.warn('App: 加载知识点树失败:', e)
  }
})
</script>
