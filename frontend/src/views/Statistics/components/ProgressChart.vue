<template>
  <el-card shadow="always">
    <template #header>
      <span>📊 学习进度分析</span>
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
  { module: '集合', knowledgeRate: 80, exerciseRate: 75 },
  { module: '线性表', knowledgeRate: 60, exerciseRate: 55 },
  { module: '树', knowledgeRate: 40, exerciseRate: 35 },
  { module: '图', knowledgeRate: 50, exerciseRate: 45 },
  { module: '查找', knowledgeRate: 70, exerciseRate: 65 },
  { module: '排序', knowledgeRate: 65, exerciseRate: 60 }
]

const initChart = () => {
  const chart = echarts.init(chartRef.value)
  const chartData = props.data.length > 0 ? props.data : mockData
  
  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['知识点完成率', '题目完成率'] },
    xAxis: {
      type: 'category',
      data: chartData.map(item => item.module)
    },
    yAxis: {
      type: 'value',
      max: 100,
      axisLabel: { formatter: '{value}%' }
    },
    series: [{
      name: '知识点完成率',
      type: 'bar',
      data: chartData.map(item => item.knowledgeRate),
      itemStyle: { color: '#409EFF' }
    }, {
      name: '题目完成率',
      type: 'bar',
      data: chartData.map(item => item.exerciseRate),
      itemStyle: { color: '#67C23A' }
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