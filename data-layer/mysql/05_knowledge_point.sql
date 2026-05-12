-- ================================================================
-- 模块: 知识点（知识图谱底层数据）
-- 负责人: 学习目录功能
-- 日期: 2026-05-11
-- 
-- 说明: 本 SQL 基于以下权威来源，与 Neo4j 数据层严格保持一致：
--   1. data-layer/neo4j/import/10_set.cypher ~ 90_cross_module.cypher
--   2. docs/Neo4j数据结构定义.md
--   3. docs/要求.md (section 3.1.1 知识点覆盖)
--   4. data-requirements.json
--   5. data-layer/mysql/00_schema.sql (knowledge_point 表结构)
-- 
-- 知识点通过 parent_id 组织为 3 层树：
--   level=1: 模块根节点 (parent_id IS NULL)
--   level=2: 子模块/核心概念
--   level=3: 具体知识点/算法
-- ================================================================

USE learning_platform;

-- 清理旧数据 (谨慎：仅删 knowledge_point 表，不影响其它模块数据)
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE knowledge_point;
SET FOREIGN_KEY_CHECKS = 1;

-- ==================== 集合 (SET) ====================
-- 来源: 10_set.cypher (2 nodes)
INSERT INTO knowledge_point (id, neo4j_id, name, code, parent_id, module, level, difficulty, description, core_points) VALUES
(1, 'KP_SET_001', '集合',       'SET',          NULL, 'SET', 1, 'EASY',   '集合是数学中的基本概念，表示具有某种特定性质的对象的总体', '集合定义、集合表示、集合运算'),
(2, 'KP_SET_002', '集合运算',   'SET_OPERATION', 1,    'SET', 2, 'MEDIUM', '集合的基本运算包括并集、交集、差集等', '并集、交集、差集、补集');

-- ==================== 线性表 (LINEAR_LIST) ====================
-- 来源: 20_linear_list.cypher (9 nodes)
-- 层级: 线性表 → 栈/队列/串/数组/广义表 → 栈基本操作/队列基本操作/KMP算法
INSERT INTO knowledge_point (id, neo4j_id, name, code, parent_id, module, level, difficulty, description, core_points) VALUES
(3,  'KP_LL_001', '线性表',         'LINEAR_LIST',       NULL, 'LINEAR_LIST', 1, 'EASY',   '线性表是由n个数据元素组成的有限序列，是最基本、最常用的数据结构', '线性表定义、顺序存储、链式存储'),
(4,  'KP_LL_002', '栈',             'STACK',             3,    'LINEAR_LIST', 2, 'EASY',   '栈是一种后进先出(LIFO)的线性表，只允许在一端进行插入和删除操作', '栈的定义、顺序栈、链栈、栈的应用'),
(5,  'KP_LL_003', '栈的基本操作',   'STACK_OPS',         4,    'LINEAR_LIST', 3, 'EASY',   '栈的基本操作包括入栈(push)、出栈(pop)、取栈顶元素等', 'push、pop、top、isEmpty'),
(6,  'KP_LL_004', '队列',           'QUEUE',             3,    'LINEAR_LIST', 2, 'EASY',   '队列是一种先进先出(FIFO)的线性表，一端插入、另一端删除', '队列定义、顺序队列、链队列、循环队列'),
(7,  'KP_LL_005', '队列的基本操作', 'QUEUE_OPS',         6,    'LINEAR_LIST', 3, 'EASY',   '队列的基本操作包括入队(enqueue)、出队(dequeue)、取队头元素等', 'enqueue、dequeue、front、isEmpty'),
(8,  'KP_LL_006', '串',             'STRING',            3,    'LINEAR_LIST', 2, 'MEDIUM', '串是由零个或多个字符组成的有限序列，又称为字符串', '串的定义、串的存储、串的模式匹配'),
(9,  'KP_LL_007', 'KMP算法',        'KMP',               8,    'LINEAR_LIST', 3, 'HARD',   'KMP算法是一种高效的字符串模式匹配算法，通过预处理next数组避免重复比较', 'next数组、模式匹配、时间复杂度O(n+m)'),
(10, 'KP_LL_008', '数组',           'ARRAY',             3,    'LINEAR_LIST', 2, 'EASY',   '数组是由相同类型的数据元素构成的有限序列，支持随机访问', '数组定义、顺序存储、多维数组、稀疏矩阵'),
(11, 'KP_LL_009', '广义表',         'GENERALIZED_LIST',  3,    'LINEAR_LIST', 2, 'MEDIUM', '广义表是线性表的推广，表中的元素可以是原子也可以是子表', '广义表定义、存储结构、head/tail操作');

-- ==================== 树 (TREE) ====================
-- 来源: 30_tree.cypher (8 nodes)
-- 层级: 树 → 二叉树/B树 → 二叉树遍历/二叉排序树/AVL/红黑/B+树
INSERT INTO knowledge_point (id, neo4j_id, name, code, parent_id, module, level, difficulty, description, core_points) VALUES
(12, 'KP_TREE_001', '树',           'TREE',          NULL, 'TREE', 1, 'EASY',   '树是一种非线性数据结构，由n个有限节点组成，具有层次关系', '树的定义、基本术语、树的存储'),
(13, 'KP_TREE_002', '二叉树',       'BINARY_TREE',   12,   'TREE', 2, 'MEDIUM', '二叉树是每个节点最多有两个子树的树结构，是最重要的树形结构', '二叉树定义、性质、存储、遍历'),
(14, 'KP_TREE_003', '二叉树遍历',   'BT_TRAVERSE',   13,   'TREE', 3, 'MEDIUM', '二叉树遍历包括前序、中序、后序遍历和层序遍历', '前序遍历、中序遍历、后序遍历、层序遍历'),
(15, 'KP_TREE_004', '二叉排序树',   'BST',           13,   'TREE', 2, 'MEDIUM', '二叉排序树是一棵满足左小右大性质的二叉树，支持高效查找', 'BST定义、插入、删除、查找'),
(16, 'KP_TREE_005', 'AVL树',        'AVL_TREE',      15,   'TREE', 3, 'HARD',   'AVL树是自平衡二叉搜索树，任意节点的左右子树高度差不超过1', '平衡条件、旋转操作(LL/RR/LR/RL)、插入删除'),
(17, 'KP_TREE_006', '红黑树',       'RED_BLACK_TREE',15,   'TREE', 3, 'HARD',   '红黑树是一种自平衡二叉搜索树，通过颜色标记和旋转维持平衡', '红黑树性质、插入调整、删除调整'),
(18, 'KP_TREE_007', 'B树',          'B_TREE',        12,   'TREE', 3, 'HARD',   'B树是一种自平衡多路搜索树，常用于数据库和文件系统的索引', 'B树定义、m阶B树性质、插入分裂、删除合并'),
(19, 'KP_TREE_008', 'B+树',         'BPLUS_TREE',    18,   'TREE', 3, 'HARD',   'B+树是B树的变体，所有数据存储在叶子节点，叶子节点通过链表相连', 'B+树定义、与B树区别、范围查询优势');

-- ==================== 图 (GRAPH) ====================
-- 来源: 40_graph.cypher (10 nodes)
-- 层级: 图 → 存储结构/DFS/BFS/最小生成树/最短路径 → Prim/Kruskal/Dijkstra/Floyd
INSERT INTO knowledge_point (id, neo4j_id, name, code, parent_id, module, level, difficulty, description, core_points) VALUES
(20, 'KP_GRAPH_001', '图',                 'GRAPH',         NULL, 'GRAPH', 1, 'MEDIUM', '图是由顶点集合和边集合组成的非线性数据结构', '图的定义、有向图、无向图、权值'),
(21, 'KP_GRAPH_002', '图的存储结构',       'GRAPH_STORAGE', 20,   'GRAPH', 2, 'MEDIUM', '图的存储方式包括邻接矩阵、邻接表、十字链表等', '邻接矩阵、邻接表、存储空间分析'),
(22, 'KP_GRAPH_003', '深度优先搜索(DFS)',  'DFS',           20,   'GRAPH', 2, 'MEDIUM', 'DFS是从某个顶点出发，沿着一条路径尽可能深入，然后回溯的遍历方式', 'DFS递归实现、DFS非递归、时间复杂度O(V+E)'),
(23, 'KP_GRAPH_004', '广度优先搜索(BFS)',  'BFS',           20,   'GRAPH', 2, 'MEDIUM', 'BFS是从某个顶点出发，先访问所有相邻顶点，再逐层向外扩展的遍历方式', 'BFS队列实现、最短路径、时间复杂度O(V+E)'),
(24, 'KP_GRAPH_005', '最小生成树',         'MST',           20,   'GRAPH', 3, 'HARD',   '最小生成树是连通无向图中包含所有顶点的最小权值生成树', 'Prim算法、Kruskal算法'),
(25, 'KP_GRAPH_006', 'Prim算法',           'PRIM',          24,   'GRAPH', 3, 'HARD',   'Prim算法从一个顶点开始，每次选择权值最小的边扩展生成树', '贪心策略、时间复杂度O(V²)或O(ElogV)'),
(26, 'KP_GRAPH_007', 'Kruskal算法',        'KRUSKAL',       24,   'GRAPH', 3, 'HARD',   'Kruskal算法按边权值从小到大选择边，用并查集判断是否成环', '并查集、按权排序、时间复杂度O(ElogE)'),
(27, 'KP_GRAPH_008', '最短路径',           'SHORTEST_PATH', 20,   'GRAPH', 3, 'HARD',   '最短路径问题是求图中两个顶点之间权值之和最小的路径', 'Dijkstra算法、Floyd算法'),
(28, 'KP_GRAPH_009', 'Dijkstra算法',       'DIJKSTRA',      27,   'GRAPH', 3, 'HARD',   'Dijkstra算法求单源最短路径，适用于权值非负的图', '贪心策略、时间复杂度O(V²)、不能处理负权边'),
(29, 'KP_GRAPH_010', 'Floyd算法',          'FLOYD',         27,   'GRAPH', 3, 'HARD',   'Floyd算法求所有顶点对之间的最短路径，基于动态规划', '动态规划、时间复杂度O(V³)、可处理负权边');

-- ==================== 查找 (SEARCH) ====================
-- 来源: 50_search.cypher (5 nodes)
-- 层级: 查找 → 顺序查找/二分查找/哈希查找/树表查找
INSERT INTO knowledge_point (id, neo4j_id, name, code, parent_id, module, level, difficulty, description, core_points) VALUES
(30, 'KP_SEARCH_001', '查找',     'SEARCH',      NULL, 'SEARCH', 1, 'EASY',   '查找是在数据集合中寻找满足条件的数据元素的过程', '查找定义、平均查找长度ASL、查找分类'),
(31, 'KP_SEARCH_002', '顺序查找', 'SEQ_SEARCH',  30,   'SEARCH', 2, 'EASY',   '顺序查找从表的一端开始，逐个比较关键字，适用于顺序表和链表', '基本思想、时间复杂度O(n)、哨兵优化'),
(32, 'KP_SEARCH_003', '二分查找', 'BIN_SEARCH',  30,   'SEARCH', 2, 'MEDIUM', '二分查找在有序表中通过折半缩小查找范围，效率高', '前提条件有序、时间复杂度O(logn)、判定树'),
(33, 'KP_SEARCH_004', '哈希查找', 'HASH_SEARCH', 30,   'SEARCH', 3, 'HARD',   '哈希查找通过哈希函数将关键字映射到存储地址，实现O(1)查找', '哈希函数、冲突处理(开放定址/链地址法)、装填因子'),
(34, 'KP_SEARCH_005', '树表查找', 'TREE_SEARCH', 30,   'SEARCH', 2, 'MEDIUM', '树表查找利用树形结构组织数据，包括二叉排序树查找、平衡树查找等', 'BST查找、AVL查找、B树查找');

-- ==================== 排序 (SORT) ====================
-- 来源: 60_sort.cypher (8 nodes)
-- 层级: 排序 → 8 种排序算法 (扁平结构)
INSERT INTO knowledge_point (id, neo4j_id, name, code, parent_id, module, level, difficulty, description, core_points) VALUES
(40, 'KP_SORT_001', '排序',       'SORTING',        NULL, 'SORT', 1, 'EASY',   '排序是将数据元素按关键字递增或递减顺序重新排列的过程', '排序定义、稳定性、时间/空间复杂度、适用场景'),
(41, 'KP_SORT_002', '冒泡排序',   'BUBBLE_SORT',    40,   'SORT', 2, 'EASY',   '冒泡排序通过相邻元素比较交换，每轮将最大元素"冒泡"到末尾', '基本原理、时间O(n²)、空间O(1)、稳定排序'),
(42, 'KP_SORT_003', '选择排序',   'SELECTION_SORT', 40,   'SORT', 2, 'EASY',   '选择排序每轮从未排序部分选择最小元素放到已排序部分末尾', '基本原理、时间O(n²)、空间O(1)、不稳定'),
(43, 'KP_SORT_004', '插入排序',   'INSERTION_SORT', 40,   'SORT', 2, 'EASY',   '插入排序将元素逐个插入到已排序序列的适当位置', '基本原理、时间O(n²)、空间O(1)、稳定排序、对近似有序数据高效'),
(44, 'KP_SORT_005', '希尔排序',   'SHELL_SORT',     40,   'SORT', 2, 'MEDIUM', '希尔排序是插入排序的改进，通过分组增量缩小进行多轮插入排序', '增量序列、时间复杂度与增量选择有关、不稳定'),
(45, 'KP_SORT_006', '快速排序',   'QUICK_SORT',     40,   'SORT', 2, 'MEDIUM', '快速排序通过分区操作将数组分为两部分，递归排序，是实践中最快的排序算法之一', '分区操作、pivot选择、平均O(nlogn)、最坏O(n²)、不稳定'),
(46, 'KP_SORT_007', '归并排序',   'MERGE_SORT',     40,   'SORT', 2, 'MEDIUM', '归并排序将数组分成两半，分别排序后合并，基于分治思想', '分治思想、合并操作、时间O(nlogn)、空间O(n)、稳定排序'),
(47, 'KP_SORT_008', '堆排序',     'HEAP_SORT',      40,   'SORT', 3, 'HARD',   '堆排序利用堆这种数据结构进行排序，先建堆再逐个取出堆顶元素', '大顶堆/小顶堆、建堆、调整堆、时间O(nlogn)、空间O(1)、不稳定');

-- ================================================================
-- 统计: 合计 42 个知识点 (与 Neo4j 一致)
--   SET      2 节点
--   LINEAR_LIST  9 节点
--   TREE     8 节点
--   GRAPH   10 节点
--   SEARCH   5 节点
--   SORT     8 节点
-- ================================================================
