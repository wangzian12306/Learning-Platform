// Neo4j Schema 定义脚本
// 执行此脚本创建索引和约束

// ============================================
// 1. 唯一约束
// ============================================

// KnowledgePoint 节点的 neo4j_id 唯一约束
CREATE CONSTRAINT knowledge_point_neo4j_id_unique IF NOT EXISTS
FOR (kp:KnowledgePoint)
REQUIRE kp.neo4j_id IS UNIQUE;

// ============================================
// 2. 索引定义
// ============================================

// 按 code 字段索引
CREATE INDEX knowledge_point_code IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.code);

// 按 module 字段索引
CREATE INDEX knowledge_point_module IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.module);

// 按 level 字段索引
CREATE INDEX knowledge_point_level IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.level);

// 按 difficulty 字段索引
CREATE INDEX knowledge_point_difficulty IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.difficulty);

// 按 mysql_id 字段索引
CREATE INDEX knowledge_point_mysql_id IF NOT EXISTS
FOR (kp:KnowledgePoint)
ON (kp.mysql_id);

// ============================================
// 3. 验证约束和索引
// ============================================

// 查看所有约束
SHOW CONSTRAINTS;

// 查看所有索引
SHOW INDEXES;

// ============================================
// 4. 测试数据 (可选，用于验证)
// ============================================

// 清除测试数据 (如果需要重新测试)
// MATCH (n) DETACH DELETE n;

// 创建测试节点
// CREATE (kp1:KnowledgePoint {
//   neo4j_id: 'KP_TEST_001',
//   name: '测试知识点1',
//   code: 'TEST_001',
//   module: 'SET',
//   level: 1,
//   difficulty: 'EASY',
//   description: '这是一个测试知识点',
//   core_points: '测试核心考点',
//   mysql_id: 999
// });

// CREATE (kp2:KnowledgePoint {
//   neo4j_id: 'KP_TEST_002',
//   name: '测试知识点2',
//   code: 'TEST_002',
//   module: 'SET',
//   level: 2,
//   difficulty: 'MEDIUM',
//   description: '这是另一个测试知识点',
//   core_points: '测试核心考点2',
//   mysql_id: 998
// });

// 创建测试关系
// MATCH (p:KnowledgePoint {neo4j_id: 'KP_TEST_001'}),
//       (c:KnowledgePoint {neo4j_id: 'KP_TEST_002'})
// CREATE (p)-[:PARENT_OF {order: 1}]->(c);

// 清理测试数据
// MATCH (kp:KnowledgePoint {neo4j_id: 'KP_TEST_001'}) DETACH DELETE kp;
// MATCH (kp:KnowledgePoint {neo4j_id: 'KP_TEST_002'}) DETACH DELETE kp;
