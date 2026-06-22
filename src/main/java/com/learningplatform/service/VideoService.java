package com.learningplatform.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.learningplatform.common.BusinessException;
import com.learningplatform.dto.VideoResponse;
import com.learningplatform.dto.VideoWatchRecordRequest;
import com.learningplatform.dto.VideoWatchRecordResponse;
import com.learningplatform.entity.KnowledgePoint;
import com.learningplatform.entity.Video;
import com.learningplatform.entity.VideoWatchRecord;
import com.learningplatform.repository.KnowledgePointRepository;
import com.learningplatform.repository.VideoRepository;
import com.learningplatform.repository.VideoWatchRecordRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.neo4j.core.Neo4jClient;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Slf4j
@Transactional(value = "transactionManager")
public class VideoService {

    private static final int COMPLETED_PROGRESS_THRESHOLD = 95;

    @Autowired
    private VideoRepository videoRepository;

    @Autowired
    private KnowledgePointRepository knowledgePointRepository;

    @Autowired
    private VideoWatchRecordRepository videoWatchRecordRepository;

    @Autowired
    private Neo4jClient neo4jClient;

    public List<VideoResponse> getVideoList(Long knowledgeId) {
        QueryWrapper<Video> queryWrapper = new QueryWrapper<>();
        if (knowledgeId != null) {
            queryWrapper.eq("knowledge_point_id", knowledgeId);
        }
        queryWrapper.orderByAsc("sort_order").orderByAsc("id");

        return videoRepository.selectList(queryWrapper).stream()
                .map(this::convertToVideoResponse)
                .collect(Collectors.toList());
    }

    public VideoResponse getVideoDetail(Long videoId) {
        Video video = videoRepository.selectById(videoId);
        if (video == null) {
            throw new BusinessException(1701, "video does not exist");
        }
        return convertToVideoResponse(video);
    }

    public List<VideoResponse> getRecommendedVideos(Long videoId) {
        Video currentVideo = videoRepository.selectById(videoId);
        if (currentVideo == null) {
            throw new BusinessException(1701, "video does not exist");
        }

        KnowledgePoint currentPoint = knowledgePointRepository.selectById(currentVideo.getKnowledgePointId());
        if (currentPoint == null) {
            return List.of();
        }

        String currentNeo4jId = resolveNeo4jId(currentPoint);
        Set<Long> knowledgeIds = new LinkedHashSet<>();
        knowledgeIds.add(currentPoint.getId());

        if (currentNeo4jId != null) {
            List<String> relatedNeo4jIds = getRelatedNeo4jIds(currentNeo4jId);
            for (String relatedNeo4jId : relatedNeo4jIds) {
                KnowledgePoint relatedPoint = findKnowledgePointByNeo4jId(relatedNeo4jId);
                if (relatedPoint != null) {
                    knowledgeIds.add(relatedPoint.getId());
                }
            }
        }

        if (knowledgeIds.isEmpty()) {
            return List.of();
        }

        return videoRepository.selectList(new QueryWrapper<Video>()
                        .in("knowledge_point_id", knowledgeIds)
                        .ne("id", videoId)
                        .orderByAsc("sort_order")
                        .orderByAsc("id")
                        .last("LIMIT 6"))
                .stream()
                .map(this::convertToVideoResponse)
                .collect(Collectors.toList());
    }

    public VideoWatchRecordResponse getWatchRecord(Long userId, Long videoId) {
        ensureVideoExists(videoId);

        VideoWatchRecord record = videoWatchRecordRepository.selectOne(buildUserVideoQuery(userId, videoId));
        if (record == null) {
            return buildEmptyWatchRecord(userId, videoId);
        }
        return convertToWatchRecordResponse(record);
    }

    public VideoWatchRecordResponse saveWatchRecord(Long userId, VideoWatchRecordRequest request) {
        ensureVideoExists(request.getVideoId());

        VideoWatchRecord record = videoWatchRecordRepository.selectOne(buildUserVideoQuery(userId, request.getVideoId()));
        if (record == null) {
            record = new VideoWatchRecord();
            record.setUserId(userId);
            record.setVideoId(request.getVideoId());
            fillWatchRecord(record, request);
            videoWatchRecordRepository.insert(record);
            return convertToWatchRecordResponse(record);
        }

        fillWatchRecord(record, request);
        videoWatchRecordRepository.updateById(record);
        return convertToWatchRecordResponse(record);
    }

    private void ensureVideoExists(Long videoId) {
        Video video = videoRepository.selectById(videoId);
        if (video == null) {
            throw new BusinessException(1701, "video does not exist");
        }
    }

    private QueryWrapper<VideoWatchRecord> buildUserVideoQuery(Long userId, Long videoId) {
        return new QueryWrapper<VideoWatchRecord>()
                .eq("user_id", userId)
                .eq("video_id", videoId);
    }

    private void fillWatchRecord(VideoWatchRecord record, VideoWatchRecordRequest request) {
        Integer progress = Math.max(record.getWatchProgress() == null ? 0 : record.getWatchProgress(),
                request.getWatchProgress());
        Integer duration = Math.max(record.getWatchDuration() == null ? 0 : record.getWatchDuration(),
                request.getWatchDuration() == null ? 0 : request.getWatchDuration());
        record.setWatchProgress(progress);
        record.setWatchDuration(duration);
        record.setLastWatchTime(LocalDateTime.now());
        record.setIsCompleted(progress >= COMPLETED_PROGRESS_THRESHOLD ? 1 : 0);
    }

    private VideoWatchRecordResponse buildEmptyWatchRecord(Long userId, Long videoId) {
        VideoWatchRecordResponse response = new VideoWatchRecordResponse();
        response.setUserId(userId);
        response.setVideoId(videoId);
        response.setWatchProgress(0);
        response.setWatchDuration(0);
        response.setIsCompleted(0);
        return response;
    }

    private VideoResponse convertToVideoResponse(Video video) {
        VideoResponse response = new VideoResponse();
        BeanUtils.copyProperties(video, response);
        KnowledgePoint knowledgePoint = knowledgePointRepository.selectById(video.getKnowledgePointId());
        if (knowledgePoint != null) {
            response.setKnowledgePointName(knowledgePoint.getName());
            response.setKnowledgePointCode(knowledgePoint.getCode());
            response.setKnowledgePointDifficulty(knowledgePoint.getDifficulty());
            response.setNeo4jId(resolveNeo4jId(knowledgePoint));
        }
        return response;
    }

    private List<String> getRelatedNeo4jIds(String neo4jId) {
        return neo4jClient.query(
                        "MATCH (n:KnowledgePoint {neo4j_id: $id})-[r]-(m:KnowledgePoint) " +
                                "RETURN m.neo4j_id AS id, coalesce(r.order, 999) AS sortOrder " +
                                "ORDER BY sortOrder, m.level")
                .bind(neo4jId).to("id")
                .fetchAs(String.class)
                .mappedBy((typeSystem, record) -> record.get("id").isNull() ? null : record.get("id").asString())
                .all()
                .stream()
                .filter(id -> id != null && !id.isBlank())
                .collect(Collectors.toList());
    }

    private KnowledgePoint findKnowledgePointByNeo4jId(String neo4jId) {
        QueryWrapper<KnowledgePoint> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("neo4j_id", neo4jId);
        queryWrapper.last("LIMIT 1");
        KnowledgePoint point = knowledgePointRepository.selectOne(queryWrapper);
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
        return new ArrayList<>(reverseMap.getOrDefault(neo4jId, List.of()));
    }

    private String resolveNeo4jId(KnowledgePoint knowledgePoint) {
        Map<String, String> fallbackMap = Map.ofEntries(
                Map.entry("LINEAR_LIST", "KP_LL_001"),
                Map.entry("LINKED_LIST", "KP_LL_001"),
                Map.entry("STACK", "KP_LL_002"),
                Map.entry("QUEUE", "KP_LL_004"),
                Map.entry("TREE", "KP_TREE_001"),
                Map.entry("BINARY_TREE", "KP_TREE_002"),
                Map.entry("B_TREE", "KP_TREE_007"),
                Map.entry("GRAPH", "KP_GRAPH_001"),
                Map.entry("GRAPH_REPRESENTATION", "KP_GRAPH_002"),
                Map.entry("SEARCH", "KP_SEARCH_001"),
                Map.entry("SEQUENTIAL_SEARCH", "KP_SEARCH_002"),
                Map.entry("BINARY_SEARCH", "KP_SEARCH_003"),
                Map.entry("HASH_TABLE", "KP_SEARCH_004"),
                Map.entry("SORT", "KP_SORT_001"),
                Map.entry("SELECTION_SORT", "KP_SORT_003")
        );

        String mappedNeo4jId = fallbackMap.get(knowledgePoint.getCode());
        if (mappedNeo4jId != null) {
            return mappedNeo4jId;
        }
        if (knowledgePoint.getNeo4jId() != null && !knowledgePoint.getNeo4jId().isBlank()) {
            return knowledgePoint.getNeo4jId();
        }
        return null;
    }

    private VideoWatchRecordResponse convertToWatchRecordResponse(VideoWatchRecord record) {
        VideoWatchRecordResponse response = new VideoWatchRecordResponse();
        BeanUtils.copyProperties(record, response);
        return response;
    }
}
