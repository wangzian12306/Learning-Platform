# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

基于 Spring Boot 的《数据结构》课程智慧学习平台。采用双数据库架构（MySQL + Neo4j）和前后端分离 + 独立 AI 微服务的多服务架构。

## 构建与运行

### 后端（Spring Boot）
- **构建**: `mvn clean package`
- **运行**: `mvn spring-boot:run`
- **运行测试**: `mvn test`
- **运行单个测试**: `mvn test -Dtest=ClassName`
- **监听地址**: `0.0.0.0:8088`，context-path `/api`

### 前端（Vue 3 + Vite）
- **安装依赖**: `cd frontend && npm install`
- **开发服务器**: `cd frontend && npm run dev`（localhost:5173）
- **构建**: `cd frontend && npm run build`

### Python AI 服务（FastAPI）
- **启动**: `cd src/python/AIchat && pip install -r requirements.txt && python run.py`
- **监听地址**: `0.0.0.0:9000`
- **配置 Key**: 复制 `config/apikeys.example.json` → `config/apikeys.local.json`

### Docker 一键部署
- `docker compose up -d`（MySQL 13306、Neo4j 17687、Piston 2000、后端、AI 服务、前端 Nginx 80）

### 外部服务依赖
- **Piston**（代码执行）: `http://localhost:2000`，支持 C/C++/Python，可通过 Docker 启动
- 前端开发模式通过 Vite proxy 将 `/api` 代理到后端 `8088`，`/api/ai` 代理到 AI 服务 `9000`

## 开发环境

- JDK 17+、Maven 3.6+、Node.js（前端）
- MySQL 8.0+（端口 13306，初始化脚本 `data-layer/mysql/00_schema.sql`）
- Neo4j 5.0+（bolt 端口 17687，初始化脚本 `data-layer/neo4j/`）

## 架构

### 双数据库
- **MySQL**（MyBatis Plus 访问）: 用户、习题、学习进度、视频、AI 对话记录等结构化数据
- **Neo4j**（`Neo4jClient` 直接执行 Cypher，非 Spring Data Repository）: 知识图谱节点和关系
- 关联方式: MySQL `knowledge_point.neo4j_id` 映射到 Neo4j 节点，手动通过 Cypher 脚本同步

### 后端代码约定
- **统一响应**: Controllers 返回 `Result<T>`（`common/Result.java`），包装 `code`/`message`/`data`
- **异常处理**: 业务异常 `BusinessException`，全局捕获 `GlobalExceptionHandler`（`@ControllerAdvice`）
- **实体基类**: 所有 Entity 继承 `BaseEntity`（自动提供 `createTime`/`updateTime`/逻辑删除 `isDeleted`）
- **自动填充**: `MyMetaObjectHandler` 在 insert 时设 `createTime`，insert/update 时设 `updateTime`
- **Mapper 扫描**: 无全局 `@MapperScan`，每个 Mapper 接口独立标注 `@Mapper`
- **逻辑删除**: `application.yml` 中 `logic-delete-field: isDeleted`，值为 1/0
- **参数校验**: Controller 层 `@Validated` + `@Valid`
- **JSON**: Jackson（`non_null` 序列化、`yyyy-MM-dd HH:mm:ss` 日期格式）

### 后端包结构
- `controller/` — REST 控制器（7 个: User, KnowledgePoint, Exercise, Code, Video, Statistics, Graph）
- `service/` — 业务逻辑（继承 MyBatis Plus `ServiceImpl`）
- `repository/` — MyBatis Plus Mapper 接口
- `entity/` — 实体类（继承 `BaseEntity`）
- `dto/` — 请求/响应 DTO
- `config/` — Spring 配置（`MyMetaObjectHandler`, `MybatisPlusConfig` 分页拦截器, `WebConfig`）
- `common/` — `Result<T>`, `BusinessException`, `GlobalExceptionHandler`

### 前端架构
- **技术栈**: Vue 3 Composition API + Vite + Element Plus + Pinia + Vue Router
- **可视化**: D3.js（知识图谱）+ ECharts（统计图表）
- **代码编辑器**: Monaco Editor（代码操场）
- **Markdown**: marked（知识点内容渲染）
- **状态管理**: Pinia（5 个 store，部分使用 localStorage 持久化）
- **API 层**: `src/api/` 下按模块组织，统一 Axios 拦截器处理 token 和错误
- **路径别名**: `@` → `./src`

### Python AI 服务架构
`src/python/AIchat/app/`:
- `api/routes.py` — FastAPI 路由
- `services/chat_service.py` — 多轮对话逻辑
- `services/ai_provider.py` — 通义千问/DeepSeek 接入（OpenAI 兼容 API）
- `repositories/chat_repository.py` — MySQL 对话记录持久化
- 支持三种能力: QA、CODE_ANALYSIS、CODE_GENERATION

## 协作规范

本项目为多人协作项目，请遵守以下规则。

### 开工前必读
- `docs/项目架构.md` — 当前架构和 TODO 清单
- `docs/分工.md` — 各模块负责人
- `docs/要求.md` — 完整功能需求

### 代码改动
- **改动最小化**: 只改需要的部分，不重构无关代码
- **Fail fast**: 异常自然冒泡，不静默 catch
- 不写假设性防御代码。仅在系统边界（用户输入、外部 API）做验证，内部信任调用方
- 遵循现有包结构和命名规范

### 文档同步
- 新增或修改表结构 → 同步更新 `data-layer/mysql/00_schema.sql`
- 架构决策或解决 TODO → 同步更新 `docs/项目架构.md`
- 模块负责人变更 → 同步更新 `docs/分工.md`
- API 契约变更 → PR 描述中说明
- 所有文档使用中文（代码和注释除外）

### Git 工作流
- 在 `feature/<模块>-<描述>` 分支开发
- PR 需至少一次 review 才能合并到 `main`
- 禁止向 `main` force-push

### 测试
- PR 前运行 `mvn test`
- 新增接口后用 `curl` 或本地请求手动验证

## 文档索引

项目文档位于 `docs/`，均为中文。核心文档:
- `要求.md` — 需求文档
- `分工.md` — 团队分工
- `项目架构.md` — 架构说明（含 TODO 清单）
- `API接口规范.md` — API 接口规范
- `数据库交互契约.md` — 数据库交互约定
- `数据层协同规范.md` — 数据层协作规范
- `待补充能力清单.md` — 关键能力缺口
- `可参考项目.md` — 参考项目分析

模块说明文档: `习题模块说明.md`、`代码实现与在线运行模块.md`、`学习统计模块说明.md`、`知识图谱可视化.md`、`学习目录功能总结.md`、`视频讲解联调清单.md`、`前端框架使用指南.md` 等
