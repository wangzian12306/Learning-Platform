// ============================================
// 图 (Graph) 知识点数据
// ============================================

// 1. 图的主模块定义
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_001',
  name: '图',
  code: 'GRAPH',
  module: 'GRAPH',
  level: 1,
  difficulty: 'MEDIUM',
  description: '图是一种由顶点和边组成的非线性数据结构，用于表示对象之间的多对多关系',
  core_points: '顶点、边、有向图、无向图、权值、度'
})

// 2. 图的基本概念
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_002',
  name: '图的基本概念',
  code: 'GRAPH_BASIC',
  module: 'GRAPH',
  level: 2,
  difficulty: 'EASY',
  description: '图的基本组成要素和术语',
  core_points: '顶点 (Vertex): 图中的数据元素; 边 (Edge): 顶点之间的连接关系; 有向图: 边有方向的图; 无向图: 边无方向的图; 权值: 边上的数值表示代价或距离; 度: 与顶点相连的边的数目'
})

// 3. 邻接矩阵
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_003',
  name: '邻接矩阵',
  code: 'GRAPH_ADJ_MATRIX',
  module: 'GRAPH',
  level: 3,
  difficulty: 'MEDIUM',
  description: '用二维数组表示图中顶点之间的连接关系。对于 n 个顶点的图，使用 n×n 的矩阵，矩阵元素 [i][j] 表示顶点 i 到顶点 j 是否有边',
  core_points: '空间复杂度 O(n²); 适合稠密图; 判断两点间是否有边 O(1); 无向图的邻接矩阵对称'
})

// 4. 邻接表
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_004',
  name: '邻接表',
  code: 'GRAPH_ADJ_LIST',
  module: 'GRAPH',
  level: 3,
  difficulty: 'MEDIUM',
  description: '数组与链表相结合的存储结构。每个顶点对应一个链表，链表中存储与该顶点相邻的所有顶点',
  core_points: '空间复杂度 O(n+e), e 为边数; 适合稀疏图; 节省空间; 查找边的效率较低'
})

// 5. 深度优先遍历 (DFS)
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_005',
  name: '深度优先遍历',
  code: 'GRAPH_DFS',
  module: 'GRAPH',
  level: 3,
  difficulty: 'MEDIUM',
  description: '从图中某顶点出发，沿着一条路径尽可能深地访问顶点，直到无法继续，然后回溯到上一个顶点继续访问。类似树的前序遍历',
  core_points: '使用栈或递归实现; 时间复杂度 O(n+e); 需要 visited 数组标记已访问顶点; 可用于路径搜索、拓扑排序'
})

// 6. 广度优先遍历 (BFS)
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_006',
  name: '广度优先遍历',
  code: 'GRAPH_BFS',
  module: 'GRAPH',
  level: 3,
  difficulty: 'MEDIUM',
  description: '从图中某顶点出发，先访问其所有邻接点，再依次访问这些邻接点的邻接点。类似树的层序遍历',
  core_points: '使用队列实现; 时间复杂度 O(n+e); 需要 visited 数组标记已访问顶点; 可用于最短路径 (无权图)、层次遍历'
})

// 7. 图的存储结构对比
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_007',
  name: '图的存储结构对比',
  code: 'GRAPH_STORAGE_COMPARE',
  module: 'GRAPH',
  level: 2,
  difficulty: 'MEDIUM',
  description: '邻接矩阵和邻接表的对比分析',
  core_points: '邻接矩阵适合稠密图，查询快但空间大; 邻接表适合稀疏图，节省空间但查询慢; 选择存储结构需考虑图的稠密程度和操作类型'
})

// 8. 遍历算法对比
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_GRAPH_008',
  name: '图的遍历算法对比',
  code: 'GRAPH_TRAVERSAL_COMPARE',
  module: 'GRAPH',
  level: 2,
  difficulty: 'MEDIUM',
  description: '深度优先遍历和广度优先遍历的对比',
  core_points: 'DFS 使用栈/递归，BFS 使用队列; DFS 适合路径搜索，BFS 适合最短路径; 两者时间复杂度相同 O(n+e)'
})