package com.learningplatform.controller;

import com.learningplatform.common.Result;
import com.learningplatform.entity.CodeExample;
import com.learningplatform.entity.KnowledgeContent;
import com.learningplatform.entity.KnowledgePoint;
import com.learningplatform.service.CodeExampleService;
import com.learningplatform.service.KnowledgeContentService;
import com.learningplatform.service.KnowledgePointService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/knowledge")
public class KnowledgePointController {

    @Autowired
    private KnowledgePointService knowledgePointService;

    @Autowired
    private KnowledgeContentService knowledgeContentService;

    @Autowired
    private CodeExampleService codeExampleService;

    @GetMapping("/list")
    public Result<List<KnowledgePoint>> list() {
        List<KnowledgePoint> list = knowledgePointService.list();
        return Result.success(list);
    }

    @GetMapping("/{id}")
    public Result<KnowledgePoint> getById(@PathVariable Long id) {
        KnowledgePoint point = knowledgePointService.getById(id);
        return Result.success(point);
    }

    @PostMapping
    public Result<Void> save(@RequestBody KnowledgePoint point) {
        knowledgePointService.save(point);
        return Result.success();
    }

    @GetMapping("/{knowledgeId}/contents")
    public Result<List<KnowledgeContent>> getContents(@PathVariable Long knowledgeId) {
        List<KnowledgeContent> contents = knowledgeContentService.listByKnowledgePointId(knowledgeId);
        return Result.success(contents);
    }

    @GetMapping("/{knowledgeId}/codes")
    public Result<List<CodeExample>> getCodes(@PathVariable Long knowledgeId) {
        List<CodeExample> codes = codeExampleService.listByKnowledgePointId(knowledgeId);
        return Result.success(codes);
    }
}
