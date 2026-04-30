package com.learningplatform.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.learningplatform.entity.CodeExample;
import com.learningplatform.repository.CodeExampleRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CodeExampleService extends ServiceImpl<CodeExampleRepository, CodeExample> {

    public List<CodeExample> listByKnowledgePointId(Long knowledgePointId) {
        LambdaQueryWrapper<CodeExample> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CodeExample::getKnowledgePointId, knowledgePointId)
               .orderByAsc(CodeExample::getSortOrder);
        return list(wrapper);
    }
}
