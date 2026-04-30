package com.learningplatform.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("code_example")
public class CodeExample extends BaseEntity {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long knowledgePointId;

    private String title;

    private String description;

    private String code;

    private String language;

    private Integer sortOrder;
}
