# 知识点数据字典

## 使用说明

本文档用于团队共同梳理和记录知识点信息。各模块负责人填写对应模块的知识点清单。

## 填写规范

### 必填字段
- **neo4j_id**: 按规范编号 (KP_模块前缀_序号)
- **name**: 知识点名称
- **code**: 知识点编码 (英文大写，下划线分隔)
- **module**: 所属模块
- **level**: 层级 (1/2/3)
- **difficulty**: 难度 (EASY/MEDIUM/HARD)

### 选填字段
- **description**: 知识点描述
- **core_points**: 核心考点
- **parent_id**: 父知识点ID (MySQL)
- **relations**: 关联知识点及关系类型

---

## 模块: 集合 (SET)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_SET_001 | 集合 | SET | 1 | EASY | 集合的基本概念 | 集合定义、性质 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 线性表 (LINEAR_LIST)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_LL_001 | 线性表 | LINEAR_LIST | 1 | EASY | 线性表的基本概念 | 线性表定义、特点 | NULL | - |
| KP_LL_002 | 数组 | ARRAY | 3 | EASY | 数组的实现和特点 | 连续内存、随机访问 | NULL | KP_LL_003 (PREREQUISITE, 5) |
| KP_LL_003 | 链表 | LINKED_LIST | 3 | MEDIUM | 链表的实现和特点 | 指针操作、动态分配 | NULL | KP_LL_002 (EXTENSION, 4) |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 树 (TREE)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_TREE_001 | 树 | TREE | 1 | EASY | 树的基本概念 | 树的定义、术语 | NULL | - |
| KP_TREE_002 | 二叉树 | BINARY_TREE | 2 | MEDIUM | 二叉树的定义和性质 | 二叉树特性、遍历 | KP_TREE_001 | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 图 (GRAPH)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_GRAPH_001 | 图 | GRAPH | 1 | MEDIUM | 图的基本概念 | 图的定义、术语 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 查找 (SEARCH)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_SEARCH_001 | 查找 | SEARCH | 1 | MEDIUM | 在一组数据中定位目标元素的位置或是否存在，是检索、索引、推荐等功能的基础能力 | 查找目标定义、成功/失败结果、静态与动态查找区别；示例: 在学生名单中找“张三”是否存在 | NULL | - |
| KP_SEARCH_002 | 顺序查找-原理 | SEQUENTIAL_SEARCH_PRINCIPLE | 3 | EASY | 从第1个元素开始逐个比对，直到找到目标或全部比完，逻辑最直观 | 逐个比较、命中即停、最坏需看完全部元素；示例: 点名时按花名册从上到下找人 | KP_SEARCH_001 | KP_SEARCH_005 (COMPARISON, 5), KP_SEARCH_008 (COMPARISON, 4) |
| KP_SEARCH_003 | 顺序查找-实现优化 | SEQUENTIAL_SEARCH_IMPLEMENTATION | 3 | MEDIUM | 顺序查找在代码层的常见写法和小优化，重点是减少判断和分支 | 哨兵法减少边界判断、for/while写法、数组与链表实现差异；示例: 在日志列表中扫描某个错误码 | KP_SEARCH_002 | KP_SEARCH_014 (EXTENSION, 4) |
| KP_SEARCH_004 | 顺序查找-应用场景 | SEQUENTIAL_SEARCH_APPLICATION | 3 | EASY | 当数据量小、数据无序、只偶尔查一次时，顺序查找通常最省事 | 无需预处理、实现成本低、适合一次性检索；示例: 在10条待办里找“买牛奶” | KP_SEARCH_002 | KP_SEARCH_014 (PREREQUISITE, 3) |
| KP_SEARCH_005 | 二分查找-原理 | BINARY_SEARCH_PRINCIPLE | 3 | MEDIUM | 每次先看中间元素，根据大小关系把查找范围缩小一半，但前提是数据有序 | 有序前提、折半缩小、时间复杂度O(log n)；示例: 在按学号排序的名单中找某学号 | KP_SEARCH_001 | KP_SEARCH_002 (COMPARISON, 5), KP_SEARCH_008 (COMPARISON, 4) |
| KP_SEARCH_006 | 二分查找-实现边界 | BINARY_SEARCH_IMPLEMENTATION | 3 | MEDIUM | 二分查找容易写错在边界条件，需统一区间定义和结束条件 | 左闭右闭/左闭右开、mid计算防溢出、未命中返回值约定；示例: 返回插入位置用于有序数组插入 | KP_SEARCH_005 | KP_SEARCH_014 (EXTENSION, 4) |
| KP_SEARCH_007 | 二分查找-变体 | BINARY_SEARCH_VARIANTS | 3 | HARD | 二分不仅能找“某值”，还常用于找边界位置 | 首个等于、最后等于、首个>=x、最后<=x；示例: 在成绩列表中找第一个及格分数的位置 | KP_SEARCH_006 | KP_SEARCH_014 (EXTENSION, 4) |
| KP_SEARCH_008 | 哈希查找-原理 | HASH_SEARCH_PRINCIPLE | 3 | HARD | 先用哈希函数把关键字映射到“桶/槽位”，再在该位置附近快速定位 | 键到地址映射、平均O(1)、空间换时间；示例: 通过用户名快速定位用户资料 | KP_SEARCH_001 | KP_SEARCH_011 (COMPARISON, 4), KP_SEARCH_012 (COMPARISON, 4) |
| KP_SEARCH_009 | 哈希查找-冲突处理 | HASH_COLLISION_RESOLUTION | 3 | HARD | 多个键映射到同一槽位时必须处理冲突，否则无法正确查找 | 开放定址法、链地址法、再哈希、主聚集问题；示例: 两个工号映射到同一数组下标 | KP_SEARCH_008 | KP_SEARCH_010 (PREREQUISITE, 5), KP_SEARCH_014 (EXTENSION, 4) |
| KP_SEARCH_010 | 哈希查找-性能分析 | HASH_SEARCH_PERFORMANCE | 3 | HARD | 哈希性能受装填因子和冲突策略影响，需要在速度与内存间平衡 | 装填因子阈值、扩容重哈希时机、平均探测长度；示例: 登录系统用户暴增后触发扩容 | KP_SEARCH_009 | KP_SEARCH_014 (PREREQUISITE, 4) |
| KP_SEARCH_011 | 二叉排序树查找-原理 | BST_SEARCH_PRINCIPLE | 3 | MEDIUM | 依据“左小右大”规则向下走，直到命中或走到空节点 | 路径比较、树高决定效率、最坏退化为链表；示例: 在动态插入的商品价格树中查某价格 | KP_SEARCH_001 | KP_TREE_002 (PREREQUISITE, 5), KP_SEARCH_012 (EXTENSION, 5), KP_SEARCH_008 (COMPARISON, 4) |
| KP_SEARCH_012 | 平衡二叉树查找-原理 | AVL_SEARCH_PRINCIPLE | 3 | HARD | 在BST基础上保持“左右子树高度差不超过1”，让查找效率更稳定 | 平衡因子、LL/LR/RR/RL旋转、稳定O(log n)；示例: 频繁增删的排行榜索引结构 | KP_SEARCH_011 | KP_SEARCH_008 (COMPARISON, 3), KP_SEARCH_014 (PREREQUISITE, 4) |
| KP_SEARCH_013 | 树表查找-实现要点 | TREE_SEARCH_IMPLEMENTATION | 3 | HARD | 树查找的工程实现重点在插入删除后如何维护结构正确和高度合理 | 递归/迭代实现、回溯更新高度、旋转触发条件；示例: 订单索引插入后自动重平衡 | KP_SEARCH_011 | KP_SEARCH_012 (PREREQUISITE, 5), KP_SEARCH_014 (EXTENSION, 4) |
| KP_SEARCH_014 | 查找算法应用与选型 | SEARCH_ALGORITHM_SELECTION | 2 | MEDIUM | 面向真实业务根据数据特征选择算法，而不是只看理论复杂度 | 选型口诀: 无序小数据用顺序；有序静态用二分；高频精确查找用哈希；频繁增删且需有序遍历用AVL/BST；示例: 通讯录搜索、库存检索、日志检索 | KP_SEARCH_001 | KP_SEARCH_003 (PREREQUISITE, 4), KP_SEARCH_006 (PREREQUISITE, 4), KP_SEARCH_010 (PREREQUISITE, 4), KP_SEARCH_013 (PREREQUISITE, 3) |
| KP_SEARCH_015 | 顺序查找-输入要求 | SEQ_INPUT_REQUIREMENT | 3 | EASY | 顺序查找对数据几乎没有前置要求 | 无序可用、结构通用；例: 临时名单 | KP_SEARCH_002 | KP_SEARCH_005 (EXTENSION, 2) |
| KP_SEARCH_016 | 顺序查找-返回结果设计 | SEQ_RETURN_CONTRACT | 3 | EASY | 约定返回首个下标、全部下标或不存在标记 | 接口契约清晰 | KP_SEARCH_002 | KP_SEARCH_017 (EXTENSION, 3) |
| KP_SEARCH_017 | 顺序查找-重复值策略 | SEQ_DUPLICATE_POLICY | 3 | MEDIUM | 重复元素时按业务返回第一个或全部 | 首次命中/全量收集 | KP_SEARCH_002 | KP_SEARCH_007 (COMPARISON, 3) |
| KP_SEARCH_018 | 顺序查找-空表处理 | SEQ_EMPTY_LIST | 3 | EASY | 空集合应直接返回失败 | 边界判定 | KP_SEARCH_002 | KP_SEARCH_027 (COMPARISON, 2) |
| KP_SEARCH_019 | 顺序查找-单元素处理 | SEQ_SINGLE_ELEMENT | 3 | EASY | 只有一个元素时仍按同一流程处理 | 一致性实现 | KP_SEARCH_002 | KP_SEARCH_039 (COMPARISON, 2) |
| KP_SEARCH_020 | 顺序查找-索引越界防护 | SEQ_BOUNDARY_GUARD | 3 | MEDIUM | 防止循环变量越界访问 | 循环边界检查 | KP_SEARCH_002 | KP_SEARCH_039 (COMPARISON, 3) |
| KP_SEARCH_021 | 顺序查找-提前终止条件 | SEQ_EARLY_STOP | 3 | MEDIUM | 有序数据可在当前值大于目标时提前结束 | 有序优化思路 | KP_SEARCH_002 | KP_SEARCH_005 (PREREQUISITE, 3) |
| KP_SEARCH_022 | 顺序查找-有序数组应用 | SEQ_ORDERED_ARRAY_CASE | 3 | EASY | 虽可用但通常不如二分高效 | 作为基线算法 | KP_SEARCH_002 | KP_SEARCH_005 (COMPARISON, 5) |
| KP_SEARCH_023 | 顺序查找-链表应用 | SEQ_LINKED_LIST_CASE | 3 | EASY | 链表天然适配顺序扫描 | 无随机访问限制 | KP_SEARCH_002 | KP_LL_003 (PREREQUISITE, 4) |
| KP_SEARCH_024 | 顺序查找-哨兵实现细节 | SEQ_SENTINEL_DETAIL | 3 | MEDIUM | 将目标值放在末尾可减少边界判断次数 | 分支优化 | KP_SEARCH_003 | KP_SEARCH_006 (COMPARISON, 2) |
| KP_SEARCH_025 | 顺序查找-时间复杂度证明 | SEQ_TIME_PROOF | 3 | MEDIUM | 比较次数与n呈线性关系 | 最好1最坏n平均n/2 | KP_SEARCH_002 | KP_SEARCH_015 (EXTENSION, 2) |
| KP_SEARCH_026 | 顺序查找-空间复杂度 | SEQ_SPACE_COMPLEXITY | 3 | EASY | 一般只用常量额外空间 | 空间O(1) | KP_SEARCH_002 | KP_SEARCH_010 (COMPARISON, 2) |
| KP_SEARCH_027 | 顺序查找-失败成本 | SEQ_FAILURE_COST | 3 | MEDIUM | 找不到目标时成本最高 | 全表扫描 | KP_SEARCH_002 | KP_SEARCH_010 (COMPARISON, 3) |
| KP_SEARCH_028 | 顺序查找-平均性能估计 | SEQ_AVERAGE_PERFORMANCE | 3 | MEDIUM | 通过ASL估计平均比较次数 | 成功与失败分开估计 | KP_SEARCH_002 | KP_SEARCH_010 (COMPARISON, 3) |
| KP_SEARCH_029 | 顺序查找-多条件匹配 | SEQ_MULTI_CONDITION | 3 | MEDIUM | 支持按多个字段组合过滤后查找 | 业务规则查找 | KP_SEARCH_002 | KP_SEARCH_033 (COMPARISON, 3) |
| KP_SEARCH_030 | 顺序查找-业务案例日志检索 | SEQ_CASE_LOG_QUERY | 3 | EASY | 在小规模日志片段中找关键字 | 低成本方案 | KP_SEARCH_002 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_031 | 顺序查找-业务案例待办检索 | SEQ_CASE_TODO_QUERY | 3 | EASY | 在个人待办中查某任务 | 数据量小可直接线扫 | KP_SEARCH_002 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_032 | 二分查找-有序前提验证 | BIN_SORTED_PRECHECK | 3 | MEDIUM | 使用二分前需确认数据有序 | 前置检查 | KP_SEARCH_005 | KP_SEARCH_015 (COMPARISON, 3) |
| KP_SEARCH_033 | 二分查找-单调性理解 | BIN_MONOTONICITY | 3 | MEDIUM | 只要满足单调关系即可二分 | 单调判定函数 | KP_SEARCH_005 | KP_SEARCH_035 (EXTENSION, 4) |
| KP_SEARCH_034 | 二分查找-左右边界初始化 | BIN_BOUNDARY_INIT | 3 | MEDIUM | left/right初值决定区间含义 | 开闭区间一致性 | KP_SEARCH_006 | KP_SEARCH_039 (PREREQUISITE, 4) |
| KP_SEARCH_035 | 二分查找-mid防溢出 | BIN_MID_OVERFLOW_GUARD | 3 | MEDIUM | mid建议用left+(right-left)/2 | 安全写法 | KP_SEARCH_006 | KP_SEARCH_024 (COMPARISON, 2) |
| KP_SEARCH_036 | 二分查找-循环终止设计 | BIN_LOOP_TERMINATION | 3 | MEDIUM | 明确while条件防死循环 | left<=right或left<right | KP_SEARCH_006 | KP_SEARCH_039 (PREREQUISITE, 4) |
| KP_SEARCH_037 | 二分查找-命中后处理 | BIN_HIT_HANDLING | 3 | EASY | 命中即返回或继续收缩找边界 | 返回策略 | KP_SEARCH_007 | KP_SEARCH_017 (COMPARISON, 3) |
| KP_SEARCH_038 | 二分查找-未命中返回策略 | BIN_MISS_RETURN | 3 | EASY | 未命中可返回-1或插入位置 | 统一API行为 | KP_SEARCH_006 | KP_SEARCH_033 (EXTENSION, 3) |
| KP_SEARCH_039 | 二分查找-常见错误清单 | BIN_ERROR_CHECKLIST | 3 | MEDIUM | 收录越界、死循环、边界错位等典型错误 | 调试清单 | KP_SEARCH_006 | KP_SEARCH_014 (PREREQUISITE, 3) |
| KP_SEARCH_040 | 二分查找-首个等于实现 | BIN_FIRST_EQUAL_IMPL | 3 | HARD | 在重复值中定位第一个等于目标的位置 | 左边界收缩 | KP_SEARCH_007 | KP_SEARCH_017 (COMPARISON, 4) |
| KP_SEARCH_041 | 二分查找-最后等于实现 | BIN_LAST_EQUAL_IMPL | 3 | HARD | 在重复值中定位最后一个等于目标的位置 | 右边界收缩 | KP_SEARCH_007 | KP_SEARCH_040 (EXTENSION, 3) |
| KP_SEARCH_042 | 二分查找-首个大于等于实现 | BIN_FIRST_GE_IMPL | 3 | HARD | lower_bound模式 | 左侧可行边界 | KP_SEARCH_007 | KP_SEARCH_038 (EXTENSION, 3) |
| KP_SEARCH_043 | 二分查找-最后小于等于实现 | BIN_LAST_LE_IMPL | 3 | HARD | upper_bound变形 | 右侧可行边界 | KP_SEARCH_007 | KP_SEARCH_042 (COMPARISON, 3) |
| KP_SEARCH_044 | 二分查找-插入位置计算 | BIN_INSERT_POSITION | 3 | MEDIUM | 用二分得到有序插入点 | 有序维护 | KP_SEARCH_006 | KP_SEARCH_042 (PREREQUISITE, 3) |
| KP_SEARCH_045 | 二分查找-答案空间二分 | BIN_ANSWER_SEARCH | 3 | HARD | 对可行性问题进行二分求最优值 | 判定函数+边界 | KP_SEARCH_005 | KP_SEARCH_033 (PREREQUISITE, 4) |
| KP_SEARCH_046 | 二分查找-浮点数二分 | BIN_FLOATING_POINT | 3 | HARD | 在实数区间按精度eps逼近 | 精度控制 | KP_SEARCH_005 | KP_SEARCH_045 (EXTENSION, 3) |
| KP_SEARCH_047 | 二分查找-业务案例词典检索 | BIN_CASE_DICT | 3 | EASY | 在排序词典中查词条 | 静态有序数据 | KP_SEARCH_005 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_048 | 二分查找-业务案例分数线定位 | BIN_CASE_SCORE_LINE | 3 | EASY | 在分数列表中定位达标边界 | 边界查找典型场景 | KP_SEARCH_007 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_049 | 哈希查找-键到地址映射 | HASH_KEY_TO_ADDRESS | 3 | MEDIUM | 将键映射为数组槽位下标 | 直接定位思想 | KP_SEARCH_008 | KP_SEARCH_050 (PREREQUISITE, 4) |
| KP_SEARCH_050 | 哈希函数-均匀分布 | HASH_UNIFORM_DISTRIBUTION | 3 | HARD | 好哈希函数应尽量均匀分散键 | 降低冲突概率 | KP_SEARCH_008 | KP_SEARCH_054 (PREREQUISITE, 4) |
| KP_SEARCH_051 | 哈希函数-计算开销 | HASH_COMPUTE_COST | 3 | MEDIUM | 哈希函数应在均匀性与速度间平衡 | 函数选择权衡 | KP_SEARCH_008 | KP_SEARCH_057 (EXTENSION, 3) |
| KP_SEARCH_052 | 哈希冲突-定义 | HASH_COLLISION_DEFINITION | 3 | EASY | 不同键映射到同一槽位称为冲突 | 冲突不可完全避免 | KP_SEARCH_009 | KP_SEARCH_053 (EXTENSION, 2) |
| KP_SEARCH_053 | 哈希冲突-开放定址法 | HASH_OPEN_ADDRESSING | 3 | HARD | 冲突时在数组中继续探测空位 | 线性/二次探测 | KP_SEARCH_009 | KP_SEARCH_056 (COMPARISON, 3) |
| KP_SEARCH_054 | 哈希冲突-链地址法 | HASH_CHAIN_ADDRESSING | 3 | MEDIUM | 每个槽位维护链表存放冲突元素 | 删除友好 | KP_SEARCH_009 | KP_SEARCH_023 (COMPARISON, 3) |
| KP_SEARCH_055 | 哈希冲突-再哈希法 | HASH_DOUBLE_HASHING | 3 | HARD | 发生冲突时用第二函数再计算地址 | 减少聚集 | KP_SEARCH_009 | KP_SEARCH_053 (EXTENSION, 3) |
| KP_SEARCH_056 | 哈希探测-线性探测 | HASH_LINEAR_PROBING | 3 | MEDIUM | 按固定步长向后探测 | 易实现但易聚集 | KP_SEARCH_053 | KP_SEARCH_057 (COMPARISON, 2) |
| KP_SEARCH_057 | 哈希探测-二次探测 | HASH_QUADRATIC_PROBING | 3 | HARD | 按平方步长探测 | 降低主聚集 | KP_SEARCH_053 | KP_SEARCH_056 (COMPARISON, 2) |
| KP_SEARCH_058 | 哈希装填因子阈值 | HASH_LOAD_FACTOR_THRESHOLD | 3 | MEDIUM | 装填因子过高需扩容 | 常见阈值约0.75 | KP_SEARCH_010 | KP_SEARCH_059 (PREREQUISITE, 4) |
| KP_SEARCH_059 | 哈希扩容与重建 | HASH_RESIZE_REBUILD | 3 | HARD | 扩容后重算位置并迁移元素 | 重哈希成本 | KP_SEARCH_010 | KP_SEARCH_057 (COMPARISON, 3) |
| KP_SEARCH_060 | 哈希删除-墓碑标记 | HASH_TOMBSTONE_DELETE | 3 | HARD | 开放定址删除常用墓碑避免查询链断裂 | 删除策略 | KP_SEARCH_009 | KP_SEARCH_059 (EXTENSION, 3) |
| KP_SEARCH_061 | 哈希查找-平均复杂度 | HASH_AVG_COMPLEXITY | 3 | MEDIUM | 在分布良好时平均查找接近O(1) | 平均性能 | KP_SEARCH_010 | KP_SEARCH_025 (COMPARISON, 4) |
| KP_SEARCH_062 | 哈希查找-最坏复杂度 | HASH_WORST_COMPLEXITY | 3 | HARD | 冲突严重时可能退化到O(n) | 极端情况识别 | KP_SEARCH_010 | KP_SEARCH_027 (COMPARISON, 3) |
| KP_SEARCH_063 | 哈希查找-案例用户登录 | HASH_CASE_LOGIN | 3 | EASY | 用户名快速映射到账户记录 | 高频精确查找 | KP_SEARCH_008 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_064 | 哈希查找-案例缓存系统 | HASH_CASE_CACHE | 3 | EASY | 缓存key快速命中value | 读多写少场景 | KP_SEARCH_008 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_065 | 哈希查找-案例字典映射 | HASH_CASE_DICTIONARY | 3 | EASY | 单词到释义的键值映射 | 典型映射检索 | KP_SEARCH_008 | KP_SEARCH_014 (PREREQUISITE, 2) |
| KP_SEARCH_066 | 树表查找-BST定义 | TREE_BST_DEFINITION | 3 | MEDIUM | BST满足左子树键小于根、右子树键大于根 | 有序查找基础 | KP_SEARCH_011 | KP_TREE_002 (PREREQUISITE, 5) |
| KP_SEARCH_067 | 树表查找-BST查找路径 | TREE_BST_LOOKUP_PATH | 3 | MEDIUM | 比较后只进入一侧子树 | 路径长度取决于树高 | KP_SEARCH_011 | KP_SEARCH_078 (EXTENSION, 3) |
| KP_SEARCH_068 | 树表查找-BST插入 | TREE_BST_INSERT | 3 | MEDIUM | 按查找路径找到空位插入节点 | 保持BST性质 | KP_SEARCH_013 | KP_SEARCH_066 (PREREQUISITE, 3) |
| KP_SEARCH_069 | 树表查找-BST删除 | TREE_BST_DELETE | 3 | HARD | 删除分叶子、单子树、双子树三类 | 后继替换 | KP_SEARCH_013 | KP_SEARCH_068 (PREREQUISITE, 4) |
| KP_SEARCH_070 | 树表查找-BST最坏退化 | TREE_BST_DEGENERATE | 3 | MEDIUM | 连续有序插入会使树退化成链 | 最坏O(n) | KP_SEARCH_011 | KP_SEARCH_079 (PREREQUISITE, 3) |
| KP_SEARCH_071 | 树表查找-AVL平衡因子 | TREE_AVL_BALANCE_FACTOR | 3 | HARD | AVL要求任一节点平衡因子在-1到1 | 维持平衡核心 | KP_SEARCH_012 | KP_SEARCH_070 (COMPARISON, 4) |
| KP_SEARCH_072 | 树表查找-AVL LL旋转 | TREE_AVL_LL_ROTATION | 3 | HARD | 左左失衡通过右旋恢复平衡 | 单旋转 | KP_SEARCH_012 | KP_SEARCH_073 (COMPARISON, 2) |
| KP_SEARCH_073 | 树表查找-AVL RR旋转 | TREE_AVL_RR_ROTATION | 3 | HARD | 右右失衡通过左旋恢复平衡 | 单旋转 | KP_SEARCH_012 | KP_SEARCH_072 (COMPARISON, 2) |
| KP_SEARCH_074 | 树表查找-AVL LR旋转 | TREE_AVL_LR_ROTATION | 3 | HARD | 左右失衡先左旋后右旋 | 双旋转 | KP_SEARCH_012 | KP_SEARCH_075 (COMPARISON, 2) |
| KP_SEARCH_075 | 树表查找-AVL RL旋转 | TREE_AVL_RL_ROTATION | 3 | HARD | 右左失衡先右旋后左旋 | 双旋转 | KP_SEARCH_012 | KP_SEARCH_074 (COMPARISON, 2) |
| KP_SEARCH_076 | 树表查找-AVL插入维护 | TREE_AVL_INSERT_MAINTAIN | 3 | HARD | 插入后回溯更新高度并按需旋转 | 平衡恢复流程 | KP_SEARCH_013 | KP_SEARCH_071 (PREREQUISITE, 4) |
| KP_SEARCH_077 | 树表查找-AVL删除维护 | TREE_AVL_DELETE_MAINTAIN | 3 | HARD | 删除后可能多次失衡，逐层修复 | 多次旋转场景 | KP_SEARCH_013 | KP_SEARCH_076 (PREREQUISITE, 4) |
| KP_SEARCH_078 | 树表查找-树高与性能 | TREE_HEIGHT_PERFORMANCE | 3 | MEDIUM | 树越矮查找路径越短 | 复杂度与高度相关 | KP_SEARCH_011 | KP_SEARCH_026 (COMPARISON, 3) |
| KP_SEARCH_079 | 树表查找-复杂度对比 | TREE_COMPLEXITY_COMPARE | 3 | MEDIUM | BST平均O(logn)最坏O(n)，AVL稳定O(logn) | 稳定性对比 | KP_SEARCH_012 | KP_SEARCH_010 (COMPARISON, 3) |
| KP_SEARCH_080 | 树表查找-递归实现 | TREE_RECURSIVE_IMPL | 3 | MEDIUM | 树操作常用递归表达 | 代码直观 | KP_SEARCH_013 | KP_SEARCH_081 (COMPARISON, 2) |
| KP_SEARCH_081 | 树表查找-迭代实现 | TREE_ITERATIVE_IMPL | 3 | MEDIUM | 通过循环和父指针实现树查找 | 控制栈开销 | KP_SEARCH_013 | KP_SEARCH_080 (COMPARISON, 2) |
| KP_SEARCH_082 | 树表查找-业务案例区间检索 | TREE_CASE_RANGE_QUERY | 3 | EASY | 在动态有序数据中做区间查询 | 价格区间、时间区间检索 | KP_SEARCH_011 | KP_SEARCH_014 (PREREQUISITE, 2) |

**负责人**: 马之涵  
**最后更新**: 2026-04-26

---

## 模块: 排序 (SORT)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_SORT_001 | 排序 | SORT | 1 | MEDIUM | 排序的基本概念 | 排序算法分类 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 关联关系说明

### 关系类型
- **PREREQUISITE**: 前置知识 (学习A之前需要先学习B)
- **EXTENSION**: 扩展知识 (学习A后可以进一步学习B)
- **COMPARISON**: 对比知识 (A和B可以对比学习)

### 关联强度
- **5**: 强关联 (必须一起学习)
- **4**: 较强关联
- **3**: 中等关联
- **2**: 较弱关联
- **1**: 弱关联

### 填写示例
```
KP_LL_002 (数组) -[PREREQUISITE, strength:5]-> KP_LL_003 (链表)
说明: 学习链表之前需要先掌握数组 (强度5)
```

---

## 编号规则

1. **模块前缀**: KP_SET_, KP_LL_, KP_TREE_, KP_GRAPH_, KP_SEARCH_, KP_SORT_
2. **序号**: 3位数字，不足补零 (001-999)
3. **编号顺序**: 按层级从上到下，同层级按逻辑顺序
4. **预留空号**: 便于后续插入新知识点

---

## 更新记录

| 日期 | 修改人 | 修改内容 |
|------|--------|----------|
| 2024-XX-XX | XXX | 初始版本 |
| 2026-04-26 | mazhi | 完善查找模块知识点，新增顺序查找、二分查找、哈希查找、BST/AVL查找及应用选型条目 |
| 2026-04-26 | mazhi | 将查找模块按知识图谱建模细化到原理、实现、性能、变体和应用选型层级 |
| 2026-04-26 | mazhi | 为查找模块补充零基础可读解释与实例，强化“看得懂、会选型、能落地” |
| 2026-04-26 | mazhi | 将查找模块扩展为超细粒度节点，补齐顺序/二分/哈希/树表各20条以上并增强互相关联 |
| | | |
