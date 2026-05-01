package com.learningplatform.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class GraphService {

    @Autowired
    private Neo4jClient neo4jClient;

    /**
     * 获取完整图谱数据：所有节点和关系
     */
    public Map<String, Object> getGraphData() {
        List<Map<String, Object>> nodes = getAllNodes();
        List<Map<String, Object>> edges = getAllEdges();

        Map<String, Object> result = new HashMap<>();
        result.put("nodes", nodes);
        result.put("edges", edges);
        return result;
    }

    /**
     * 获取所有知识点节点
     */
    private List<Map<String, Object>> getAllNodes() {
        return toTypedList(neo4jClient.query(
                "MATCH (n:KnowledgePoint) RETURN n.neo4j_id AS id, n.name AS name, " +
                        "n.code AS code, n.module AS module, n.level AS level, " +
                        "n.difficulty AS difficulty, n.description AS description, " +
                        "n.core_points AS corePoints ORDER BY n.module, n.level"
        )
                .fetchAs(Map.class)
                .mappedBy((typeSystem, record) -> {
                    Map<String, Object> node = new HashMap<>();
                    node.put("id", getValue(record, "id"));
                    node.put("name", getValue(record, "name"));
                    node.put("code", getValue(record, "code"));
                    node.put("module", getValue(record, "module"));
                    node.put("level", getInt(record, "level"));
                    node.put("difficulty", getValue(record, "difficulty"));
                    node.put("description", getValue(record, "description"));
                    node.put("corePoints", getValue(record, "corePoints"));
                    return node;
                })
                .all());
    }

    /**
     * 获取所有关系
     */
    private List<Map<String, Object>> getAllEdges() {
        return toTypedList(neo4jClient.query(
                "MATCH (a:KnowledgePoint)-[r]->(b:KnowledgePoint) " +
                        "RETURN a.neo4j_id AS source, b.neo4j_id AS target, " +
                        "type(r) AS type, r.reason AS reason, r.order AS sortOrder"
        )
                .fetchAs(Map.class)
                .mappedBy((typeSystem, record) -> {
                    Map<String, Object> edge = new HashMap<>();
                    edge.put("source", getValue(record, "source"));
                    edge.put("target", getValue(record, "target"));
                    edge.put("type", getValue(record, "type"));
                    String reason = getValue(record, "reason");
                    if (reason != null) {
                        edge.put("reason", reason);
                    }
                    Object sortOrder = getInt(record, "sortOrder");
                    if (sortOrder != null) {
                        edge.put("order", sortOrder);
                    }
                    return edge;
                })
                .all());
    }

    /**
     * 获取单个节点详情
     */
    public Map<String, Object> getNodeDetail(String nodeId) {
        // 查询节点本身
        Map<String, Object> node = neo4jClient.query(
                "MATCH (n:KnowledgePoint {neo4j_id: $id}) " +
                        "RETURN n.neo4j_id AS id, n.name AS name, n.code AS code, " +
                        "n.module AS module, n.level AS level, n.difficulty AS difficulty, " +
                        "n.description AS description, n.core_points AS corePoints"
        )
                .bind(nodeId).to("id")
                .fetchAs(Map.class)
                .mappedBy((typeSystem, record) -> {
                    Map<String, Object> n = new HashMap<>();
                    n.put("id", getValue(record, "id"));
                    n.put("name", getValue(record, "name"));
                    n.put("code", getValue(record, "code"));
                    n.put("module", getValue(record, "module"));
                    n.put("level", getInt(record, "level"));
                    n.put("difficulty", getValue(record, "difficulty"));
                    n.put("description", getValue(record, "description"));
                    n.put("corePoints", getValue(record, "corePoints"));
                    return n;
                })
                .one().orElse(null);

        if (node == null) {
            return null;
        }

        // 查询关联节点
        List<Map<String, Object>> related = toTypedList(neo4jClient.query(
                "MATCH (n:KnowledgePoint {neo4j_id: $id})-[r]-(m:KnowledgePoint) " +
                        "RETURN m.neo4j_id AS id, m.name AS name, type(r) AS relationType"
        )
                .bind(nodeId).to("id")
                .fetchAs(Map.class)
                .mappedBy((typeSystem, record) -> {
                    Map<String, Object> r = new HashMap<>();
                    r.put("id", getValue(record, "id"));
                    r.put("name", getValue(record, "name"));
                    r.put("relationType", getValue(record, "relationType"));
                    return r;
                })
                .all());

        node.put("relatedNodes", related);
        return node;
    }

    /**
     * 按关键词搜索节点
     */
    public List<Map<String, Object>> searchNodes(String keyword) {
        return toTypedList(neo4jClient.query(
                "MATCH (n:KnowledgePoint) " +
                        "WHERE n.name CONTAINS $keyword OR n.code CONTAINS $keyword OR n.description CONTAINS $keyword " +
                        "RETURN n.neo4j_id AS id, n.name AS name, n.code AS code, " +
                        "n.module AS module, n.level AS level, n.difficulty AS difficulty, " +
                        "n.description AS description, n.core_points AS corePoints"
        )
                .bind(keyword).to("keyword")
                .fetchAs(Map.class)
                .mappedBy((typeSystem, record) -> {
                    Map<String, Object> n = new HashMap<>();
                    n.put("id", getValue(record, "id"));
                    n.put("name", getValue(record, "name"));
                    n.put("code", getValue(record, "code"));
                    n.put("module", getValue(record, "module"));
                    n.put("level", getInt(record, "level"));
                    n.put("difficulty", getValue(record, "difficulty"));
                    n.put("description", getValue(record, "description"));
                    n.put("corePoints", getValue(record, "corePoints"));
                    return n;
                })
                .all());
    }

    private static String getValue(org.neo4j.driver.Record record, String key) {
        var val = record.get(key);
        return val == null || val.isNull() ? null : val.asString();
    }

    private static Integer getInt(org.neo4j.driver.Record record, String key) {
        var val = record.get(key);
        return val == null || val.isNull() ? null : val.asInt();
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> toTypedList(Collection collection) {
        return ((Collection<Map<String, Object>>) collection).stream().toList();
    }
}
