<template>
  <el-card shadow="always">
    <template #header>
      <span>📈 学习趋势</span>
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
  { date: '周一', hours: 1.5 },
  { date: '周二', hours: 2.0 },
  { date: '周三', hours: 1.0 },
  { date: '周四', hours: 2.5 },
  { date: '周五', hours: 3.0 },
  { date: '周六', hours: 1.5 },
  { date: '周日', hours: 2.0 }
]

const initChart = () => {
  const chart = echarts.init(chartRef.value)
  const chartData = props.data.length > 0 ? props.data : mockData
  
  chart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: chartData.map(item => item.date)
    },
    yAxis: {
      type: 'value',
      axisLabel: { formatter: '{value}h' }
    },
    series: [{
      name: '学习时长',
      type: 'line',
      data: chartData.map(item => item.hours),
      smooth: true,
      itemStyle: { color: '#E6A23C' },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(230, 162, 60, 0.3)' },
          { offset: 1, color: 'rgba(230, 162, 60, 0.1)' }
        ])
      }
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