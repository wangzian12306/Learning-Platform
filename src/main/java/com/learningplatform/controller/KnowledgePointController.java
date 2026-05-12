package com.learningplatform.controller;

import com.learningplatform.common.Result;
import com.learningplatform.dto.CreateKnowledgePointRequest;
import com.learningplatform.dto.KnowledgeTreeVO;
import com.learningplatform.entity.KnowledgePoint;
import com.learningplatform.service.KnowledgePointService;
import jakarta.validation.Valid;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/knowledge")
public class KnowledgePointController {

    @Autowired
    private KnowledgePointService knowledgePointService;

    @GetMapping("/tree")
    public Result<List<KnowledgeTreeVO>> tree() {
        List<KnowledgeTreeVO> tree = knowledgePointService.buildKnowledgeTree();
        return Result.success(tree);
    }

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
    public Result<Void> save(@Valid @RequestBody CreateKnowledgePointRequest request) {
        KnowledgePoint point = new KnowledgePoint();
        BeanUtils.copyProperties(request, point);
        knowledgePointService.save(point);
        return Result.success();
    }
}
