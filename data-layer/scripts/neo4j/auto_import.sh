#!/bin/bash
# ============================================
# Neo4j数据一键导入脚本 (Docker版本)
# 用途: 在Docker容器中自动导入Neo4j数据
# 使用方法: 在data-docker目录下执行 docker-compose exec neo4j /scripts/auto_import.sh
# ============================================

set -e

echo "========================================="
echo "Neo4j Docker 数据导入工具"
echo "========================================="

# 配置变量
NEO4J_URI="bolt://localhost:7687"
NEO4J_USER="neo4j"
NEO4J_PASSWORD="neo4j123"
IMPORT_DIR="/import"
SCRIPTS_DIR="/scripts"

echo "等待Neo4j启动..."
# 等待Neo4j完全启动
until cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" "RETURN 1;" > /dev/null 2>&1; do
    echo "Neo4j尚未就绪，等待中..."
    sleep 5
done

echo "Neo4j已就绪！"
echo ""

# 检查CSV文件是否存在
if [ ! -f "$IMPORT_DIR/nodes/knowledge_points.csv" ]; then
    echo "错误: 未找到知识点CSV文件"
    echo "请将CSV文件放置在 ../data/neo4j_import/nodes/ 目录"
    exit 1
fi

# 1. 执行Schema定义
echo "步骤1: 创建索引和约束..."
cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" < "$SCRIPTS_DIR/schema.cql"
echo "✓ Schema创建完成"
echo ""

# 2. 导入节点数据
echo "步骤2: 导入知识点节点..."
cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" <<EOF
LOAD CSV WITH HEADERS FROM 'file:///nodes/knowledge_points.csv' AS row
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
EOF
echo "✓ 节点导入完成"
echo ""

# 3. 导入层级关系（如果文件存在）
if [ -f "$IMPORT_DIR/relationships/parent_of.csv" ]; then
    echo "步骤3: 导入层级关系..."
    cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" <<EOF
LOAD CSV WITH HEADERS FROM 'file:///relationships/parent_of.csv' AS row
MATCH (parent:KnowledgePoint {neo4j_id: row.:START_ID}),
      (child:KnowledgePoint {neo4j_id: row.:END_ID})
CREATE (parent)-[:PARENT_OF {order: toInteger(row.order)}]->(child);
EOF
    echo "✓ 层级关系导入完成"
    echo ""
fi

# 4. 导入关联关系（如果文件存在）
if [ -f "$IMPORT_DIR/relationships/related_to.csv" ]; then
    echo "步骤4: 导入关联关系..."
    cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" <<EOF
LOAD CSV WITH HEADERS FROM 'file:///relationships/related_to.csv' AS row
MATCH (start:KnowledgePoint {neo4j_id: row.:START_ID}),
      (end:KnowledgePoint {neo4j_id: row.:END_ID})
CREATE (start)-[:RELATED_TO {
  type: row.type,
  strength: toInteger(row.strength)
}]->(end);
EOF
    echo "✓ 关联关系导入完成"
    echo ""
fi

# 5. 验证导入结果
echo "========================================="
echo "导入结果验证"
echo "========================================="

NODE_COUNT=$(cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" "MATCH (kp:KnowledgePoint) RETURN count(kp);" | tail -1)
echo "知识点节点数: $NODE_COUNT"

PARENT_COUNT=$(cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" "MATCH ()-[r:PARENT_OF]->() RETURN count(r);" | tail -1)
echo "层级关系数: $PARENT_COUNT"

RELATED_COUNT=$(cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" "MATCH ()-[r:RELATED_TO]->() RETURN count(r);" | tail -1)
echo "关联关系数: $RELATED_COUNT"

echo ""
echo "========================================="
echo "✓ 所有数据导入完成！"
echo "========================================="
echo ""
echo "访问Neo4j Browser: http://localhost:17474"
echo "用户名: neo4j"
echo "密码: neo4j"
