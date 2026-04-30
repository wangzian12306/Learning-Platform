package com.learningplatform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("knowledge_content")
public class KnowledgeContent extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long knowledgePointId;

    private String contentType;

    private String title;

    private String content;

    private Integer sortOrder;
}
