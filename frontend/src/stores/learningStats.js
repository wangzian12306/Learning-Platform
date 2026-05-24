import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const STORAGE_KEY = 'learning_stats_data'

const MODULE_NAMES = {
  set: '集合', 'linear-list': '线性表', ll: '线性表',
  tree: '树', graph: '图', search: '查找', sort: '排序',
}

function todayKey() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function loadFromStorage() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) return JSON.parse(raw)
  } catch (e) { /* ignore */ }
  return null
}

function saveToStorage(data) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
  } catch (e) { /* ignore */ }
}

function createEmptyState() {
  return {
    knowledgeVisits: {},
    dailyStudySeconds: {},
    exerciseRecords: {},
  }
}

export const useLearningStatsStore = defineStore('learningStats', () => {
  const raw = ref(loadFromStorage() || createEmptyState())
  const knowledgePointModuleMap = ref({})

  function persist() {
    saveToStorage(raw.value)
  }

  const knowledgeVisits = computed(() => raw.value.knowledgeVisits || {})
  const dailyStudySeconds = computed(() => raw.value.dailyStudySeconds || {})
  const exerciseRecords = computed(() => raw.value.exerciseRecords || {})

  function buildModuleMap(tree) {
    if (!Array.isArray(tree)) return
    const map = {}
    function walk(nodes, parentModuleName) {
      if (!nodes) return
      nodes.forEach(n => {
        if (n.id != null) {
          const moduleName = n.children ? (n.name || parentModuleName) : parentModuleName
          map[String(n.id)] = moduleName
        }
        if (n.children) walk(n.children, n.name || parentModuleName)
      })
    }
    walk(tree, '')
    knowledgePointModuleMap.value = map
  }

  function getModuleForKnowledgePoint(knowledgePointId) {
    const key = String(knowledgePointId)
    const visit = raw.value.knowledgeVisits[key]
    if (visit && visit.module) {
      return MODULE_NAMES[visit.module] || visit.module
    }
    if (knowledgePointModuleMap.value[key]) {
      return knowledgePointModuleMap.value[key]
    }
    return '未知'
  }

  function recordKnowledgeVisit(knowledgePointId, module) {
    const key = String(knowledgePointId)
    if (!raw.value.knowledgeVisits[key]) {
      raw.value.knowledgeVisits[key] = { firstVisit: Date.now(), lastVisit: Date.now(), totalSeconds: 0, module: module || '' }
    } else {
      raw.value.knowledgeVisits[key].lastVisit = Date.now()
      raw.value.knowledgeVisits[key].module = module || raw.value.knowledgeVisits[key].module
    }
    persist()
  }

  function addStudyTime(knowledgePointId, seconds) {
    const key = String(knowledgePointId)
    const day = todayKey()

    if (!raw.value.dailyStudySeconds[day]) {
      raw.value.dailyStudySeconds[day] = 0
    }
    raw.value.dailyStudySeconds[day] += seconds

    if (raw.value.knowledgeVisits[key]) {
      raw.value.knowledgeVisits[key].totalSeconds += seconds
    }
    persist()
  }

  function recordExerciseResult(exerciseId, knowledgePointId, exerciseType, isCorrect, userAnswer) {
    const key = String(exerciseId)
    if (!raw.value.exerciseRecords[key]) {
      raw.value.exerciseRecords[key] = {
        exerciseId,
        knowledgePointId,
        exerciseType,
        attempts: 0,
        correctCount: 0,
        lastAnswer: null,
        lastCorrect: null,
        lastTime: null,
      }
    }
    const rec = raw.value.exerciseRecords[key]
    rec.attempts += 1
    if (isCorrect) rec.correctCount += 1
    rec.lastAnswer = userAnswer
    rec.lastCorrect = isCorrect
    rec.lastTime = Date.now()
    rec.knowledgePointId = knowledgePointId || rec.knowledgePointId
    rec.exerciseType = exerciseType || rec.exerciseType
    persist()
  }

  const totalStudyHours = computed(() => {
    let totalSec = 0
    for (const day in raw.value.dailyStudySeconds) {
      totalSec += raw.value.dailyStudySeconds[day]
    }
    return totalSec / 3600
  })

  const learnedKnowledgeCount = computed(() => {
    return Object.keys(raw.value.knowledgeVisits).length
  })

  const completedExerciseCount = computed(() => {
    return Object.keys(raw.value.exerciseRecords).length
  })

  const totalCorrectRate = computed(() => {
    let attempts = 0
    let correct = 0
    for (const key in raw.value.exerciseRecords) {
      const rec = raw.value.exerciseRecords[key]
      attempts += rec.attempts
      correct += rec.correctCount
    }
    return attempts > 0 ? (correct / attempts) * 100 : 0
  })

  function getModuleStats(moduleKey) {
    const moduleName = MODULE_NAMES[moduleKey] || moduleKey
    let visitedCount = 0
    let studySeconds = 0
    let exerciseAttempts = 0
    let exerciseCorrect = 0
    let exerciseDone = 0

    for (const kid in raw.value.knowledgeVisits) {
      const v = raw.value.knowledgeVisits[kid]
      if (v.module === moduleKey || v.module === moduleName) {
        visitedCount++
        studySeconds += v.totalSeconds
      }
    }

    for (const eid in raw.value.exerciseRecords) {
      const rec = raw.value.exerciseRecords[eid]
      const mod = getModuleForKnowledgePoint(rec.knowledgePointId)
      if (mod === moduleName) {
        exerciseAttempts += rec.attempts
        exerciseCorrect += rec.correctCount
        exerciseDone++
      }
    }

    return {
      module: moduleName,
      visitedCount,
      studyHours: studySeconds / 3600,
      exerciseDone,
      exerciseAttempts,
      exerciseCorrect,
      exerciseRate: exerciseAttempts > 0 ? (exerciseCorrect / exerciseAttempts) * 100 : 0,
    }
  }

  function getTrendData(days = 7) {
    const result = []
    const now = new Date()
    for (let i = days - 1; i >= 0; i--) {
      const d = new Date(now)
      d.setDate(d.getDate() - i)
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
      result.push({
        date: key.slice(5),
        hours: ((raw.value.dailyStudySeconds[key] || 0) / 3600),
      })
    }
    return result
  }

  function getWeakPoints(limit = 10) {
    const points = []
    for (const eid in raw.value.exerciseRecords) {
      const rec = raw.value.exerciseRecords[eid]
      if (rec.attempts > 0) {
        const rate = (rec.correctCount / rec.attempts) * 100
        if (rate < 80) {
          points.push({
            exerciseId: rec.exerciseId,
            knowledgePointId: rec.knowledgePointId,
            module: getModuleForKnowledgePoint(rec.knowledgePointId),
            attempts: rec.attempts,
            correctCount: rec.correctCount,
            correctRate: Math.round(rate),
            masteryScore: Math.round(rate),
            masteryLevel: rate < 50 ? '未掌握' : rate < 70 ? '基本掌握' : '掌握',
            suggestion: rate < 50 ? '建议复习' : '继续练习',
          })
        }
      }
    }
    points.sort((a, b) => a.correctRate - b.correctRate)
    return points.slice(0, limit)
  }

  function getProgressByModule(totalKnowledgeByModule) {
    const modules = ['集合', '线性表', '树', '图', '查找', '排序']
    return modules.map(m => {
      let visited = 0
      let exerciseDone = 0
      let exerciseAttempts = 0
      let exerciseCorrect = 0

      for (const kid in raw.value.knowledgeVisits) {
        const v = raw.value.knowledgeVisits[kid]
        if (v.module === m) visited++
      }
      for (const eid in raw.value.exerciseRecords) {
        const rec = raw.value.exerciseRecords[eid]
        const mod = getModuleForKnowledgePoint(rec.knowledgePointId)
        if (mod === m) {
          exerciseDone++
          exerciseAttempts += rec.attempts
          exerciseCorrect += rec.correctCount
        }
      }

      const total = totalKnowledgeByModule?.[m] || 5
      return {
        module: m,
        knowledgeRate: Math.round((visited / total) * 100),
        exerciseRate: exerciseAttempts > 0 ? Math.round((exerciseCorrect / exerciseAttempts) * 100) : 0,
      }
    })
  }

  function getMasteryByModule() {
    const modules = ['集合', '线性表', '树', '图', '查找', '排序']
    return modules.map(m => {
      let attempts = 0
      let correct = 0
      let visited = 0

      for (const kid in raw.value.knowledgeVisits) {
        if (raw.value.knowledgeVisits[kid].module === m) visited++
      }
      for (const eid in raw.value.exerciseRecords) {
        const rec = raw.value.exerciseRecords[eid]
        const mod = getModuleForKnowledgePoint(rec.knowledgePointId)
        if (mod === m) {
          attempts += rec.attempts
          correct += rec.correctCount
        }
      }

      let score = 0
      if (attempts > 0) {
        score = Math.round((correct / attempts) * 70)
      }
      if (visited > 0) {
        score += Math.min(30, visited * 10)
      }
      score = Math.min(100, score)

      return { module: m, score }
    })
  }

  function clearAll() {
    raw.value = createEmptyState()
    persist()
  }

  return {
    raw,
    knowledgeVisits,
    dailyStudySeconds,
    exerciseRecords,
    knowledgePointModuleMap,
    buildModuleMap,
    getModuleForKnowledgePoint,
    recordKnowledgeVisit,
    addStudyTime,
    recordExerciseResult,
    totalStudyHours,
    learnedKnowledgeCount,
    completedExerciseCount,
    totalCorrectRate,
    getModuleStats,
    getTrendData,
    getWeakPoints,
    getProgressByModule,
    getMasteryByModule,
    clearAll,
    persist,
  }
})
