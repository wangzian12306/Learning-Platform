# Neo4j 数据结构定义

## 1. 节点定义 (Node Labels)

### KnowledgePoint 节点

**节点标签**: `KnowledgePoint`

**属性定义**:

| 属性名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| neo4j_id | String | 是 | 唯一标识，格式: KP_模块编码_序号 | KP_LL_001 |
| name | String | 是 | 知识点名称 | 数组 |
| code | String | 是 | 知识点编码，与MySQL保持一致 | ARRAY |
| module | String | 是 | 所属模块 | SET/LINEAR_LIST/TREE/GRAPH/SEARCH/SORT |
| level | Integer | 是 | 层级: 1-主模块, 2-子模块, 3-具体知识点 | 3 |
| difficulty | String | 是 | 难度等级 | EASY/MEDIUM/HARD |
| description | String | 否 | 知识点描述 | 数组是... |
| core_points | String | 否 | 核心考点 | 内存连续、随机访问... |
| mysql_id | Long | 是 | 对应的MySQL表knowledge_point的id | 1 |

**示例**:
```cypher
CREATE (kp:KnowledgePoint {
  neo4j_id: 'KP_LL_001',
  name: '数组',
  code: 'ARRAY',
  module: 'LINEAR_LIST',
  level: 3,
  difficulty: 'EASY',
  description: '数组是一种线性数据结构，使用连续的内存空间存储相同类型的数据',
  core_points: '内存连续、随机访问O(1)、插入删除O(n)',
  mysql_id: 1
})
```

## 2. 关系定义 (Relationship Types)

### 2.1 PARENT_OF 关系 (层级关系)

**方向**: 父节点 → 子节点

**属性定义**:

| 属性名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| order | Integer | 是 | 排序序号 | 1 |

**示例**:
```cypher
MATCH (parent:KnowledgePoint {neo4j_id: 'KP_TREE_001'}),
      (child:KnowledgePoint {neo4j_id: 'KP_TREE_002'})
CREATE (parent)-[:PARENT_OF {order: 1}]->(child)
```

**说明**: 
- 表示知识点的层级归属关系
- order 字段用于控制同一父节点下子节点的显示顺序

### 2.2 RELATED_TO 关系 (关联关系)

**方向**: 知识点A → 知识点B

**属性定义**:

| 属性名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| type | String | 是 | 关联类型 | PREREQUISITE/EXTENSION/COMPARISON |
| strength | Integer | 是 | 关联强度 (1-5) | 5 |

**关联类型说明**:
- `PREREQUISITE`: 前置知识 (学习A之前需要先学习B)
- `EXTENSION`: 扩展知识 (学习A后可以进一步学习B)
- `COMPARISON`: 对比知识 (A和B可以对比学习)

**示例**:
```cypher
MATCH (a:KnowledgePoint {neo4j_id: 'KP_LL_001'}),
      (b:KnowledgePoint {neo4j_id: 'KP_LL_002'})
CREATE (a)-[:RELATED_TO {type: 'PREREQUISITE', strength: 5}]->(b)
```

## 3. 模块编码规范

| 模块名称 | 编码 | Neo4j ID前缀 | 说明 |
|---------|------|-------------|------|
| 集合 | SET | KP_SET_ | 集合相关数据结构 |
| 线性表 | LINEAR_LIST | KP_LL_ | 数组、链表、栈、队列等 |
| 树 | TREE | KP_TREE_ | 二叉树、BST、AVL、红黑树等 |
| 图 | GRAPH | KP_GRAPH_ | 图的存储、遍历、最短路径等 |
| 查找 | SEARCH | KP_SEARCH_ | 顺序查找、二分查找、哈希查找等 |
| 排序 | SORT | KP_SORT_ | 冒泡、选择、插入、快速、归并等 |

## 4. Neo4j ID 命名规则

**格式**: `{模块前缀}{序号}`

**规则**:
- 模块前缀使用缩写 (见上表)
- 序号使用3位数字，不足补零 (001-999)
- 示例: `KP_LL_001`, `KP_TREE_015`, `KP_SORT_008`

**编号原则**:
1. 同一模块内序号唯一
2. 按知识点层级从上到下编号
3. 同层级按逻辑顺序编号
4. 预留空号便于后续插入

## 5. 索引和约束

### 5.1 唯一约束
```cypher
CREATE CONSTRAINT knowledge_point_neo4j_id_unique IF NOT EXISTS
FOR (kp:KnowledgePoint)
REQUIRE kp.neo4j_id IS UNIQUE
```

### 5.2 索引
```cypher
CREATE INDEX knowledge_point_code IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.code)

CREATE INDEX knowledge_point_module IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.module)

CREATE INDEX knowledge_point_level IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.level)

CREATE INDEX knowledge_point_difficulty IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.difficulty)
```
