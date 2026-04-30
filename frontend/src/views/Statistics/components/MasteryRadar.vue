<template>
  <el-card shadow="always">
    <template #header>
      <span>🎯 知识点掌握情况</span>
    </template>
    <div ref="chartRef" class="chart-container"></div>
  </el-card>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  data: {
    type: Array,
    default: () => []
  }
})

const chartRef = ref(null)

const mockData = [
  { name: '集合', score: 85 },
  { name: '线性表', score: 70 },
  { name: '树', score: 50 },
  { name: '图', score: 60 },
  { name: '查找', score: 75 },
  { name: '排序', score: 68 }
]

const initChart = () => {
  const chart = echarts.init(chartRef.value)
  const chartData = props.data.length > 0 ? props.data : mockData
  
  chart.setOption({
    tooltip: {},
    radar: {
      indicator: chartData.map(item => ({
        name: item.name,
        max: 100
      }))
    },
    series: [{
      name: '掌握度',
      type: 'radar',
      data: [{
        value: chartData.map(item => item.score),
        name: '掌握度评分'
      }]
    }]
  })

  window.addEventListener('resize', () => chart.resize())
}

onMounted(() => {
  initChart()
})

watch(() => props.data, () => {
  initChart()
}, { deep: true })
</script>

<style scoped>
.chart-container {
  height: 300px;
  width: 100%;
}
</style>