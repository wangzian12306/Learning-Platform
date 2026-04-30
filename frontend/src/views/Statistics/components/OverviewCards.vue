<template>
  <el-row :gutter="20">
    <el-col :span="6" v-for="(card, index) in cards" :key="index">
      <el-card shadow="hover" class="overview-card">
        <div class="card-content">
          <div class="card-icon">{{ card.icon }}</div>
          <div class="card-info">
            <div class="card-value">{{ card.value }}</div>
            <div class="card-label">{{ card.label }}</div>
          </div>
        </div>
      </el-card>
    </el-col>
  </el-row>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  data: {
    type: Object,
    default: () => ({})
  }
})

const cards = computed(() => [
  { icon: '📚', value: `${props.data.totalHours || 0} 小时`, label: '总学习时长' },
  { icon: '📖', value: `${props.data.learnedCount || 0}/${props.data.totalCount || 0}`, label: '已学知识点' },
  { icon: '✅', value: `${props.data.completedExercises || 0}/${props.data.totalExercises || 0}`, label: '已完成题目' },
  { icon: '🎯', value: `${props.data.correctRate || 0}%`, label: '平均正确率' }
])
</script>

<style scoped>
.overview-card {
  height: 120px;
  margin-bottom: 20px;
}

.card-content {
  display: flex;
  align-items: center;
  gap: 15px;
}

.card-icon {
  font-size: 40px;
}

.card-info {
  flex: 1;
}

.card-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.card-label {
  font-size: 14px;
  color: #909399;
}
</style>