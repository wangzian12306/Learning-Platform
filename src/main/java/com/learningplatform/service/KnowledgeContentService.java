package com.learningplatform.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.learningplatform.entity.KnowledgeContent;
import com.learningplatform.repository.KnowledgeContentRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class KnowledgeContentService extends ServiceImpl<KnowledgeContentRepository, KnowledgeContent> {

    public List<KnowledgeContent> listByKnowledgePointId(Long knowledgePointId) {
        LambdaQueryWrapper<KnowledgeContent> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(KnowledgeContent::getKnowledgePointId, knowledgePointId)
               .orderByAsc(KnowledgeContent::getSortOrder);
        return list(wrapper);
    }
}
