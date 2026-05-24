<template>
  <div class="node-detail" v-if="node">
    <div class="detail-header">
      <div class="header-top">
        <h3 class="node-name">{{ node.name }}</h3>
        <div class="header-actions">
          <el-button type="primary" size="small" @click="goToLearning">
            查看学习内容
          </el-button>
          <el-button :icon="Close" circle size="small" @click="$emit('close')" />
        </div>
      </div>
      <div class="node-tags">
        <el-tag :type="diffType" size="small">{{ diffLabel }}</el-tag>
        <el-tag type="info" size="small">{{ moduleLabel }}</el-tag>
        <el-tag size="small" effect="plain">Level {{ node.level }}</el-tag>
      </div>
    </div>

    <el-divider />

    <div class="detail-body">
      <div class="section">
        <div class="section-title">编号</div>
        <div class="section-content code-text">{{ node.code }}</div>
      </div>

      <div class="section">
        <div class="section-title">简介</div>
        <div class="section-content">{{ node.description }}</div>
      </div>

      <div class="section" v-if="node.corePoints">
        <div class="section-title">核心考点</div>
        <div class="section-content">
          <el-tag
            v-for="point in corePointList"
            :key="point"
            size="small"
            effect="plain"
            class="point-tag"
          >
            {{ point }}
          </el-tag>
        </div>
      </div>

      <div class="section" v-if="node.relatedNodes?.length">
        <div class="section-title">关联知识点</div>
        <div class="section-content">
          <div
            v-for="rel in node.relatedNodes"
            :key="rel.id"
            class="related-item"
            @click="$emit('node-click', rel.id)"
          >
            <span class="related-name">{{ rel.name }}</span>
            <span class="related-type">{{ rel.relationType === 'PARENT_OF' ? '包含' : '关联' }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="node-detail empty" v-else>
    <el-empty description="点击图谱中的节点查看详情" :image-size="80" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { Close } from '@element-plus/icons-vue'
import { getKnowledgeTree } from '@/api/modules/knowledge.js'

const props = defineProps({
  node: { type: Object, default: null },
  allEdges: { type: Array, default: () => [] },
  allNodes: { type: Array, default: () => [] },
})

const emit = defineEmits(['close', 'node-click'])

const router = useRouter()

const moduleRouteMap = {
  SET: 'set', LINEAR_LIST: 'linear-list', TREE: 'tree',
  GRAPH: 'graph', SEARCH: 'search', SORT: 'sort',
}

async function goToLearning() {
  if (!props.node) return

  const routeModule = moduleRouteMap[props.node.module] || props.node.module?.toLowerCase() || ''

  const codesToTry = [props.node.code]
  const namesToTry = [props.node.name]

  const parentMap = {}
  for (const e of props.allEdges) {
    if (e.type === 'PARENT_OF') parentMap[e.target] = e.source
  }
  let cur = props.node.id
  for (let i = 0; i < 5; i++) {
    const pid = parentMap[cur]
    if (!pid) break
    const parent = props.allNodes.find((n) => n.id === pid)
    if (parent?.code) codesToTry.push(parent.code)
    if (parent?.name) namesToTry.push(parent.name)
    cur = pid
  }

  try {
    const tree = await getKnowledgeTree()
    const codeToId = {}
    const nameToId = {}
    function walk(nodes) {
      if (!nodes) return
      for (const n of nodes) {
        if (n.code) codeToId[n.code] = n.id
        if (n.name) nameToId[n.name] = n.id
        if (n.children) walk(n.children)
      }
    }
    walk(tree)

    for (const code of codesToTry) {
      const dbId = codeToId[code]
      if (dbId) {
        router.push({ name: 'KnowledgeDetail', params: { module: routeModule, id: dbId } })
        return
      }
    }
    for (const name of namesToTry) {
      const dbId = nameToId[name]
      if (dbId) {
        router.push({ name: 'KnowledgeDetail', params: { module: routeModule, id: dbId } })
        return
      }
    }
  } catch (e) {
    console.warn('获取知识点树失败:', e)
  }

  router.push({
    name: 'KnowledgeModule',
    params: { module: routeModule },
    query: { highlight: props.node.id },
  })
}

const moduleLabels = {
  SET: '集合',
  LINEAR_LIST: '线性表',
  TREE: '树',
  GRAPH: '图',
  SEARCH: '查找',
  SORT: '排序',
}

const diffLabel = computed(() => {
  const map = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }
  return map[props.node?.difficulty] || props.node?.difficulty || ''
})

const diffType = computed(() => {
  const map = { EASY: 'success', MEDIUM: 'warning', HARD: 'danger' }
  return map[props.node?.difficulty] || 'info'
})

const moduleLabel = computed(() => {
  return moduleLabels[props.node?.module] || props.node?.module || ''
})

const corePointList = computed(() => {
  if (!props.node?.corePoints) return []
  return props.node.corePoints.split(/[、，,]/).map((s) => s.trim()).filter(Boolean)
})
</script>

<style scoped>
.node-detail {
  padding: 16px;
  height: 100%;
  overflow-y: auto;
}

.node-detail.empty {
  display: flex;
  align-items: center;
  justify-content: center;
}

.detail-header {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.node-name {
  margin: 0;
  font-size: 18px;
  color: #303133;
}

.node-tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.el-divider {
  margin: 12px 0;
}

.detail-body {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.section-title {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
  font-weight: 500;
}

.section-content {
  font-size: 14px;
  color: #606266;
  line-height: 1.6;
}

.code-text {
  font-family: 'Courier New', monospace;
  background: #F5F7FA;
  padding: 4px 8px;
  border-radius: 4px;
  display: inline-block;
}

.point-tag {
  margin: 2px 4px 2px 0;
}

.related-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: background 0.2s;
}

.related-item:hover {
  background: #F5F7FA;
}

.related-name {
  font-size: 13px;
  color: #409EFF;
}

.related-type {
  font-size: 11px;
  color: #C0C4CC;
}
</style>
