<template>
  <div class="learning-path-layout">
    <!-- ========== 左侧：目录树 ========== -->
    <aside class="tree-panel" :class="{ collapsed: treeCollapsed }">
      <template v-if="!treeCollapsed">
        <div class="panel-header">
          <h3 class="panel-title">目录</h3>
          <div class="panel-actions">
            <el-popover placement="bottom" :width="220" trigger="hover">
              <template #reference>
                <el-button :icon="InfoFilled" circle size="small" />
              </template>
              <div class="legend-popup">
                <div class="legend-item"><span class="dot dot-not-started"></span> 未学习</div>
                <div class="legend-item"><span class="dot dot-in-progress"></span> 学习中</div>
                <div class="legend-item"><span class="dot dot-completed"></span> 已完成</div>
                <div class="legend-item"><span class="prereq-badge">⚠</span> 有前置依赖</div>
              </div>
            </el-popover>
            <el-button :icon="DArrowLeft" text size="small" title="收起目录" @click="treeCollapsed = true" />
          </div>
        </div>

        <el-input
          v-model="searchKeyword"
          placeholder="搜索知识点..."
          :prefix-icon="Search"
          clearable
          size="small"
          class="search-input"
          @input="handleSearch"
        />

        <div class="tree-wrapper">
          <el-tree
            ref="treeRef"
            :data="treeData"
            :props="treeProps"
            node-key="id"
            highlight-current
            :expand-on-click-node="true"
            :filter-node-method="filterNode"
            :default-expanded-keys="defaultExpandedKeys"
            accordion
            @node-click="handleNodeClick"
          >
            <template #default="{ data }">
              <div class="tree-node-content">
                <span
                  class="status-dot"
                  :class="'status-' + getStatus(data)"
                  :title="statusLabel[getStatus(data)]"
                ></span>
                <span class="node-label">{{ data.name }}</span>
                <el-tag
                  :type="difficultyTagType(data.difficulty)"
                  size="small"
                  class="difficulty-tag"
                >
                  {{ difficultyLabel[data.difficulty] || data.difficulty }}
                </el-tag>
                <el-tooltip
                  v-if="hasPrerequisites(data)"
                  placement="right"
                  :show-after="300"
                >
                  <template #content>
                    <div class="prereq-tooltip">
                      <strong>推荐学习顺序：</strong>
                      <ul>
                        <li v-for="pre in getPrerequisiteNames(data)" :key="pre">
                          需先学习「{{ pre }}」
                        </li>
                      </ul>
                    </div>
                  </template>
                  <span class="prereq-icon" title="有前置依赖">⚠</span>
                </el-tooltip>
              </div>
            </template>
          </el-tree>
        </div>
      </template>

      <div v-else class="collapsed-strip">
        <el-tooltip content="展开目录" placement="right">
          <el-button :icon="DArrowRight" text @click="treeCollapsed = false" />
        </el-tooltip>
      </div>
    </aside>

    <!-- ========== 右侧：知识点详情 ========== -->
    <main class="detail-panel">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { Search, InfoFilled, DArrowLeft, DArrowRight } from '@element-plus/icons-vue'
import { useKnowledgeStore } from '@/stores/knowledge'
import { useLearningStore } from '@/stores/learning'

const router = useRouter()
const knowledgeStore = useKnowledgeStore()
const learningStore = useLearningStore()

const treeRef = ref(null)
const searchKeyword = ref('')
const treeCollapsed = ref(false)

// ================================================================
//  静态 Mock 数据（后续替换为 getKnowledgeTree() API 调用）
//  数据结构与后端约定见同目录下的 data-requirements.json
// ================================================================
const mockTreeData = [
  {
    id: 1,
    neo4jId: 'KP_SET_001',
    name: '集合',
    code: 'SET',
    module: 'SET',
    level: 1,
    difficulty: 'EASY',
    prerequisites: [],
    children: [
      {
        id: 2,
        neo4jId: 'KP_SET_002',
        name: '集合运算',
        code: 'SET_OPERATION',
        module: 'SET',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_SET_001'],
        children: [
          {
            id: 21,
            neo4jId: 'KP_SET_003',
            name: '并集与交集',
            code: 'UNION_INTERSECTION',
            module: 'SET',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_SET_002'],
            children: [],
          },
          {
            id: 22,
            neo4jId: 'KP_SET_004',
            name: '差集与补集',
            code: 'DIFFERENCE_COMPLEMENT',
            module: 'SET',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_SET_002'],
            children: [],
          },
        ],
      },
    ],
  },
  {
    id: 3,
    neo4jId: 'KP_LL_001',
    name: '线性表',
    code: 'LINEAR_LIST',
    module: 'LINEAR_LIST',
    level: 1,
    difficulty: 'EASY',
    prerequisites: [],
    children: [
      {
        id: 4,
        neo4jId: 'KP_LL_002',
        name: '数组',
        code: 'ARRAY',
        module: 'LINEAR_LIST',
        level: 2,
        difficulty: 'EASY',
        prerequisites: ['KP_LL_001'],
        children: [],
      },
      {
        id: 5,
        neo4jId: 'KP_LL_003',
        name: '链表',
        code: 'LINKED_LIST',
        module: 'LINEAR_LIST',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_LL_001', 'KP_LL_002'],
        children: [
          {
            id: 51,
            neo4jId: 'KP_LL_004',
            name: '单链表',
            code: 'SINGLY_LINKED_LIST',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_LL_003'],
            children: [],
          },
          {
            id: 52,
            neo4jId: 'KP_LL_005',
            name: '双向链表',
            code: 'DOUBLY_LINKED_LIST',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_LL_003'],
            children: [],
          },
          {
            id: 53,
            neo4jId: 'KP_LL_006',
            name: '循环链表',
            code: 'CIRCULAR_LINKED_LIST',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_LL_003', 'KP_LL_004'],
            children: [],
          },
        ],
      },
      {
        id: 6,
        neo4jId: 'KP_LL_007',
        name: '栈',
        code: 'STACK',
        module: 'LINEAR_LIST',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_LL_001'],
        children: [
          {
            id: 61,
            neo4jId: 'KP_LL_008',
            name: '顺序栈',
            code: 'SEQUENTIAL_STACK',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_LL_007'],
            children: [],
          },
          {
            id: 62,
            neo4jId: 'KP_LL_009',
            name: '链式栈',
            code: 'LINKED_STACK',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_LL_007', 'KP_LL_003'],
            children: [],
          },
        ],
      },
      {
        id: 7,
        neo4jId: 'KP_LL_010',
        name: '队列',
        code: 'QUEUE',
        module: 'LINEAR_LIST',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_LL_001'],
        children: [
          {
            id: 71,
            neo4jId: 'KP_LL_011',
            name: '循环队列',
            code: 'CIRCULAR_QUEUE',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_LL_010'],
            children: [],
          },
          {
            id: 72,
            neo4jId: 'KP_LL_012',
            name: '链式队列',
            code: 'LINKED_QUEUE',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_LL_010', 'KP_LL_003'],
            children: [],
          },
        ],
      },
      {
        id: 8,
        neo4jId: 'KP_LL_013',
        name: '串',
        code: 'STRING',
        module: 'LINEAR_LIST',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_LL_001'],
        children: [
          {
            id: 81,
            neo4jId: 'KP_LL_014',
            name: '模式匹配算法',
            code: 'PATTERN_MATCHING',
            module: 'LINEAR_LIST',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_LL_013'],
            children: [],
          },
        ],
      },
      {
        id: 9,
        neo4jId: 'KP_LL_015',
        name: '广义表',
        code: 'GENERALIZED_LIST',
        module: 'LINEAR_LIST',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_LL_001', 'KP_LL_003'],
        children: [],
      },
    ],
  },
  {
    id: 10,
    neo4jId: 'KP_TREE_001',
    name: '树',
    code: 'TREE',
    module: 'TREE',
    level: 1,
    difficulty: 'EASY',
    prerequisites: [],
    children: [
      {
        id: 11,
        neo4jId: 'KP_TREE_002',
        name: '二叉树',
        code: 'BINARY_TREE',
        module: 'TREE',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_TREE_001'],
        children: [
          {
            id: 111,
            neo4jId: 'KP_TREE_003',
            name: '二叉树遍历',
            code: 'TREE_TRAVERSAL',
            module: 'TREE',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_TREE_002'],
            children: [],
          },
          {
            id: 112,
            neo4jId: 'KP_TREE_004',
            name: '二叉搜索树',
            code: 'BINARY_SEARCH_TREE',
            module: 'TREE',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_TREE_002'],
            children: [],
          },
        ],
      },
      {
        id: 12,
        neo4jId: 'KP_TREE_005',
        name: 'AVL 树',
        code: 'AVL_TREE',
        module: 'TREE',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_TREE_002', 'KP_TREE_004'],
        children: [],
      },
      {
        id: 13,
        neo4jId: 'KP_TREE_006',
        name: '红黑树',
        code: 'RED_BLACK_TREE',
        module: 'TREE',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_TREE_002', 'KP_TREE_004'],
        children: [],
      },
      {
        id: 14,
        neo4jId: 'KP_TREE_007',
        name: 'B 树与 B+ 树',
        code: 'B_TREE',
        module: 'TREE',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_TREE_002'],
        children: [
          {
            id: 141,
            neo4jId: 'KP_TREE_008',
            name: 'B 树插入删除',
            code: 'B_TREE_OPS',
            module: 'TREE',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_TREE_007'],
            children: [],
          },
        ],
      },
    ],
  },
  {
    id: 20,
    neo4jId: 'KP_GRAPH_001',
    name: '图',
    code: 'GRAPH',
    module: 'GRAPH',
    level: 1,
    difficulty: 'MEDIUM',
    prerequisites: [],
    children: [
      {
        id: 201,
        neo4jId: 'KP_GRAPH_002',
        name: '图的存储结构',
        code: 'GRAPH_STORAGE',
        module: 'GRAPH',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_GRAPH_001'],
        children: [
          {
            id: 211,
            neo4jId: 'KP_GRAPH_003',
            name: '邻接矩阵',
            code: 'ADJACENCY_MATRIX',
            module: 'GRAPH',
            level: 3,
            difficulty: 'EASY',
            prerequisites: ['KP_GRAPH_002'],
            children: [],
          },
          {
            id: 212,
            neo4jId: 'KP_GRAPH_004',
            name: '邻接表',
            code: 'ADJACENCY_LIST',
            module: 'GRAPH',
            level: 3,
            difficulty: 'EASY',
            prerequisites: ['KP_GRAPH_002'],
            children: [],
          },
        ],
      },
      {
        id: 202,
        neo4jId: 'KP_GRAPH_005',
        name: '图的遍历',
        code: 'GRAPH_TRAVERSAL',
        module: 'GRAPH',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_GRAPH_001', 'KP_GRAPH_002'],
        children: [
          {
            id: 221,
            neo4jId: 'KP_GRAPH_006',
            name: '深度优先搜索',
            code: 'DFS',
            module: 'GRAPH',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_GRAPH_005', 'KP_LL_007'],
            children: [],
          },
          {
            id: 222,
            neo4jId: 'KP_GRAPH_007',
            name: '广度优先搜索',
            code: 'BFS',
            module: 'GRAPH',
            level: 3,
            difficulty: 'MEDIUM',
            prerequisites: ['KP_GRAPH_005', 'KP_LL_010'],
            children: [],
          },
        ],
      },
      {
        id: 203,
        neo4jId: 'KP_GRAPH_008',
        name: '最小生成树',
        code: 'MST',
        module: 'GRAPH',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_GRAPH_001'],
        children: [
          {
            id: 231,
            neo4jId: 'KP_GRAPH_009',
            name: 'Prim 算法',
            code: 'PRIM',
            module: 'GRAPH',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_GRAPH_008'],
            children: [],
          },
          {
            id: 232,
            neo4jId: 'KP_GRAPH_010',
            name: 'Kruskal 算法',
            code: 'KRUSKAL',
            module: 'GRAPH',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_GRAPH_008'],
            children: [],
          },
        ],
      },
      {
        id: 204,
        neo4jId: 'KP_GRAPH_011',
        name: '最短路径',
        code: 'SHORTEST_PATH',
        module: 'GRAPH',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_GRAPH_002'],
        children: [
          {
            id: 241,
            neo4jId: 'KP_GRAPH_012',
            name: 'Dijkstra 算法',
            code: 'DIJKSTRA',
            module: 'GRAPH',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_GRAPH_011'],
            children: [],
          },
          {
            id: 242,
            neo4jId: 'KP_GRAPH_013',
            name: 'Floyd 算法',
            code: 'FLOYD',
            module: 'GRAPH',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_GRAPH_011'],
            children: [],
          },
        ],
      },
    ],
  },
  {
    id: 30,
    neo4jId: 'KP_SEARCH_001',
    name: '查找',
    code: 'SEARCH',
    module: 'SEARCH',
    level: 1,
    difficulty: 'MEDIUM',
    prerequisites: [],
    children: [
      {
        id: 31,
        neo4jId: 'KP_SEARCH_002',
        name: '顺序查找',
        code: 'SEQUENTIAL_SEARCH',
        module: 'SEARCH',
        level: 2,
        difficulty: 'EASY',
        prerequisites: ['KP_SEARCH_001'],
        children: [],
      },
      {
        id: 32,
        neo4jId: 'KP_SEARCH_003',
        name: '二分查找',
        code: 'BINARY_SEARCH',
        module: 'SEARCH',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_SEARCH_001'],
        children: [],
      },
      {
        id: 33,
        neo4jId: 'KP_SEARCH_004',
        name: '哈希查找',
        code: 'HASH_SEARCH',
        module: 'SEARCH',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_SEARCH_001'],
        children: [
          {
            id: 331,
            neo4jId: 'KP_SEARCH_005',
            name: '哈希函数与冲突解决',
            code: 'HASH_COLLISION',
            module: 'SEARCH',
            level: 3,
            difficulty: 'HARD',
            prerequisites: ['KP_SEARCH_004'],
            children: [],
          },
        ],
      },
      {
        id: 34,
        neo4jId: 'KP_SEARCH_006',
        name: '树表查找',
        code: 'TREE_SEARCH',
        module: 'SEARCH',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_SEARCH_001', 'KP_TREE_002'],
        children: [],
      },
    ],
  },
  {
    id: 40,
    neo4jId: 'KP_SORT_001',
    name: '排序',
    code: 'SORT',
    module: 'SORT',
    level: 1,
    difficulty: 'MEDIUM',
    prerequisites: [],
    children: [
      {
        id: 41,
        neo4jId: 'KP_SORT_002',
        name: '冒泡排序',
        code: 'BUBBLE_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'EASY',
        prerequisites: ['KP_SORT_001'],
        children: [],
      },
      {
        id: 42,
        neo4jId: 'KP_SORT_003',
        name: '选择排序',
        code: 'SELECTION_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'EASY',
        prerequisites: ['KP_SORT_001'],
        children: [],
      },
      {
        id: 43,
        neo4jId: 'KP_SORT_004',
        name: '插入排序',
        code: 'INSERTION_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'EASY',
        prerequisites: ['KP_SORT_001'],
        children: [],
      },
      {
        id: 44,
        neo4jId: 'KP_SORT_005',
        name: '快速排序',
        code: 'QUICK_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_SORT_001', 'KP_TREE_002'],
        children: [],
      },
      {
        id: 45,
        neo4jId: 'KP_SORT_006',
        name: '归并排序',
        code: 'MERGE_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_SORT_001'],
        children: [],
      },
      {
        id: 46,
        neo4jId: 'KP_SORT_007',
        name: '堆排序',
        code: 'HEAP_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'HARD',
        prerequisites: ['KP_SORT_001', 'KP_TREE_002'],
        children: [],
      },
      {
        id: 47,
        neo4jId: 'KP_SORT_008',
        name: '希尔排序',
        code: 'SHELL_SORT',
        module: 'SORT',
        level: 2,
        difficulty: 'MEDIUM',
        prerequisites: ['KP_SORT_001', 'KP_SORT_004'],
        children: [],
      },
    ],
  },
]

// TODO: 后续替换为真实 API 调用
const treeData = ref(mockTreeData)

const treeProps = { children: 'children', label: 'name' }
const defaultExpandedKeys = []

const neo4jIdIndex = computed(() => {
  const map = new Map()
  function walk(nodes) {
    for (const n of nodes) {
      map.set(n.neo4jId, n)
      if (n.children) walk(n.children)
    }
  }
  walk(treeData.value)
  return map
})

// ================================================================
//  学习状态
// ================================================================
const statusLabel = { not_started: '未学习', in_progress: '学习中', completed: '已完成' }

function getStatus(data) {
  return learningStore.getProgress(data.id)
}

// 静态演示进度数据（仅 dev 环境下当 progressMap 为空时注入，避免覆盖真实数据）
if (import.meta.env.DEV && Object.keys(learningStore.progressMap).length === 0) {
  learningStore.setProgress(1, 'completed')
  learningStore.setProgress(2, 'completed')
  learningStore.setProgress(21, 'completed')
  learningStore.setProgress(3, 'completed')
  learningStore.setProgress(4, 'completed')
  learningStore.setProgress(5, 'in_progress')
  learningStore.setProgress(51, 'in_progress')
  learningStore.setProgress(10, 'completed')
  learningStore.setProgress(11, 'in_progress')
}

// ================================================================
//  难度标签
// ================================================================
const difficultyLabel = { EASY: '简单', MEDIUM: '中等', HARD: '困难' }

function difficultyTagType(d) {
  return d === 'EASY' ? 'success' : d === 'MEDIUM' ? 'warning' : 'danger'
}

// ================================================================
//  前置依赖（路径引导）
// ================================================================
function hasPrerequisites(data) {
  return data.prerequisites && data.prerequisites.length > 0
}

function getPrerequisiteNames(data) {
  return (data.prerequisites || []).map((neo4jId) => {
    const node = neo4jIdIndex.value.get(neo4jId)
    return node ? node.name : neo4jId
  })
}

// ================================================================
//  节点点击 → 右侧展示详情
// ================================================================
function handleNodeClick(data) {
  const moduleKey = data.module.toLowerCase()
  knowledgeStore.setCurrentNode({
    id: data.id,
    name: data.name,
    module: moduleKey,
    difficulty: data.difficulty,
  })
  knowledgeStore.setCurrentModule(moduleKey)

  router.push({
    name: 'KnowledgeDetail',
    params: { module: moduleKey, id: data.id },
  })
}

// ================================================================
//  搜索过滤
// ================================================================
function handleSearch() {
  treeRef.value.filter(searchKeyword.value)
}

function filterNode(value, data) {
  if (!value) return true
  return (
    data.name.includes(value) ||
    (data.code && data.code.toLowerCase().includes(value.toLowerCase()))
  )
}


</script>

<style scoped>
.learning-path-layout {
  display: flex;
  height: calc(100vh - 56px);
  margin: -24px;
}

/* ========== 左侧树面板 ========== */
.tree-panel {
  width: 320px;
  min-width: 280px;
  background: #fff;
  border-right: 1px solid #e8e8e8;
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
  transition: width 0.25s ease;
}

.tree-panel.collapsed {
  width: 44px;
  min-width: 44px;
}

.panel-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 16px 0;
}

.panel-actions {
  display: flex;
  align-items: center;
  gap: 4px;
}

.panel-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.search-input {
  padding: 12px 16px 0;
}

.tree-wrapper {
  flex: 1;
  overflow-y: auto;
  padding: 8px 8px 8px 4px;
}

.collapsed-strip {
  flex: 1;
  display: flex;
  justify-content: center;
  padding-top: 12px;
}

/* ========== 右侧详情面板 ========== */
.detail-panel {
  flex: 1;
  min-width: 0;
  overflow-y: auto;
  background: #f5f7fa;
}

/* ========== 树节点 ========== */
.tree-node-content {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 0;
  padding-right: 4px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.status-not_started { background: #c0c4cc; }

.status-in_progress {
  background: #409eff;
  box-shadow: 0 0 0 3px rgba(64, 158, 255, 0.2);
}

.status-completed { background: #67c23a; }

.node-label {
  font-size: 13px;
  color: #303133;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.difficulty-tag {
  flex-shrink: 0;
  margin-left: auto;
  transform: scale(0.85);
}

.prereq-icon {
  color: #e6a23c;
  font-size: 13px;
  flex-shrink: 0;
  cursor: help;
}

/* ========== 图例 ========== */
.legend-popup {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
}

.dot {
  display: inline-block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
}

.dot-not-started { background: #c0c4cc; }
.dot-in-progress { background: #409eff; }
.dot-completed { background: #67c23a; }

.prereq-badge { color: #e6a23c; }

/* ========== tooltip ========== */
.prereq-tooltip ul {
  margin: 4px 0 0;
  padding-left: 16px;
}

.prereq-tooltip li {
  font-size: 13px;
  line-height: 1.8;
}

/* ========== el-tree 微调 ========== */
:deep(.el-tree-node__content) {
  height: 34px;
  padding-right: 4px;
}

:deep(.el-tree-node.is-current > .el-tree-node__content) {
  background-color: #ecf5ff;
}

:deep(.el-tree-node__label) {
  flex: 1;
  min-width: 0;
}

:deep(.el-tree) {
  font-size: 13px;
}
</style>
