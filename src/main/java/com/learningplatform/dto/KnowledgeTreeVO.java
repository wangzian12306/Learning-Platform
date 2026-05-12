package com.learningplatform.dto;

import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
public class KnowledgeTreeVO {

    private Long id;

    private String neo4jId;

    private String name;

    private String code;

    private String module;

    private Integer level;

    private String difficulty;

    private List<String> prerequisites;

    private List<KnowledgeTreeVO> children;

    public KnowledgeTreeVO() {
        this.children = new ArrayList<>();
        this.prerequisites = new ArrayList<>();
    }

    public static KnowledgeTreeVO from(com.learningplatform.entity.KnowledgePoint point) {
        KnowledgeTreeVO vo = new KnowledgeTreeVO();
        vo.setId(point.getId());
        vo.setNeo4jId(point.getNeo4jId());
        vo.setName(point.getName());
        vo.setCode(point.getCode());
        vo.setModule(point.getModule());
        vo.setLevel(point.getLevel());
        vo.setDifficulty(point.getDifficulty());
        return vo;
    }
}
