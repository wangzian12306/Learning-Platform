#!/bin/bash
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

echo "启动Neo4j服务..."
/startup/docker-entrypoint.sh neo4j &

echo "等待Neo4j启动..."
until cypher-shell -u neo4j -p neo4j123 -a bolt://localhost:7687 "RETURN 1;" > /dev/null 2>&1; do
    echo "Neo4j尚未就绪，等待中..."
    sleep 5
done

echo "Neo4j已就绪！"
echo ""

EXISTING_COUNT=$(cypher-shell -u neo4j -p neo4j123 -a bolt://localhost:7687 "MATCH (kp:KnowledgePoint) RETURN count(kp);" 2>/dev/null | tail -1 || echo "0")

if [ "$EXISTING_COUNT" != "0" ] && [ -n "$EXISTING_COUNT" ]; then
    echo "检测到已有 $EXISTING_COUNT 个知识点节点，跳过自动导入"
    echo "如需重新导入，请先清空数据或删除数据卷"
else
    echo "开始自动导入数据..."
    echo ""

    if [ -f "/scripts/auto_import.sh" ]; then
        bash /scripts/auto_import.sh
    else
        echo "警告: 未找到自动导入脚本 /scripts/auto_import.sh"
    fi
fi

echo ""
echo "========================================="
echo "Neo4j服务准备就绪！"
echo "========================================="
echo ""

wait
