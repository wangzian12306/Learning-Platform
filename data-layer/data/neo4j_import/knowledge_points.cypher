// 知识点数据 - 集合模块
// 负责人: XXX
// 日期: 2026-XX-XX

// 创建根节点
CREATE (kp1:KnowledgePoint {
  neo4j_id: 'KP_SET_001',
  name: '集合',
  code: 'SET',
  module: 'SET',
  level: 1,
  difficulty: 'EASY',
  description: '集合是数学中的基本概念，表示具有某种特定性质的对象的总体',
  core_points: '集合定义、集合表示、集合运算'
});

// 创建子节点
CREATE (kp2:KnowledgePoint {
  neo4j_id: 'KP_SET_002',
  name: '集合运算',
  code: 'SET_OPERATION',
  module: 'SET',
  level: 2,
  difficulty: 'MEDIUM',
  description: '集合的基本运算包括并集、交集、差集等',
  core_points: '并集、交集、差集、补集'
});

// 创建层级关系
MATCH (parent:KnowledgePoint {neo4j_id: 'KP_SET_001'}),
      (child:KnowledgePoint {neo4j_id: 'KP_SET_002'})
CREATE (parent)-[:PARENT_OF {order: 1}]->(child);
