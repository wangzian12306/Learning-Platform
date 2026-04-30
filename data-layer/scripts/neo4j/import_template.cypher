// Neo4j数据导入脚本模板
// 使用 CSV 文件导入知识点数据和关系

// ============================================
// 使用说明
// ============================================
// 1. 确保 CSV 文件已放置在 /import 目录
// 2. 在 Neo4j Browser 或 Cypher Shell 中执行此脚本
// 3. 如果使用 Docker，CSV 文件应在 ./data/neo4j_import/ 目录

// ============================================
// 1. 导入知识点节点
// ============================================

// 方式1: 使用 LOAD CSV (需要文件在 /import 目录)
LOAD CSV WITH HEADERS FROM 'file:///knowledge_points.csv' AS row
CREATE (kp:KnowledgePoint {
  neo4j_id: row.neo4j_id,
  name: row.name,
  code: row.code,
  module: row.module,
  level: toInteger(row.level),
  difficulty: row.difficulty,
  description: row.description,
  core_points: row.core_points,
  mysql_id: toInteger(row.mysql_id)
});

// 方式2: 使用 neo4j-admin import 命令 (适合大批量数据)
// 在终端执行:
// neo4j-admin import --nodes=/import/knowledge_points.csv \
//   --relationships=/import/parent_of.csv \
//   --relationships=/import/related_to.csv \
//   --delimiter=',' \
//   --array-delimiter='|'

// ============================================
// 2. 导入层级关系 (PARENT_OF)
// ============================================

LOAD CSV WITH HEADERS FROM 'file:///parent_of.csv' AS row
MATCH (parent:KnowledgePoint {neo4j_id: row.:START_ID}),
      (child:KnowledgePoint {neo4j_id: row.:END_ID})
CREATE (parent)-[:PARENT_OF {order: toInteger(row.order)}]->(child);

// ============================================
// 3. 导入关联关系 (RELATED_TO)
// ============================================

LOAD CSV WITH HEADERS FROM 'file:///related_to.csv' AS row
MATCH (start:KnowledgePoint {neo4j_id: row.:START_ID}),
      (end:KnowledgePoint {neo4j_id: row.:END_ID})
CREATE (start)-[:RELATED_TO {
  type: row.type,
  strength: toInteger(row.strength)
}]->(end);

// ============================================
// 4. 验证导入结果
// ============================================

// 统计知识点数量
MATCH (kp:KnowledgePoint)
RETURN count(kp) as total_knowledge_points;

// 按模块统计
MATCH (kp:KnowledgePoint)
RETURN kp.module as module, count(kp) as count
ORDER BY count DESC;

// 统计关系数量
MATCH ()-[r:PARENT_OF]->()
RETURN count(r) as parent_of_count;

MATCH ()-[r:RELATED_TO]->()
RETURN count(r) as related_to_count;

// 查看导入的示例数据
MATCH (kp:KnowledgePoint)
RETURN kp.neo4j_id, kp.name, kp.module, kp.level
LIMIT 10;

// ============================================
// 5. 清理数据 (如果需要重新导入)
// ============================================

// 警告: 此操作会删除所有数据!
// MATCH (n) DETACH DELETE n;

// ============================================
// 6. 常见错误处理
// ============================================

// 如果遇到 "CSV文件不存在" 错误:
// - 检查文件是否在 /import 目录
// - 检查文件名是否正确
// - 检查文件权限

// 如果遇到 "约束冲突" 错误:
// - 检查 neo4j_id 是否重复
// - 先清理重复数据再导入

// 如果遇到 "节点不存在" 错误:
// - 确保先导入节点，再导入关系
// - 检查 START_ID 和 END_ID 是否存在
