package com.learningplatform.controller;

import com.learningplatform.common.Result;
import com.learningplatform.dto.VideoResponse;
import com.learningplatform.dto.VideoWatchRecordRequest;
import com.learningplatform.dto.VideoWatchRecordResponse;
import com.learningplatform.service.VideoService;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/video")
@Validated
@Slf4j
public class VideoController {

    @Autowired
    private VideoService videoService;

    @GetMapping("/list")
    public Result<List<VideoResponse>> getVideoList(@RequestParam(value = "knowledgeId", required = false) Long knowledgeId) {
        return Result.success(videoService.getVideoList(knowledgeId));
    }

    @GetMapping("/{id}")
    public Result<VideoResponse> getVideoDetail(@PathVariable Long id) {
        return Result.success(videoService.getVideoDetail(id));
    }

    @GetMapping("/{id}/recommendations")
    public Result<List<VideoResponse>> getRecommendedVideos(@PathVariable Long id) {
        return Result.success(videoService.getRecommendedVideos(id));
    }

    @PostMapping("/watch-record")
    public Result<VideoWatchRecordResponse> saveWatchRecord(@Valid @RequestBody VideoWatchRecordRequest request,
                                                            @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        return Result.success(videoService.saveWatchRecord(getCurrentUserId(userId), request));
    }

    @GetMapping("/watch-record/{videoId}")
    public Result<VideoWatchRecordResponse> getWatchRecord(@PathVariable Long videoId,
                                                           @RequestHeader(value = "X-User-Id", required = false) Long userId) {
        return Result.success(videoService.getWatchRecord(getCurrentUserId(userId), videoId));
    }

    private Long getCurrentUserId(Long userId) {
        if (userId != null) {
            return userId;
        }
        log.warn("User id is missing, fallback to default user 1");
        return 1L;
    }
}
