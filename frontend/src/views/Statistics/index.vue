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
                    <div class="card-value">{{ stats.totalStudyHours.toFixed(1) }} 小时</div>
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
                    <div class="card-value">{{ stats.learnedKnowledgeCount }}/{{ totalKnowledgeCount }}</div>
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
                    <div class="card-value">{{ stats.completedExerciseCount }}/{{ totalExerciseCount }}</div>
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
                    <div class="card-value">{{ stats.totalCorrectRate.toFixed(1) }}%</div>
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
                  <el-radio-group v-model="trendPeriod" size="small" style="float: right" @change="loadTrendData">
                    <el-radio-button label="day">一天</el-radio-button>
                    <el-radio-button label="week">一周</el-radio-button>
                    <el-radio-button label="month">一月</el-radio-button>
                  </el-radio-group>
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
                  <el-table-column prop="exerciseId" label="题号" width="70" />
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
                  <el-table-column prop="attempts" label="尝试次数" width="80" />
                  <el-table-column label="建议" width="100">
                    <template #default="{ row }">
                      <span v-if="row.masteryScore < 50" style="color: #F56C6C">{{ row.suggestion }}</span>
                      <span v-else-if="row.masteryScore < 70" style="color: #E6A23C">{{ row.suggestion }}</span>
                      <span v-else style="color: #67C23A">{{ row.suggestion }}</span>
                    </template>
                  </el-table-column>
                </el-table>
                <div v-if="weakPoints.length === 0" class="empty-hint">
                  <el-empty description="暂无薄弱点，继续保持！" :image-size="60" />
                </div>
              </el-card>
            </el-col>
          </el-row>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import * as echarts from 'echarts'
import { useLearningStatsStore } from '@/stores/learningStats.js'
import { getKnowledgeTree } from '@/api/modules/knowledge.js'
import { getExerciseList } from '@/api/modules/exercise.js'

const store = useLearningStatsStore()

const trendPeriod = ref('week')
const progressChartRef = ref(null)
const masteryChartRef = ref(null)
const trendChartRef = ref(null)

const totalKnowledgeCount = ref(0)
const totalExerciseCount = ref(0)
const moduleKnowledgeCounts = ref({})

const stats = computed(() => ({
  totalStudyHours: store.totalStudyHours,
  learnedKnowledgeCount: store.learnedKnowledgeCount,
  completedExerciseCount: store.completedExerciseCount,
  totalCorrectRate: store.totalCorrectRate,
}))

const weakPoints = computed(() => store.getWeakPoints(10))

function getMasteryTagType(level) {
  const map = { '未掌握': 'danger', '基本掌握': 'warning', '掌握': 'success', '未知': 'info' }
  return map[level] || 'info'
}

async function loadTotalCounts() {
  try {
    const tree = await getKnowledgeTree()
    function countNodes(nodes) {
      if (!nodes) return 0
      let count = 0
      nodes.forEach(n => {
        if (n.id) count++
        if (n.children) count += countNodes(n.children)
      })
      return count
    }
    totalKnowledgeCount.value = countNodes(tree)

    store.buildModuleMap(tree)

    const counts = {}
    if (Array.isArray(tree)) {
      tree.forEach(mod => {
        const name = mod.name || ''
        counts[name] = countNodes([mod])
      })
    }
    moduleKnowledgeCounts.value = counts
  } catch (e) {
    totalKnowledgeCount.value = 30
  }

  try {
    const res = await getExerciseList(null, { page: 1, pageSize: 1 })
    totalExerciseCount.value = res?.total || 0
  } catch (e) {
    totalExerciseCount.value = 0
  }
}

function initProgressChart() {
  if (!progressChartRef.value) return
  const chart = echarts.init(progressChartRef.value)
  const chartData = store.getProgressByModule(moduleKnowledgeCounts.value)

  chart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['知识点完成率', '题目正确率'] },
    xAxis: {
      type: 'category',
      data: chartData.map(item => item.module),
    },
    yAxis: {
      type: 'value',
      max: 100,
      axisLabel: { formatter: '{value}%' },
    },
    series: [{
      name: '知识点完成率',
      type: 'bar',
      data: chartData.map(item => item.knowledgeRate),
      itemStyle: { color: '#409EFF' },
    }, {
      name: '题目正确率',
      type: 'bar',
      data: chartData.map(item => item.exerciseRate),
      itemStyle: { color: '#67C23A' },
    }],
  })

  window.addEventListener('resize', () => chart.resize())
}

function initMasteryChart() {
  if (!masteryChartRef.value) return
  const chart = echarts.init(masteryChartRef.value)
  const chartData = store.getMasteryByModule()

  chart.setOption({
    tooltip: {},
    radar: {
      indicator: chartData.map(item => ({ name: item.module, max: 100 })),
    },
    series: [{
      name: '掌握度',
      type: 'radar',
      data: [{ value: chartData.map(item => item.score), name: '掌握度评分' }],
    }],
  })

  window.addEventListener('resize', () => chart.resize())
}

function initTrendChart() {
  if (!trendChartRef.value) return
  const chart = echarts.init(trendChartRef.value)
  const chartData = store.getTrendData(trendPeriod.value)

  const isDay = trendPeriod.value === 'day'
  const isMonth = trendPeriod.value === 'month'

  chart.setOption({
    tooltip: {
      trigger: 'axis',
      formatter: (params) => {
        const p = params[0]
        if (isDay) {
          return `${p.name}<br/>学习时长: ${p.value > 0 ? p.value.toFixed(2) : 0} 小时`
        }
        return `${p.name}<br/>学习时长: ${p.value > 0 ? p.value.toFixed(2) : 0} 小时`
      },
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: isMonth ? '12%' : '3%',
      containLabel: true,
    },
    xAxis: {
      type: 'category',
      data: chartData.map(item => item.date),
      axisLabel: {
        rotate: isMonth ? 45 : 0,
        interval: isMonth ? 2 : 'auto',
      },
    },
    yAxis: {
      type: 'value',
      axisLabel: { formatter: '{value}h' },
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
          { offset: 1, color: 'rgba(230, 162, 60, 0.1)' },
        ]),
      },
    }],
  })

  window.addEventListener('resize', () => chart.resize())
}

function loadTrendData() {
  nextTick(() => initTrendChart())
}

onMounted(async () => {
  await loadTotalCounts()
  await nextTick()
  initProgressChart()
  initMasteryChart()
  initTrendChart()
})
</script>

<style scoped>
.statistics-page {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 56px);
}
.mb-20 { margin-bottom: 20px; }
.overview-card { height: 120px; }
.card-content { display: flex; align-items: center; gap: 15px; }
.card-icon { font-size: 40px; }
.card-info { flex: 1; }
.card-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}
.card-label { font-size: 14px; color: #909399; }
.chart-container { height: 300px; width: 100%; }
.empty-hint { padding: 10px 0; }
</style>
