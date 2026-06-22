<template>
  <div class="video-page">
    <section class="page-header">
      <div>
        <h1>视频讲解</h1>
        <p>按知识点查看配套讲解视频，并自动记录观看进度。</p>
      </div>
      <el-button :icon="Refresh" :loading="loading" @click="fetchVideoList">刷新</el-button>
    </section>

    <section class="toolbar">
      <el-form :inline="true" @submit.prevent>
        <el-form-item label="知识点 ID">
          <el-input-number
            v-model="filter.knowledgeId"
            :min="1"
            :controls="false"
            placeholder="全部"
            class="knowledge-input"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :icon="Search" @click="fetchVideoList">筛选</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </section>

    <section class="video-workspace" v-loading="loading">
      <aside class="video-list">
        <div class="list-header">
          <span>视频列表</span>
          <el-tag size="small" effect="plain">{{ videos.length }} 个</el-tag>
        </div>

        <el-empty v-if="!loading && videos.length === 0" description="暂无视频数据" />

        <button
          v-for="item in videos"
          :key="item.id"
          class="video-item"
          :class="{ active: selectedVideo?.id === item.id }"
          type="button"
          @click="selectVideo(item)"
        >
          <span class="video-title">{{ item.title }}</span>
          <span class="video-meta">
            {{ item.knowledgePointName || '未命名知识点' }}
            <el-tag
              v-if="item.knowledgePointDifficulty"
              class="meta-tag"
              :type="difficultyType(item.knowledgePointDifficulty)"
              size="small"
              effect="plain"
            >
              {{ difficultyLabel(item.knowledgePointDifficulty) }}
            </el-tag>
            <template v-if="item.duration"> · {{ formatDuration(item.duration) }}</template>
          </span>
        </button>
      </aside>

      <main class="player-panel">
        <template v-if="selectedVideo">
          <div class="player-header">
            <div>
              <h2>{{ selectedVideo.title }}</h2>
              <p>{{ selectedVideo.description || '暂无视频说明' }}</p>
            </div>
            <div class="player-actions">
              <el-button
                v-if="selectedVideo.neo4jId"
                type="primary"
                plain
                size="small"
                @click="openGraphNode"
              >
                查看图谱节点
              </el-button>
              <el-tag :type="watchState.isCompleted ? 'success' : 'info'" effect="plain">
                {{ watchState.isCompleted ? '已完成' : '学习中' }}
              </el-tag>
            </div>
          </div>

          <video
            v-if="isNativeVideo"
            ref="videoRef"
            class="video-player"
            :src="selectedVideo.videoUrl"
            :poster="selectedVideo.thumbnailUrl || undefined"
            controls
            preload="metadata"
            @loadedmetadata="handleLoadedMetadata"
            @timeupdate="handleTimeUpdate"
            @pause="flushProgress"
            @ended="handleEnded"
          />

          <iframe
            v-else-if="embedUrl"
            class="video-player"
            :src="embedUrl"
            title="教学视频播放器"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
            allowfullscreen
          />

          <div v-else class="external-video">
            <p>当前视频平台不支持站内嵌入播放。</p>
            <el-button type="primary" tag="a" :href="selectedVideo.videoUrl" target="_blank" rel="noopener">
              打开原视频
            </el-button>
          </div>

          <div class="progress-panel">
            <div class="progress-copy">
              <span>观看进度</span>
              <strong>{{ watchState.watchProgress }}%</strong>
            </div>
            <el-progress
              :percentage="watchState.watchProgress"
              :status="watchState.isCompleted ? 'success' : undefined"
            />
            <div class="watch-meta">
              <span>已观看 {{ formatDuration(watchState.watchDuration) }}</span>
              <span v-if="watchState.lastWatchTime">上次观看 {{ formatTime(watchState.lastWatchTime) }}</span>
            </div>
            <el-button
              v-if="!isNativeVideo"
              class="complete-button"
              type="success"
              plain
              :disabled="Boolean(watchState.isCompleted)"
              @click="markEmbeddedCompleted"
            >
              {{ watchState.isCompleted ? '已标记完成' : '标记为已完成' }}
            </el-button>
          </div>

          <section class="resource-section" v-if="recommendedVideos.length">
            <div class="resource-header">
              <h3>图谱推荐视频</h3>
              <span>来自当前知识点及相邻图谱节点</span>
            </div>
            <div class="resource-list">
              <button
                v-for="item in recommendedVideos"
                :key="item.id"
                class="resource-item"
                type="button"
                @click="selectVideo(item)"
              >
                <span>{{ item.title }}</span>
                <small>{{ item.knowledgePointName || '相关知识点' }}</small>
              </button>
            </div>
          </section>

          <section class="resource-section" v-if="relatedExercises.length">
            <div class="resource-header">
              <h3>配套习题</h3>
              <span>看完视频后可直接练习</span>
            </div>
            <div class="resource-list">
              <button
                v-for="item in relatedExercises"
                :key="item.id"
                class="resource-item"
                type="button"
                @click="openExercise(item)"
              >
                <span>{{ item.title }}</span>
                <small>{{ exerciseTypeLabel(item.type) }} · {{ difficultyLabel(item.difficulty) }}</small>
              </button>
            </div>
          </section>
        </template>

        <el-empty v-else description="请选择一个视频开始学习" />
      </main>
    </section>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Refresh, Search } from '@element-plus/icons-vue'
import { getRecommendedVideos, getVideoList, getWatchRecord, saveWatchProgress } from '@/api/modules/video.js'
import { getExercisesByKnowledge } from '@/api/modules/exercise.js'

const loading = ref(false)
const videos = ref([])
const selectedVideo = ref(null)
const recommendedVideos = ref([])
const relatedExercises = ref([])
const videoRef = ref(null)
const pendingResumeSeconds = ref(null)
const lastReportAt = ref(0)
const embeddedTimer = ref(null)
const embeddedLastReportAt = ref(0)
const router = useRouter()
const route = useRoute()

const filter = reactive({
  knowledgeId: undefined,
})

const embedUrl = computed(() => buildEmbedUrl(selectedVideo.value?.videoUrl))
const isNativeVideo = computed(() => isDirectVideoUrl(selectedVideo.value?.videoUrl))

const watchState = reactive({
  watchProgress: 0,
  watchDuration: 0,
  lastWatchTime: '',
  isCompleted: 0,
})

const fetchVideoList = async () => {
  loading.value = true
  try {
    const list = await getVideoList(filter.knowledgeId)
    videos.value = Array.isArray(list) ? list : []
    if (videos.value.length === 0) {
      selectedVideo.value = null
      resetWatchState()
      return
    }
    const routeVideoId = Number(route.query.videoId)
    const routeVideo = Number.isFinite(routeVideoId)
      ? videos.value.find((item) => item.id === routeVideoId)
      : null
    if (routeVideo) {
      await selectVideo(routeVideo)
    } else if (!selectedVideo.value || !videos.value.some((item) => item.id === selectedVideo.value.id)) {
      await selectVideo(videos.value[0])
    }
  } catch (error) {
    videos.value = []
    selectedVideo.value = null
    resetWatchState()
    console.error('Failed to load video list', error)
  } finally {
    loading.value = false
  }
}

const selectVideo = async (video) => {
  stopEmbeddedTracking()
  selectedVideo.value = video
  resetWatchState()
  recommendedVideos.value = []
  relatedExercises.value = []
  pendingResumeSeconds.value = null

  try {
    const record = await getWatchRecord(video.id)
    applyWatchRecord(record)
    pendingResumeSeconds.value = watchState.watchDuration
    await nextTick()
    if (isNativeVideo.value) {
      handleLoadedMetadata()
    } else {
      startEmbeddedTracking()
    }
  } catch (error) {
    console.error('Failed to load watch record', error)
    if (!isNativeVideo.value) {
      startEmbeddedTracking()
    }
  }

  fetchRelatedResources(video)
}

const resetFilter = () => {
  filter.knowledgeId = undefined
  fetchVideoList()
}

const openGraphNode = () => {
  if (!selectedVideo.value?.neo4jId) return
  router.push({
    name: 'Graph',
    query: { node: selectedVideo.value.neo4jId },
  })
}

const fetchRelatedResources = async (video) => {
  try {
    const [videos, exercises] = await Promise.all([
      getRecommendedVideos(video.id),
      video.knowledgePointId ? getExercisesByKnowledge(video.knowledgePointId) : Promise.resolve([]),
    ])
    recommendedVideos.value = Array.isArray(videos) ? videos : []
    relatedExercises.value = Array.isArray(exercises) ? exercises.slice(0, 6) : []
  } catch (error) {
    console.error('Failed to load related resources', error)
  }
}

const openExercise = (exercise) => {
  if (!exercise?.id) return
  if (['SINGLE_CHOICE', 'MULTIPLE_CHOICE'].includes(exercise.type)) {
    router.push({ path: `/exercise/choice/${exercise.id}` })
    return
  }
  if (exercise.type === 'FILL_BLANK') {
    router.push({ path: `/exercise/fill/${exercise.id}` })
    return
  }
  router.push({ path: `/exercise/${exercise.id}` })
}

const resetWatchState = () => {
  watchState.watchProgress = 0
  watchState.watchDuration = 0
  watchState.lastWatchTime = ''
  watchState.isCompleted = 0
}

const applyWatchRecord = (record) => {
  if (!record) return
  watchState.watchProgress = clampProgress(record.watchProgress || 0)
  watchState.watchDuration = record.watchDuration || 0
  watchState.lastWatchTime = record.lastWatchTime || ''
  watchState.isCompleted = record.isCompleted || 0
}

const handleLoadedMetadata = () => {
  const player = videoRef.value
  if (!player || pendingResumeSeconds.value === null || pendingResumeSeconds.value <= 0) return

  const duration = Number.isFinite(player.duration) ? player.duration : selectedVideo.value?.duration
  if (duration > 0 && watchState.watchProgress < 100) {
    player.currentTime = Math.min(Math.max(0, duration - 0.2), pendingResumeSeconds.value)
  }
  pendingResumeSeconds.value = null
}

const handleTimeUpdate = () => {
  const player = videoRef.value
  if (!player || !selectedVideo.value) return

  syncLocalProgress()
  const now = Date.now()
  if (now - lastReportAt.value > 10000) {
    lastReportAt.value = now
    reportProgress(false)
  }
}

const handleEnded = () => {
  watchState.watchProgress = 100
  watchState.isCompleted = 1
  syncLocalProgress()
  reportProgress(true)
}

const flushProgress = () => {
  if (!isNativeVideo.value) return
  syncLocalProgress()
  reportProgress(true)
}

const markEmbeddedCompleted = () => {
  if (!selectedVideo.value) return
  watchState.watchProgress = 100
  watchState.watchDuration = selectedVideo.value.duration || watchState.watchDuration || 0
  watchState.isCompleted = 1
  reportProgress(true)
}

const startEmbeddedTracking = () => {
  stopEmbeddedTracking()
  embeddedLastReportAt.value = Date.now()
  embeddedTimer.value = window.setInterval(() => {
    if (!selectedVideo.value || isNativeVideo.value || watchState.isCompleted) return

    watchState.watchDuration += 1
    if (selectedVideo.value.duration) {
      watchState.watchProgress = clampProgress(Math.floor((watchState.watchDuration / selectedVideo.value.duration) * 100))
    }

    const now = Date.now()
    if (now - embeddedLastReportAt.value > 10000) {
      embeddedLastReportAt.value = now
      reportProgress(false)
    }
  }, 1000)
}

const stopEmbeddedTracking = () => {
  if (embeddedTimer.value) {
    window.clearInterval(embeddedTimer.value)
    embeddedTimer.value = null
  }
}

const syncLocalProgress = () => {
  const player = videoRef.value
  if (!player) return

  const duration = Number.isFinite(player.duration) && player.duration > 0
    ? player.duration
    : selectedVideo.value?.duration

  watchState.watchDuration = Math.max(0, Math.round(player.currentTime || 0))
  if (duration > 0) {
    watchState.watchProgress = clampProgress(Math.floor((watchState.watchDuration / duration) * 100))
  }
  if (watchState.watchProgress >= 95) {
    watchState.isCompleted = 1
  }
}

const reportProgress = async (showError) => {
  if (!selectedVideo.value) return

  try {
    const record = await saveWatchProgress({
      videoId: selectedVideo.value.id,
      watchProgress: watchState.watchProgress,
      watchDuration: watchState.watchDuration,
    })
    applyWatchRecord(record)
  } catch (error) {
    console.error('Failed to save watch progress', error)
    if (showError) {
      ElMessage.error('观看进度保存失败')
    }
  }
}

const clampProgress = (value) => Math.max(0, Math.min(100, Number(value) || 0))

const formatDuration = (seconds) => {
  const total = Math.max(0, Number(seconds) || 0)
  const minute = Math.floor(total / 60)
  const second = total % 60
  return `${minute}:${String(second).padStart(2, '0')}`
}

const formatTime = (time) => {
  if (!time) return ''
  return new Date(time).toLocaleString()
}

const difficultyLabel = (difficulty) => {
  const map = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }
  return map[difficulty] || difficulty || '未知'
}

const difficultyType = (difficulty) => {
  const map = { EASY: 'success', MEDIUM: 'warning', HARD: 'danger' }
  return map[difficulty] || 'info'
}

const exerciseTypeLabel = (type) => {
  const map = {
    SINGLE_CHOICE: '单选题',
    MULTIPLE_CHOICE: '多选题',
    FILL_BLANK: '填空题',
    PROGRAMMING: '编程题',
  }
  return map[type] || type || '习题'
}

const isDirectVideoUrl = (url) => {
  if (!url) return false
  return /\.(mp4|webm|ogg)(\.download)?(\?.*)?$/i.test(url)
}

const buildEmbedUrl = (url) => {
  if (!url) return ''
  const bilibiliMatch = url.match(/bilibili\.com\/video\/(BV[0-9A-Za-z]+)/i)
  if (bilibiliMatch) {
    return `https://player.bilibili.com/player.html?bvid=${bilibiliMatch[1]}&page=1&high_quality=1&autoplay=0`
  }

  const youtubeMatch = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([0-9A-Za-z_-]+)/i)
  if (youtubeMatch) {
    return `https://www.youtube.com/embed/${youtubeMatch[1]}`
  }

  return ''
}

onMounted(fetchVideoList)
watch(
  () => route.query.videoId,
  async (videoId) => {
    const targetId = Number(videoId)
    if (!Number.isFinite(targetId) || videos.value.length === 0) return
    const target = videos.value.find((item) => item.id === targetId)
    if (target && selectedVideo.value?.id !== target.id) {
      await selectVideo(target)
    }
  },
)
onBeforeUnmount(() => {
  flushProgress()
  if (!isNativeVideo.value && selectedVideo.value) {
    reportProgress(false)
  }
  stopEmbeddedTracking()
})
</script>

<style scoped>
.video-page {
  min-height: 100%;
  padding: 24px;
  color: #1f2937;
  background: #f6f7fb;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}

.page-header h1 {
  margin: 0 0 6px;
  font-size: 26px;
  font-weight: 700;
}

.page-header p {
  margin: 0;
  color: #667085;
}

.toolbar {
  padding: 16px;
  margin-bottom: 16px;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}

.knowledge-input {
  width: 180px;
}

.video-workspace {
  display: grid;
  grid-template-columns: minmax(260px, 340px) minmax(0, 1fr);
  gap: 16px;
  min-height: 540px;
}

.video-list,
.player-panel {
  min-width: 0;
  background: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
}

.video-list {
  padding: 12px;
  overflow: auto;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 4px 12px;
  color: #344054;
  font-weight: 600;
}

.video-item {
  display: block;
  width: 100%;
  padding: 12px;
  margin-bottom: 8px;
  text-align: left;
  background: #ffffff;
  border: 1px solid #edf0f5;
  border-radius: 8px;
  cursor: pointer;
  transition: border-color 0.2s ease, background 0.2s ease;
}

.video-item:hover,
.video-item.active {
  background: #eef5ff;
  border-color: #409eff;
}

.video-title {
  display: block;
  margin-bottom: 6px;
  color: #101828;
  font-size: 15px;
  font-weight: 600;
}

.video-meta {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
  color: #667085;
  font-size: 13px;
}

.meta-tag {
  height: 20px;
}

.player-panel {
  padding: 18px;
  display: flex;
  flex-direction: column;
}

.player-header {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 16px;
}

.player-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.player-header h2 {
  margin: 0 0 6px;
  font-size: 22px;
}

.player-header p {
  margin: 0;
  color: #667085;
  line-height: 1.6;
}

.video-player {
  width: 100%;
  aspect-ratio: 16 / 9;
  background: #111827;
  border: 0;
  border-radius: 8px;
}

.external-video {
  display: grid;
  place-items: center;
  gap: 12px;
  width: 100%;
  aspect-ratio: 16 / 9;
  color: #667085;
  background: #111827;
  border-radius: 8px;
}

.progress-panel {
  padding-top: 16px;
}

.progress-copy,
.watch-meta {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 8px;
  color: #667085;
  font-size: 13px;
}

.progress-copy strong {
  color: #101828;
}

.watch-meta {
  margin-top: 8px;
  margin-bottom: 0;
}

.complete-button {
  margin-top: 12px;
}

.resource-section {
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px solid #edf0f5;
}

.resource-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 10px;
}

.resource-header h3 {
  margin: 0;
  color: #101828;
  font-size: 16px;
}

.resource-header span {
  color: #98a2b3;
  font-size: 12px;
}

.resource-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 8px;
}

.resource-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-height: 66px;
  padding: 10px 12px;
  text-align: left;
  background: #ffffff;
  border: 1px solid #edf0f5;
  border-radius: 8px;
  cursor: pointer;
}

.resource-item:hover {
  border-color: #409eff;
  background: #f7fbff;
}

.resource-item span {
  color: #101828;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.35;
}

.resource-item small {
  color: #667085;
  font-size: 12px;
}

@media (max-width: 900px) {
  .video-page {
    padding: 16px;
  }

  .page-header,
  .player-header,
  .progress-copy,
  .watch-meta {
    flex-direction: column;
  }

  .video-workspace {
    grid-template-columns: 1fr;
  }
}
</style>
