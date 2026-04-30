package com.learningplatform.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.learningplatform.entity.KnowledgeContent;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface KnowledgeContentRepository extends BaseMapper<KnowledgeContent> {
}
