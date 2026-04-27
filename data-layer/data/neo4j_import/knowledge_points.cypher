// 知识点数据 - 集合模块
// 负责人: 张佳宇
// 日期: 2026-04-27

// =========================
// 1 创建/更新节点
// =========================
MERGE (kp001:KnowledgePoint {neo4j_id: 'KP_SET_001'})
SET kp001.name = '集合', kp001.code = 'SET', kp001.module = 'SET', kp001.level = 1, kp001.difficulty = 'EASY',
    kp001.description = '由确定元素构成的整体，是离散数学与数据结构中的基础抽象',
    kp001.core_points = '定义域、元素、隶属关系、去重语义';

MERGE (kp002:KnowledgePoint {neo4j_id: 'KP_SET_002'})
SET kp002.name = '集合表示法', kp002.code = 'SET_REPRESENTATION', kp002.module = 'SET', kp002.level = 3, kp002.difficulty = 'EASY',
    kp002.description = '常见表示方式包括列举法和描述法',
    kp002.core_points = '列举法、描述法、等价表达';

MERGE (kp003:KnowledgePoint {neo4j_id: 'KP_SET_003'})
SET kp003.name = '元素隶属关系', kp003.code = 'ELEMENT_MEMBERSHIP', kp003.module = 'SET', kp003.level = 3, kp003.difficulty = 'EASY',
    kp003.description = '用属于与不属于描述元素和集合关系',
    kp003.core_points = '符号∈/∉、判定条件';

MERGE (kp004:KnowledgePoint {neo4j_id: 'KP_SET_004'})
SET kp004.name = '集合相等判定', kp004.code = 'SET_EQUALITY', kp004.module = 'SET', kp004.level = 3, kp004.difficulty = 'MEDIUM',
    kp004.description = '两集合元素完全相同则相等，与顺序和重复无关',
    kp004.core_points = '双向包含、与数组相等区别';

MERGE (kp005:KnowledgePoint {neo4j_id: 'KP_SET_005'})
SET kp005.name = '空集与全集', kp005.code = 'EMPTY_AND_UNIVERSAL_SET', kp005.module = 'SET', kp005.level = 3, kp005.difficulty = 'EASY',
    kp005.description = '空集不含任何元素，全集表示讨论范围内全部元素',
    kp005.core_points = '空集符号、全集上下文依赖';

MERGE (kp006:KnowledgePoint {neo4j_id: 'KP_SET_006'})
SET kp006.name = '子集与真子集', kp006.code = 'SUBSET_AND_PROPER_SUBSET', kp006.module = 'SET', kp006.level = 3, kp006.difficulty = 'MEDIUM',
    kp006.description = '子集关系刻画集合层级，真子集要求不相等',
    kp006.core_points = '包含关系、反例判断';

MERGE (kp007:KnowledgePoint {neo4j_id: 'KP_SET_007'})
SET kp007.name = '幂集', kp007.code = 'POWER_SET', kp007.module = 'SET', kp007.level = 3, kp007.difficulty = 'MEDIUM',
    kp007.description = '幂集由原集合全部子集组成，规模呈指数增长',
    kp007.core_points = '幂集定义、元素个数2^n';

MERGE (kp008:KnowledgePoint {neo4j_id: 'KP_SET_008'})
SET kp008.name = '集合基本性质总览', kp008.code = 'SET_PROPERTIES_OVERVIEW', kp008.module = 'SET', kp008.level = 2, kp008.difficulty = 'MEDIUM',
    kp008.description = '集合具备无序性、互异性、确定性等核心性质',
    kp008.core_points = '抽象语义与实现影响';

MERGE (kp009:KnowledgePoint {neo4j_id: 'KP_SET_009'})
SET kp009.name = '无序性', kp009.code = 'SET_UNORDEREDNESS', kp009.module = 'SET', kp009.level = 3, kp009.difficulty = 'EASY',
    kp009.description = '集合不关心元素先后顺序',
    kp009.core_points = '与线性结构对比、判等影响';

MERGE (kp010:KnowledgePoint {neo4j_id: 'KP_SET_010'})
SET kp010.name = '互异性', kp010.code = 'SET_UNIQUENESS', kp010.module = 'SET', kp010.level = 3, kp010.difficulty = 'EASY',
    kp010.description = '集合中同一元素只保留一次',
    kp010.core_points = '去重规则、重复处理';

MERGE (kp011:KnowledgePoint {neo4j_id: 'KP_SET_011'})
SET kp011.name = '确定性', kp011.code = 'SET_WELL_DEFINEDNESS', kp011.module = 'SET', kp011.level = 3, kp011.difficulty = 'MEDIUM',
    kp011.description = '任一对象能明确判断是否属于集合',
    kp011.core_points = '判定规则、边界定义';

MERGE (kp012:KnowledgePoint {neo4j_id: 'KP_SET_012'})
SET kp012.name = '集合存储结构总览', kp012.code = 'SET_STORAGE_OVERVIEW', kp012.module = 'SET', kp012.level = 2, kp012.difficulty = 'MEDIUM',
    kp012.description = '集合可用顺序、链式、哈希、位图等结构实现',
    kp012.core_points = '空间效率、查询性能、适用场景';

MERGE (kp013:KnowledgePoint {neo4j_id: 'KP_SET_013'})
SET kp013.name = '顺序存储实现集合', kp013.code = 'SET_ARRAY_STORAGE', kp013.module = 'SET', kp013.level = 3, kp013.difficulty = 'EASY',
    kp013.description = '用数组或动态数组维护集合，常用于小规模场景',
    kp013.core_points = '线性查找、插删搬移、去重策略';

MERGE (kp014:KnowledgePoint {neo4j_id: 'KP_SET_014'})
SET kp014.name = '链式存储实现集合', kp014.code = 'SET_LINKED_STORAGE', kp014.module = 'SET', kp014.level = 3, kp014.difficulty = 'MEDIUM',
    kp014.description = '用链表维护集合元素，插删灵活但查询较慢',
    kp014.core_points = '指针维护、遍历判重';

MERGE (kp015:KnowledgePoint {neo4j_id: 'KP_SET_015'})
SET kp015.name = '哈希存储实现集合', kp015.code = 'SET_HASH_STORAGE', kp015.module = 'SET', kp015.level = 3, kp015.difficulty = 'HARD',
    kp015.description = '基于哈希表可实现近似O(1)成员查询',
    kp015.core_points = '哈希函数、冲突处理、负载因子';

MERGE (kp016:KnowledgePoint {neo4j_id: 'KP_SET_016'})
SET kp016.name = '位图实现集合', kp016.code = 'SET_BITMAP_STORAGE', kp016.module = 'SET', kp016.level = 3, kp016.difficulty = 'MEDIUM',
    kp016.description = '用位向量表示整数域集合，节省空间且操作快',
    kp016.core_points = '位运算、固定值域、压缩存储';

MERGE (kp017:KnowledgePoint {neo4j_id: 'KP_SET_017'})
SET kp017.name = '集合基本操作总览', kp017.code = 'SET_OPERATIONS_OVERVIEW', kp017.module = 'SET', kp017.level = 2, kp017.difficulty = 'EASY',
    kp017.description = '集合操作包括增删查与代数运算，是后续算法基础',
    kp017.core_points = '成员操作、集合运算、复杂度';

MERGE (kp018:KnowledgePoint {neo4j_id: 'KP_SET_018'})
SET kp018.name = '插入元素', kp018.code = 'SET_INSERT', kp018.module = 'SET', kp018.level = 3, kp018.difficulty = 'EASY',
    kp018.description = '向集合加入元素时需维护互异性约束',
    kp018.core_points = '先判重后插入、幂等更新';

MERGE (kp019:KnowledgePoint {neo4j_id: 'KP_SET_019'})
SET kp019.name = '删除元素', kp019.code = 'SET_DELETE', kp019.module = 'SET', kp019.level = 3, kp019.difficulty = 'EASY',
    kp019.description = '从集合中移除指定元素并维护结构一致性',
    kp019.core_points = '删除不存在元素处理、稳定性';

MERGE (kp020:KnowledgePoint {neo4j_id: 'KP_SET_020'})
SET kp020.name = '成员判定', kp020.code = 'SET_MEMBERSHIP_QUERY', kp020.module = 'SET', kp020.level = 3, kp020.difficulty = 'EASY',
    kp020.description = '判断元素是否属于集合，是最基础查询能力',
    kp020.core_points = 'contains语义、平均/最坏复杂度';

MERGE (kp021:KnowledgePoint {neo4j_id: 'KP_SET_021'})
SET kp021.name = '并集', kp021.code = 'SET_UNION', kp021.module = 'SET', kp021.level = 3, kp021.difficulty = 'EASY',
    kp021.description = '并集包含两个集合所有元素且去重',
    kp021.core_points = '合并策略、去重语义';

MERGE (kp022:KnowledgePoint {neo4j_id: 'KP_SET_022'})
SET kp022.name = '交集', kp022.code = 'SET_INTERSECTION', kp022.module = 'SET', kp022.level = 3, kp022.difficulty = 'EASY',
    kp022.description = '交集保留两个集合共同元素',
    kp022.core_points = '双集合匹配、过滤思想';

MERGE (kp023:KnowledgePoint {neo4j_id: 'KP_SET_023'})
SET kp023.name = '差集', kp023.code = 'SET_DIFFERENCE', kp023.module = 'SET', kp023.level = 3, kp023.difficulty = 'MEDIUM',
    kp023.description = '差集保留在A中但不在B中的元素',
    kp023.core_points = '方向性、互补关系';

MERGE (kp024:KnowledgePoint {neo4j_id: 'KP_SET_024'})
SET kp024.name = '对称差', kp024.code = 'SET_SYMMETRIC_DIFFERENCE', kp024.module = 'SET', kp024.level = 3, kp024.difficulty = 'MEDIUM',
    kp024.description = '对称差保留仅属于其中一个集合的元素',
    kp024.core_points = '与并交差关系变换';

MERGE (kp025:KnowledgePoint {neo4j_id: 'KP_SET_025'})
SET kp025.name = '补集', kp025.code = 'SET_COMPLEMENT', kp025.module = 'SET', kp025.level = 3, kp025.difficulty = 'MEDIUM',
    kp025.description = '补集依赖全集定义，表示全集中不属于目标集合的部分',
    kp025.core_points = '上下文全集、德摩根律';

MERGE (kp026:KnowledgePoint {neo4j_id: 'KP_SET_026'})
SET kp026.name = '笛卡尔积', kp026.code = 'SET_CARTESIAN_PRODUCT', kp026.module = 'SET', kp026.level = 3, kp026.difficulty = 'MEDIUM',
    kp026.description = '笛卡尔积生成有序对集合，连接集合与关系概念',
    kp026.core_points = '有序对、规模乘法增长';

MERGE (kp027:KnowledgePoint {neo4j_id: 'KP_SET_027'})
SET kp027.name = '集合运算律', kp027.code = 'SET_ALGEBRA_LAWS', kp027.module = 'SET', kp027.level = 3, kp027.difficulty = 'HARD',
    kp027.description = '交换律、结合律、分配律、德摩根律支撑推导与化简',
    kp027.core_points = '公式变换、等价证明';

MERGE (kp028:KnowledgePoint {neo4j_id: 'KP_SET_028'})
SET kp028.name = '集合操作复杂度分析', kp028.code = 'SET_OPERATION_COMPLEXITY', kp028.module = 'SET', kp028.level = 3, kp028.difficulty = 'MEDIUM',
    kp028.description = '同一操作在不同存储结构下复杂度差异明显',
    kp028.core_points = '时间复杂度、空间复杂度、选型权衡';

MERGE (kp029:KnowledgePoint {neo4j_id: 'KP_SET_029'})
SET kp029.name = '集合应用与选型', kp029.code = 'SET_APPLICATION_AND_SELECTION', kp029.module = 'SET', kp029.level = 2, kp029.difficulty = 'MEDIUM',
    kp029.description = '根据数据规模、值域和操作频率选择集合实现',
    kp029.core_points = '小规模/大规模、静态/动态、高频查询';

MERGE (kp030:KnowledgePoint {neo4j_id: 'KP_SET_030'})
SET kp030.name = '典型问题-数据去重', kp030.code = 'SET_CASE_DEDUPLICATION', kp030.module = 'SET', kp030.level = 3, kp030.difficulty = 'EASY',
    kp030.description = '使用集合快速去除重复元素，是最常见业务场景',
    kp030.core_points = '去重流程、稳定输出策略';

MERGE (kp031:KnowledgePoint {neo4j_id: 'KP_SET_031'})
SET kp031.name = '典型问题-集合合并', kp031.code = 'SET_CASE_MERGE', kp031.module = 'SET', kp031.level = 3, kp031.difficulty = 'EASY',
    kp031.description = '合并多个集合并去重，常见于标签、权限、推荐等场景',
    kp031.core_points = '多源合并、冲突规约';

MERGE (kp032:KnowledgePoint {neo4j_id: 'KP_SET_032'})
SET kp032.name = '典型问题-集合查询过滤', kp032.code = 'SET_CASE_FILTERING', kp032.module = 'SET', kp032.level = 3, kp032.difficulty = 'MEDIUM',
    kp032.description = '借助集合进行黑白名单过滤和快速包含判断',
    kp032.core_points = '白名单、黑名单、预过滤';

MERGE (kp033:KnowledgePoint {neo4j_id: 'KP_SET_033'})
SET kp033.name = '典型问题-子集枚举', kp033.code = 'SET_CASE_SUBSET_ENUMERATION', kp033.module = 'SET', kp033.level = 3, kp033.difficulty = 'HARD',
    kp033.description = '子集枚举常用于回溯和状态压缩问题',
    kp033.core_points = '位掩码枚举、剪枝策略';

MERGE (kp034:KnowledgePoint {neo4j_id: 'KP_SET_034'})
SET kp034.name = '典型问题-幂集生成', kp034.code = 'SET_CASE_POWER_SET_GENERATION', kp034.module = 'SET', kp034.level = 3, kp034.difficulty = 'HARD',
    kp034.description = '通过回溯或位运算生成幂集，关注复杂度爆炸',
    kp034.core_points = '递归构造、位运算技巧';

MERGE (kp035:KnowledgePoint {neo4j_id: 'KP_SET_035'})
SET kp035.name = '多重集合与集合对比', kp035.code = 'MULTISET_VS_SET', kp035.module = 'SET', kp035.level = 3, kp035.difficulty = 'MEDIUM',
    kp035.description = '多重集合允许重复元素，和集合语义不同',
    kp035.core_points = '计数模型、应用场景差异';

MERGE (kp036:KnowledgePoint {neo4j_id: 'KP_SET_036'})
SET kp036.name = '集合与线性表对比', kp036.code = 'SET_VS_LINEAR_LIST', kp036.module = 'SET', kp036.level = 3, kp036.difficulty = 'MEDIUM',
    kp036.description = '集合强调成员语义，线性表强调次序与位置',
    kp036.core_points = '抽象差异、操作差异';

MERGE (kp037:KnowledgePoint {neo4j_id: 'KP_SET_037'})
SET kp037.name = '常见边界与错误处理', kp037.code = 'SET_EDGE_CASES', kp037.module = 'SET', kp037.level = 3, kp037.difficulty = 'MEDIUM',
    kp037.description = '处理空集、重复输入、非法值域等边界是工程落地关键',
    kp037.core_points = '空输入、防重复、异常约定';

MERGE (kp038:KnowledgePoint {neo4j_id: 'KP_SET_038'})
SET kp038.name = '空集相关边界处理', kp038.code = 'SET_EMPTY_CASE_HANDLING', kp038.module = 'SET', kp038.level = 3, kp038.difficulty = 'EASY',
    kp038.description = '空集参与运算时结果有固定规律，应在实现中显式覆盖',
    kp038.core_points = '空集并交差规则';

MERGE (kp039:KnowledgePoint {neo4j_id: 'KP_SET_039'})
SET kp039.name = '重复输入处理策略', kp039.code = 'SET_DUPLICATE_INPUT_POLICY', kp039.module = 'SET', kp039.level = 3, kp039.difficulty = 'EASY',
    kp039.description = '面对重复输入时应保持集合语义一致并定义输出约定',
    kp039.core_points = '幂等行为、日志记录策略';

MERGE (kp040:KnowledgePoint {neo4j_id: 'KP_SET_040'})
SET kp040.name = '集合实践设计清单', kp040.code = 'SET_IMPLEMENTATION_CHECKLIST', kp040.module = 'SET', kp040.level = 2, kp040.difficulty = 'MEDIUM',
    kp040.description = '实现集合前确认值域、操作比例、并发需求和持久化方案',
    kp040.core_points = '设计前检查项、性能目标、测试要点';

// =========================
// 2 创建/更新层级关系 PARENT_OF
// =========================
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_002'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_003'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 2;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_004'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 3;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_005'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 4;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_006'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 5;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_006'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_007'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_008'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 6;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_008'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_009'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_008'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 2;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_008'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_011'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 3;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_012'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 7;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_013'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_014'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 2;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_015'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 3;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_016'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 4;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_017'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 8;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_018'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_019'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 2;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_020'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 3;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_021'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 4;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_022'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 5;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_023'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 6;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_024'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 7;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_025'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 8;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_026'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 9;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_027'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 10;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_028'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 11;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_029'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 9;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_030'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_031'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 2;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_032'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 3;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_033'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 4;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_034'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 5;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_035'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 10;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_001'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_036'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 11;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_037'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 12;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_037'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_038'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 1;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_037'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_039'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 2;
MATCH (p:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (c:KnowledgePoint {neo4j_id: 'KP_SET_040'}) MERGE (p)-[r:PARENT_OF]->(c) SET r.order = 6;

// =========================
// 3 创建/更新关联关系 RELATED_TO
// =========================
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_002'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_003'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_003'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_020'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_004'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_009'}) MERGE (a)-[r:RELATED_TO {type: 'COMPARISON'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_005'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_025'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_006'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_007'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_007'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_033'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_008'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_009'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_008'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_008'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_011'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_009'}), (b:KnowledgePoint {neo4j_id: 'KP_LL_001'}) MERGE (a)-[r:RELATED_TO {type: 'COMPARISON'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_010'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_030'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_011'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_003'}) MERGE (a)-[r:RELATED_TO {type: 'COMPARISON'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_013'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_014'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_015'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_012'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_016'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_013'}), (b:KnowledgePoint {neo4j_id: 'KP_LL_002'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_013'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_018'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_014'}), (b:KnowledgePoint {neo4j_id: 'KP_LL_003'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_014'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_019'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_015'}), (b:KnowledgePoint {neo4j_id: 'KP_SEARCH_008'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 5;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_015'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_020'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_016'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_021'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_016'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_022'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_018'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_019'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_020'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_021'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_022'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_017'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_023'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_018'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_019'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_037'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 2;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_020'}), (b:KnowledgePoint {neo4j_id: 'KP_SEARCH_001'}) MERGE (a)-[r:RELATED_TO {type: 'COMPARISON'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_021'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_021'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_028'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_022'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_020'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_022'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_028'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_023'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_025'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_024'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_021'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_024'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_022'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_025'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_005'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 5;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_026'}), (b:KnowledgePoint {neo4j_id: 'KP_GRAPH_001'}) MERGE (a)-[r:RELATED_TO {type: 'EXTENSION'}]->(b) SET r.strength = 2;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_027'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_021'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_027'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_022'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_027'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_025'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_028'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_012'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_028'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_030'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_031'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_029'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_032'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_030'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_030'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_018'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_031'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_021'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_032'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_020'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_033'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_007'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_033'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_016'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_034'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_033'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_035'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (a)-[r:RELATED_TO {type: 'COMPARISON'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_036'}), (b:KnowledgePoint {neo4j_id: 'KP_LL_001'}) MERGE (a)-[r:RELATED_TO {type: 'COMPARISON'}]->(b) SET r.strength = 5;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_037'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_038'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_037'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_039'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_038'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_005'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_039'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_010'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 4;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_040'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_012'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_040'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_028'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
MATCH (a:KnowledgePoint {neo4j_id: 'KP_SET_040'}), (b:KnowledgePoint {neo4j_id: 'KP_SET_037'}) MERGE (a)-[r:RELATED_TO {type: 'PREREQUISITE'}]->(b) SET r.strength = 3;
