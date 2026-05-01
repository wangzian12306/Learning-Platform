#!/bin/bash
# ============================================
# Neo4j数据一键导入脚本 (Docker版本)
# 用途: 在Docker容器中自动导入Neo4j数据
# 使用方法: 在data-docker目录下执行 docker-compose exec neo4j /scripts/auto_import.sh
# ============================================

set -e

# 设置UTF-8编码，防止中文乱码
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

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

# 检查Cypher文件是否存在
if [ ! -f "$IMPORT_DIR/knowledge_points.cypher" ]; then
    echo "错误: 未找到知识点Cypher文件"
    echo "请将Cypher文件放置在 ../data/neo4j_import/ 目录"
    exit 1
fi

# 1. 执行Schema定义
echo "步骤1: 创建索引和约束..."
cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" < "$SCRIPTS_DIR/schema.cql"
echo "✓ Schema创建完成"
echo ""

# 2. 导入知识点数据
echo "步骤2: 导入知识点数据..."
cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI" < "$IMPORT_DIR/knowledge_points.cypher"
echo "✓ 知识点数据导入完成"
echo ""

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
