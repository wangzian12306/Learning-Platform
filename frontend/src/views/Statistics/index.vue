<template>
  <div class="statistics-page">
    <el-container>
      <el-main>
        <!-- 学习概况卡片 -->
        <el-row :gutter="20" class="mb-20">
          <el-col :span="6">
            <el-card shadow="hover" class="overview-card">
              <div class="card-content">
                <div class="card-icon">📚</div>
                <div class="card-info">
                  <div class="card-value">{{ overview.totalHours }} 小时</div>
                  <div class="card-label">总学习时长</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card shadow="hover" class="overview-card">
              <div class="card-content">
                <div class="card-icon">📖</div>
                <div class="card-info">
                  <div class="card-value">{{ overview.learnedCount }}/{{ overview.totalCount }}</div>
                  <div class="card-label">已学知识点</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card shadow="hover" class="overview-card">
              <div class="card-content">
                <div class="card-icon">✅</div>
                <div class="card-info">
                  <div class="card-value">{{ overview.completedExercises }}/{{ overview.totalExercises }}</div>
                  <div class="card-label">已完成题目</div>
                </div>
              </div>
            </el-card>
          </el-col>
          <el-col :span="6">
            <el-card shadow="hover" class="overview-card">
              <div class="card-content">
                <div class="card-icon">🎯</div>
                <div class="card-info">
                  <div class="card-value">{{ overview.correctRate }}%</div>
                  <div class="card-label">平均正确率</div>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <!-- 学习进度和掌握度 -->
        <el-row :gutter="20" class="mb-20">
          <el-col :span="12">
            <el-card shadow="always">
              <template #header>
                <span>📊 学习进度分析</span>
              </template>
              <div ref="progressChartRef" class="chart-container"></div>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card shadow="always">
              <template #header>
                <span>🎯 知识点掌握情况</span>
              </template>
              <div ref="masteryChartRef" class="chart-container"></div>
            </el-card>
          </el-col>
        </el-row>

        <!-- 学习趋势和薄弱点 -->
        <el-row :gutter="20">
          <el-col :span="12">
            <el-card shadow="always">
              <template #header>
                <span>📈 学习趋势</span>
              </template>
              <div ref="trendChartRef" class="chart-container"></div>
            </el-card>
          </el-col>
          <el-col :span="12">
            <el-card shadow="always">
              <template #header>
                <span>⚠️ 薄弱知识点</span>
              </template>
              <el-table :data="weakPoints" style="width: 100%" :height="280">
                <el-table-column prop="name" label="知识点" />
                <el-table-column prop="module" label="模块" width="80" />
                <el-table-column prop="masteryLevel" label="掌握程度" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getMasteryTagType(row.masteryLevel)" size="small">
                      {{ row.masteryLevel }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="correctRate" label="正确率" width="80">
                  <template #default="{ row }">
                    {{ row.correctRate }}%
                  </template>
                </el-table-column>
              </el-table>
            </el-card>
          </el-col>
        </el-row>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'

// 概况数据（mock）
const overview = ref({
  totalHours: 12.5,
  learnedCount: 23,
  totalCount: 46,
  completedExercises: 45,
  totalExercises: 60,
  correctRate: 75
})

// 薄弱知识点（mock）
const weakPoints = ref([
  { name: '二叉树遍历', module: '树', masteryLevel: '未掌握', correctRate: 40 },
  { name: '快速排序', module: '排序', masteryLevel: '基本掌握', correctRate: 65 },
  { name: '图的遍历', module: '图', masteryLevel: '未掌握', correctRate: 50 },
  { name: '红黑树', module: '树', masteryLevel: '未掌握', correctRate: 35 }
])

// 图表引用
const progressChartRef = ref(null)
const masteryChartRef = ref(null)
const trendChartRef = ref(null)

// 获取掌握度标签类型
const getMasteryTagType = (level) => {
  const map = {
    '未掌握': 'danger',
    '基本掌握': 'warning',
    '掌握': 'success'
  }
  return map[level] || 'info'
}

// 初始化图表
const initCharts = () => {
  // 进度柱状图
  const progressChart = echarts.init(progressChartRef.value)
  progressChart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: ['集合', '线性表', '树', '图', '查找', '排序']
    },
    yAxis: {
      type: 'value',
      max: 100,
      axisLabel: { formatter: '{value}%' }
    },
    series: [{
      name: '知识点完成率',
      type: 'bar',
      data: [80, 60, 40, 50, 70, 65],
      itemStyle: { color: '#409EFF' }
    }, {
      name: '题目完成率',
      type: 'bar',
      data: [75, 55, 35, 45, 65, 60],
      itemStyle: { color: '#67C23A' }
    }]
  })

  // 掌握度雷达图
  const masteryChart = echarts.init(masteryChartRef.value)
  masteryChart.setOption({
    tooltip: {},
    radar: {
      indicator: [
        { name: '集合', max: 100 },
        { name: '线性表', max: 100 },
        { name: '树', max: 100 },
        { name: '图', max: 100 },
        { name: '查找', max: 100 },
        { name: '排序', max: 100 }
      ]
    },
    series: [{
      name: '掌握度',
      type: 'radar',
      data: [{
        value: [85, 70, 50, 60, 75, 68],
        name: '掌握度评分'
      }]
    }]
  })

  // 学习趋势折线图
  const trendChart = echarts.init(trendChartRef.value)
  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
    },
    yAxis: {
      type: 'value',
      axisLabel: { formatter: '{value}h' }
    },
    series: [{
      name: '学习时长',
      type: 'line',
      data: [1.5, 2.0, 1.0, 2.5, 3.0, 1.5, 2.0],
      smooth: true,
      itemStyle: { color: '#E6A23C' }
    }]
  })

  // 响应式调整
  window.addEventListener('resize', () => {
    progressChart.resize()
    masteryChart.resize()
    trendChart.resize()
  })
}

onMounted(() => {
  initCharts()
})
</script>

<style scoped>
.statistics-page {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 56px);
}

.mb-20 {
  margin-bottom: 20px;
}

.overview-card {
  height: 120px;
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

.chart-container {
  height: 300px;
  width: 100%;
}
</style>
