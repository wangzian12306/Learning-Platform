CREATE DATABASE IF NOT EXISTS learning_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE learning_platform;

CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(255) NOT NULL COMMENT '密码',
    `email` VARCHAR(100) COMMENT '邮箱',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `avatar` VARCHAR(255) COMMENT '头像URL',
    `role` VARCHAR(20) NOT NULL DEFAULT 'STUDENT' COMMENT '角色：ADMIN, STUDENT',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_username (`username`),
    INDEX idx_email (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE IF NOT EXISTS `knowledge_point` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '知识点ID',
    `neo4j_id` VARCHAR(100) COMMENT 'Neo4j节点ID',
    `name` VARCHAR(100) NOT NULL COMMENT '知识点名称',
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT '知识点编码',
    `parent_id` BIGINT COMMENT '父知识点ID',
    `module` VARCHAR(50) NOT NULL COMMENT '所属模块：集合, 线性表, 树, 图, 查找, 排序',
    `level` INT NOT NULL COMMENT '层级',
    `difficulty` VARCHAR(20) NOT NULL COMMENT '难度等级：EASY, MEDIUM, HARD',
    `description` TEXT COMMENT '知识点描述',
    `core_points` TEXT COMMENT '核心考点',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_module (`module`),
    INDEX idx_parent_id (`parent_id`),
    INDEX idx_code (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识点表';

CREATE TABLE IF NOT EXISTS `knowledge_content` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '内容ID',
    `knowledge_point_id` BIGINT NOT NULL COMMENT '知识点ID',
    `content_type` VARCHAR(20) NOT NULL COMMENT '内容类型：DEFINITION, OPERATION, COMPLEXITY, VIDEO, DIAGRAM',
    `title` VARCHAR(200) NOT NULL COMMENT '标题',
    `content` TEXT NOT NULL COMMENT '内容',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_knowledge_point_id (`knowledge_point_id`),
    INDEX idx_content_type (`content_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识点内容表';

CREATE TABLE IF NOT EXISTS `code_example` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '代码示例ID',
    `knowledge_point_id` BIGINT NOT NULL COMMENT '知识点ID',
    `title` VARCHAR(200) NOT NULL COMMENT '标题',
    `description` TEXT COMMENT '描述',
    `code` TEXT NOT NULL COMMENT 'C++代码',
    `language` VARCHAR(20) NOT NULL DEFAULT 'C++' COMMENT '编程语言',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_knowledge_point_id (`knowledge_point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代码示例表';

CREATE TABLE IF NOT EXISTS `exercise` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '题目ID',
    `knowledge_point_id` BIGINT NOT NULL COMMENT '知识点ID',
    `title` VARCHAR(500) NOT NULL COMMENT '题目',
    `type` VARCHAR(20) NOT NULL COMMENT '题型：CHOICE, FILL, PROGRAMMING',
    `difficulty` VARCHAR(20) NOT NULL COMMENT '难度：EASY, MEDIUM, HARD',
    `category` VARCHAR(50) NOT NULL COMMENT '类别：基础题, 考研题, 面试题',
    `options` JSON COMMENT '选择题选项',
    `answer` TEXT NOT NULL COMMENT '答案',
    `analysis` TEXT COMMENT '解析',
    `time_limit` INT COMMENT '时间限制（秒）',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_knowledge_point_id (`knowledge_point_id`),
    INDEX idx_type (`type`),
    INDEX idx_difficulty (`difficulty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='练习题表';

CREATE TABLE IF NOT EXISTS `user_exercise` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `exercise_id` BIGINT NOT NULL COMMENT '题目ID',
    `user_answer` TEXT COMMENT '用户答案',
    `is_correct` TINYINT COMMENT '是否正确：0-否，1-是',
    `score` INT COMMENT '得分',
    `submit_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_user_id (`user_id`),
    INDEX idx_exercise_id (`exercise_id`),
    INDEX idx_submit_time (`submit_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户做题记录表';

CREATE TABLE IF NOT EXISTS `learning_progress` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '进度ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `knowledge_point_id` BIGINT NOT NULL COMMENT '知识点ID',
    `status` VARCHAR(20) NOT NULL DEFAULT 'NOT_STARTED' COMMENT '学习状态：NOT_STARTED, LEARNING, COMPLETED, MASTERED',
    `study_duration` INT NOT NULL DEFAULT 0 COMMENT '学习时长（分钟）',
    `last_study_time` DATETIME COMMENT '最后学习时间',
    `mastery_score` INT COMMENT '掌握程度分数（0-100）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    UNIQUE KEY uk_user_knowledge (`user_id`, `knowledge_point_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_knowledge_point_id (`knowledge_point_id`),
    INDEX idx_status (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习进度表';

CREATE TABLE IF NOT EXISTS `learning_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `knowledge_point_id` BIGINT COMMENT '知识点ID',
    `action_type` VARCHAR(50) NOT NULL COMMENT '动作类型：VIEW, STUDY, EXERCISE, VIDEO_WATCH',
    `action_detail` VARCHAR(500) COMMENT '动作详情',
    `duration` INT COMMENT '持续时间（秒）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (`user_id`),
    INDEX idx_knowledge_point_id (`knowledge_point_id`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学习行为记录表';

CREATE TABLE IF NOT EXISTS `video` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '视频ID',
    `knowledge_point_id` BIGINT NOT NULL COMMENT '知识点ID',
    `title` VARCHAR(200) NOT NULL COMMENT '标题',
    `description` TEXT COMMENT '描述',
    `video_url` VARCHAR(500) NOT NULL COMMENT '视频URL',
    `duration` INT COMMENT '视频时长（秒）',
    `thumbnail_url` VARCHAR(500) COMMENT '缩略图URL',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除：0-否，1-是',
    INDEX idx_knowledge_point_id (`knowledge_point_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='视频表';

CREATE TABLE IF NOT EXISTS `video_watch_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `video_id` BIGINT NOT NULL COMMENT '视频ID',
    `watch_progress` INT NOT NULL DEFAULT 0 COMMENT '观看进度（0-100）',
    `watch_duration` INT NOT NULL DEFAULT 0 COMMENT '观看时长（秒）',
    `last_watch_time` DATETIME COMMENT '最后观看时间',
    `is_completed` TINYINT NOT NULL DEFAULT 0 COMMENT '是否完成：0-否，1-是',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_user_video (`user_id`, `video_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_video_id (`video_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='视频观看记录表';

CREATE TABLE IF NOT EXISTS `ai_chat` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '对话ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `session_id` VARCHAR(100) NOT NULL COMMENT '会话ID',
    `role` VARCHAR(20) NOT NULL COMMENT '角色：USER, ASSISTANT',
    `content` TEXT NOT NULL COMMENT '内容',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    INDEX idx_user_id (`user_id`),
    INDEX idx_session_id (`session_id`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI对话记录表';

CREATE TABLE IF NOT EXISTS `code_submission` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '提交ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `exercise_id` BIGINT COMMENT '题目ID',
    `code` TEXT NOT NULL COMMENT '提交的代码',
    `language` VARCHAR(20) NOT NULL DEFAULT 'C++' COMMENT '编程语言',
    `analysis_result` JSON COMMENT 'AI分析结果',
    `status` VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '状态：PENDING, SUCCESS, ERROR',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (`user_id`),
    INDEX idx_exercise_id (`exercise_id`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代码提交记录表';
