package com.learningplatform.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.learningplatform.entity.Exercise;
import com.learningplatform.entity.KnowledgePoint;
import com.learningplatform.entity.Video;
import com.learningplatform.repository.ExerciseRepository;
import com.learningplatform.repository.KnowledgePointRepository;
import com.learningplatform.repository.VideoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class GraphService {

    @Autowired
    private Neo4jClient neo4jClient;

    @Autowired
    private KnowledgePointRepository knowledgePointRepository;

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private ExerciseRepository exerciseRepository;

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
        KnowledgePoint mysqlKnowledgePoint = findKnowledgePointByNeo4jId(nodeId);
        if (mysqlKnowledgePoint != null) {
            node.put("relatedVideos", getRelatedVideos(mysqlKnowledgePoint.getId()));
            node.put("relatedExercises", getRelatedExercises(mysqlKnowledgePoint.getId()));
        } else {
            node.put("relatedVideos", List.of());
            node.put("relatedExercises", List.of());
        }
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

    private KnowledgePoint findKnowledgePointByNeo4jId(String neo4jId) {
        KnowledgePoint point = knowledgePointRepository.selectOne(new QueryWrapper<KnowledgePoint>()
                .eq("neo4j_id", neo4jId)
                .last("LIMIT 1"));
        if (point != null) {
            return point;
        }

        List<String> codes = getCodesByNeo4jId(neo4jId);
        if (codes.isEmpty()) {
            return null;
        }
        return knowledgePointRepository.selectOne(new QueryWrapper<KnowledgePoint>()
                .in("code", codes)
                .last("LIMIT 1"));
    }

    private List<Map<String, Object>> getRelatedVideos(Long knowledgePointId) {
        return videoRepository.selectList(new QueryWrapper<Video>()
                        .eq("knowledge_point_id", knowledgePointId)
                        .orderByAsc("sort_order")
                        .orderByAsc("id")
                        .last("LIMIT 5"))
                .stream()
                .map(video -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", video.getId());
                    item.put("title", video.getTitle());
                    item.put("description", video.getDescription());
                    return item;
                })
                .toList();
    }

    private List<Map<String, Object>> getRelatedExercises(Long knowledgePointId) {
        return exerciseRepository.selectList(new QueryWrapper<Exercise>()
                        .eq("knowledge_point_id", knowledgePointId)
                        .orderByAsc("sort_order")
                        .orderByAsc("id")
                        .last("LIMIT 5"))
                .stream()
                .map(exercise -> {
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", exercise.getId());
                    item.put("title", exercise.getTitle());
                    item.put("type", exercise.getType());
                    item.put("difficulty", exercise.getDifficulty());
                    return item;
                })
                .toList();
    }

    private List<String> getCodesByNeo4jId(String neo4jId) {
        Map<String, List<String>> reverseMap = Map.ofEntries(
                Map.entry("KP_LL_001", List.of("LINEAR_LIST", "LINKED_LIST")),
                Map.entry("KP_LL_002", List.of("STACK")),
                Map.entry("KP_LL_004", List.of("QUEUE")),
                Map.entry("KP_TREE_001", List.of("TREE")),
                Map.entry("KP_TREE_002", List.of("BINARY_TREE")),
                Map.entry("KP_TREE_007", List.of("B_TREE")),
                Map.entry("KP_GRAPH_001", List.of("GRAPH")),
                Map.entry("KP_GRAPH_002", List.of("GRAPH_REPRESENTATION", "GRAPH_STORAGE")),
                Map.entry("KP_SEARCH_001", List.of("SEARCH")),
                Map.entry("KP_SEARCH_002", List.of("SEQUENTIAL_SEARCH")),
                Map.entry("KP_SEARCH_003", List.of("BINARY_SEARCH")),
                Map.entry("KP_SEARCH_004", List.of("HASH_TABLE")),
                Map.entry("KP_SORT_001", List.of("SORT", "SORTING")),
                Map.entry("KP_SORT_003", List.of("SELECTION_SORT"))
        );
        return reverseMap.getOrDefault(neo4jId, List.of());
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> toTypedList(Collection collection) {
        return ((Collection<Map<String, Object>>) collection).stream().toList();
    }
}
