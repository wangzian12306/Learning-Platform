package com.learningplatform.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class VideoResponse {
    private Long id;
    private Long knowledgePointId;
    private String knowledgePointName;
    private String knowledgePointCode;
    private String knowledgePointDifficulty;
    private String neo4jId;
    private String title;
    private String description;
    private String videoUrl;
    private Integer duration;
    private String thumbnailUrl;
    private Integer sortOrder;
    private LocalDateTime updateTime;
}
