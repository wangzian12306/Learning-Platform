# 《数据结构》课程智慧学习平台 - Docker 部署指南

## 项目概述

本项目是一个基于 Vue 3 + Spring Boot + Neo4j + MySQL 的数据结构课程智慧学习平台，包含知识点学习、习题练习、知识图谱可视化、AI 助教、代码在线运行等功能模块。

## 系统架构

```
┌─────────────┐
│   浏览器     │  http://localhost
└──────┬──────┘
       │
┌──────▼──────┐
│   Nginx     │  前端静态资源 + API 反向代理
│  (frontend) │  :80
└──┬───────┬──┘
   │       │
   │ /api/ │ /api/ai/
   │       │
┌──▼──┐ ┌──▼───┐
│后端  │ │AI服务 │
│Spring│ │FastAPI│
│Boot  │ │Python │
│:8088 │ │:9000  │
└──┬──┘ └──┬───┘
   │       │
┌──▼───────▼──┐   ┌──────┐   ┌──────┐
│   MySQL 8.0 │   │Neo4j │   │Piston│
│   :3306     │   │:7687 │   │:2000 │
└─────────────┘   └──────┘   └──────┘
```

## 环境要求

- **Docker** >= 20.10
- **Docker Compose** >= 2.0（或 Docker Desktop 内置的 compose）
- **内存** >= 8GB（推荐 16GB，Neo4j 和 Piston 较占内存）
- **磁盘** >= 10GB 可用空间

## 快速启动

### 1. 克隆项目

```bash
git clone <项目仓库地址>
cd code
```

### 2. 一键启动所有服务

```bash
docker compose up -d --build
```

首次启动需要构建镜像和下载数据，预计耗时 5-15 分钟（取决于网络速度）。

### 3. 等待服务就绪

```bash
docker compose logs -f
```

观察日志，当看到以下信息时表示服务已就绪：
- MySQL: `ready for connections`
- Neo4j: `Neo4j服务准备就绪`
- 后端: `Started LearningPlatformApplication`
- AI服务: `Application startup complete`
- 前端: 无特殊日志，Nginx 启动即可

### 4. 访问系统

- **前端页面**: http://localhost
- **后端 API**: http://localhost/api
- **Neo4j 浏览器**: http://localhost:7474（用户名: neo4j，密码: neo4j123）

### 5. 默认测试账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| student1 | 123456 | 学生 |

## 服务说明

| 服务 | 容器名 | 端口 | 说明 |
|------|--------|------|------|
| mysql | learning-platform-mysql | 3306（内部） | MySQL 8.0 数据库 |
| neo4j | learning-platform-neo4j | 7474/7687（内部） | Neo4j 5.19 图数据库 |
| piston | piston | 2000（内部） | 代码执行引擎 |
| backend | learning-platform-backend | 8088（内部） | Spring Boot 后端 |
| ai-service | learning-platform-ai | 9000（内部） | FastAPI AI 助教 |
| frontend | learning-platform-frontend | 80 → 80 | Nginx 前端 |

## 数据初始化

### MySQL 数据

MySQL 容器首次启动时会自动执行以下 SQL 脚本（按文件名排序）：

1. `data-layer/mysql/00_schema.sql` - 建表（12 张表）
2. `data-layer/mysql/50_data_dump.sql` - 初始化数据

初始化数据包含：
- 30 个知识点（集合、线性表、树、图、查找、排序 6 大模块）
- 120+ 条知识点内容（操作原理、复杂度分析等）
- 30+ 个代码示例（C++ 实现）
- 120+ 道习题（选择题、填空题、编程题）
- 1 个测试用户（student1 / 123456）

> **注意**: SQL 脚本仅在 MySQL 数据卷首次创建时执行。如需重新初始化，请先删除数据卷：
> ```bash
> docker compose down -v
> docker compose up -d --build
> ```

### Neo4j 数据

Neo4j 容器首次启动时会自动执行：
1. `data-layer/neo4j/schema.cql` - 创建索引和约束
2. `data-layer/neo4j/import/knowledge_points.cypher` - 导入 52 个知识点节点和关系

包含：
- 52 个 KnowledgePoint 节点（6 个模块 + 24 个二级知识点 + 22 个三级知识点）
- 24 条 PARENT_OF 关系（层级关系）
- 5 条 RELATED_TO 关系（跨模块关联）

## AI 助教配置（可选）

AI 助教使用阿里云通义千问 API，需要配置 API Key 才能使用对话功能。**不配置 API Key 不影响其他功能，AI 服务仍会正常启动，只是对话请求会返回错误提示。**

### 配置方式

1. 复制示例配置文件并填写 API Key：
```bash
cp src/python/AIchat/config/apikeys.example.json src/python/AIchat/config/apikeys.local.json
```

2. 编辑 `src/python/AIchat/config/apikeys.local.json`，填入你的通义千问 API Key：
```json
{
  "qwen": "sk-你的API Key",
  "deepseek": "",
  "openai": ""
}
```

3. 重新构建 AI 服务：
```bash
docker compose up -d --build ai-service
```

> 如果不配置 API Key，AI 对话功能将不可用，但其他功能不受影响。

## 常用运维命令

```bash
# 查看所有服务状态
docker compose ps

# 查看某个服务日志
docker compose logs -f backend
docker compose logs -f mysql

# 重启某个服务
docker compose restart backend

# 重新构建并启动某个服务
docker compose up -d --build backend

# 停止所有服务
docker compose down

# 停止并删除数据卷（重置所有数据）
docker compose down -v

# 进入 MySQL 容器
docker exec -it learning-platform-mysql mysql -uroot -proot123 learning_platform

# 进入 Neo4j 容器执行 Cypher
docker exec -it learning-platform-neo4j cypher-shell -u neo4j -p neo4j123
```

## 数据库连接信息

| 参数 | 值 |
|------|-----|
| MySQL 主机 | mysql（容器内） / localhost（宿主机需映射端口） |
| MySQL 端口 | 3306 |
| MySQL 用户 | root |
| MySQL 密码 | root123 |
| MySQL 数据库 | learning_platform |
| Neo4j URI | bolt://neo4j:7687（容器内） |
| Neo4j 用户 | neo4j |
| Neo4j 密码 | neo4j123 |

## 端口映射

默认只暴露前端 80 端口。如需从宿主机直接访问数据库或后端，可在 `docker-compose.yml` 中添加端口映射：

```yaml
mysql:
  ports:
    - "13306:3306"   # 宿主机 13306 → 容器 3306

neo4j:
  ports:
    - "17474:7474"   # Neo4j Browser
    - "17687:7687"   # Neo4j Bolt

backend:
  ports:
    - "8088:8088"    # 后端 API
```

## 故障排查

### 1. MySQL 初始化失败

```bash
# 查看初始化日志
docker compose logs mysql

# 常见原因：数据卷已存在旧数据，需要清除
docker compose down -v
docker compose up -d
```

### 2. Neo4j 启动缓慢

Neo4j 首次启动需要 30-60 秒，属于正常现象。后端服务会等待 Neo4j 健康检查通过后才启动。

### 3. 后端无法连接数据库

```bash
# 检查 MySQL 和 Neo4j 是否就绪
docker compose ps
# 确认 mysql 和 neo4j 状态为 healthy

# 查看后端日志
docker compose logs backend
```

### 4. Piston 代码运行超时

Piston 首次运行代码时需要下载语言运行时，可能较慢。后续运行会使用缓存。

### 5. 前端页面空白

```bash
# 检查前端容器日志
docker compose logs frontend

# 检查 Nginx 配置是否正确
docker exec learning-platform-frontend nginx -t
```

### 6. 重新构建某个服务

```bash
# 重新构建后端（代码更新后）
docker compose up -d --build backend

# 重新构建前端
docker compose up -d --build frontend

# 重新构建所有服务
docker compose up -d --build
```

## 项目目录结构

```
code/
├── docker-compose.yml          # Docker Compose 主配置
├── pom.xml                     # Maven 项目配置
├── docker/                     # Docker 相关文件
│   ├── backend/
│   │   ├── Dockerfile          # 后端镜像构建
│   │   └── application-docker.yml  # Docker 环境配置
│   ├── frontend/
│   │   ├── Dockerfile          # 前端镜像构建
│   │   └── nginx.conf          # Nginx 配置
│   ├── ai/
│   │   ├── Dockerfile          # AI 服务镜像构建
│   │   └── .env                # AI 服务环境变量
│   └── neo4j/
│       └── entrypoint.sh       # Neo4j 启动脚本
├── data-layer/                 # 数据层
│   ├── mysql/
│   │   ├── 00_schema.sql       # 建表脚本
│   │   └── 50_data_dump.sql    # 初始化数据
│   └── neo4j/
│       ├── schema.cql          # Neo4j 索引和约束
│       ├── import/
│       │   └── knowledge_points.cypher  # 知识点数据
│       └── auto_import.sh      # 自动导入脚本
├── src/                        # 源代码
│   ├── main/java/              # Java 后端
│   └── python/AIchat/          # Python AI 服务
└── frontend/                   # Vue 3 前端
    ├── src/
    ├── package.json
    └── vite.config.js
```
