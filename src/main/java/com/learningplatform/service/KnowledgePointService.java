package com.learningplatform.service;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.learningplatform.dto.KnowledgeTreeVO;
import com.learningplatform.entity.KnowledgePoint;
import com.learningplatform.repository.KnowledgePointRepository;
import lombok.extern.slf4j.Slf4j;
import org.neo4j.driver.Value;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
public class KnowledgePointService extends ServiceImpl<KnowledgePointRepository, KnowledgePoint> {

    private final Neo4jClient neo4jClient;

    public KnowledgePointService(Neo4jClient neo4jClient) {
        this.neo4jClient = neo4jClient;
    }

    public List<KnowledgeTreeVO> buildKnowledgeTree() {
        List<KnowledgePoint> all = list();

        Map<String, List<String>> prereqMap = loadPrerequisitesFromNeo4j();

        Map<Long, KnowledgeTreeVO> nodeMap = new LinkedHashMap<>();
        for (KnowledgePoint point : all) {
            KnowledgeTreeVO vo = KnowledgeTreeVO.from(point);
            List<String> prereqs = prereqMap.getOrDefault(point.getNeo4jId(), Collections.emptyList());
            vo.setPrerequisites(prereqs);
            nodeMap.put(point.getId(), vo);
        }

        List<KnowledgeTreeVO> roots = new ArrayList<>();
        for (KnowledgePoint point : all) {
            KnowledgeTreeVO vo = nodeMap.get(point.getId());
            if (point.getParentId() == null || point.getParentId() == 0) {
                roots.add(vo);
            } else {
                KnowledgeTreeVO parent = nodeMap.get(point.getParentId());
                if (parent != null) {
                    parent.getChildren().add(vo);
                }
            }
        }

        sortChildren(roots);
        return roots;
    }

    @SuppressWarnings("unchecked")
    private Map<String, List<String>> loadPrerequisitesFromNeo4j() {
        Map<String, List<String>> map = new LinkedHashMap<>();
        try {
            Collection rows = neo4jClient.query(
                    "MATCH (n:KnowledgePoint)-[:RELATED_TO]->(prereq:KnowledgePoint) " +
                    "RETURN n.neo4j_id AS nodeId, collect(prereq.neo4j_id) AS prerequisites"
            )
            .fetchAs(Map.class)
                    .mappedBy((typeSystem, record) -> {
                        Map<String, Object> row = new LinkedHashMap<>();
                        var nodeIdVal = record.get("nodeId");
                        var prereqVal = record.get("prerequisites");
                        row.put("nodeId", nodeIdVal == null || nodeIdVal.isNull() ? null : nodeIdVal.asString());
                        row.put("prerequisites", prereqVal == null || prereqVal.isNull() ? null : prereqVal.asList());
                        return row;
                    })
                    .all();

            for (Map<String, Object> row : (Collection<Map<String, Object>>) rows) {
                String nodeId = (String) row.get("nodeId");
                Object prereqRaw = row.get("prerequisites");
                List<String> prereqList = new ArrayList<>();
                if (prereqRaw instanceof List) {
                    for (Object item : (List<?>) prereqRaw) {
                        if (item instanceof Value) {
                            prereqList.add(((Value) item).asString());
                        } else if (item instanceof String) {
                            prereqList.add((String) item);
                        }
                    }
                }
                if (nodeId != null && !prereqList.isEmpty()) {
                    map.put(nodeId, prereqList);
                }
            }
        } catch (Exception e) {
            log.warn("Failed to load prerequisites from Neo4j: " + e.getMessage());
        }
        return map;
    }

    private void sortChildren(List<KnowledgeTreeVO> nodes) {
        nodes.sort(Comparator.comparing(KnowledgeTreeVO::getLevel)
                .thenComparing(KnowledgeTreeVO::getId));
        for (KnowledgeTreeVO node : nodes) {
            if (node.getChildren() != null && !node.getChildren().isEmpty()) {
                sortChildren(node.getChildren());
            }
        }
    }
}
