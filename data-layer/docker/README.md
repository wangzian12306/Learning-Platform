# 数据层 Docker 使用说明

## 目录结构

```
data-layer/
├── docker/                     # Docker配置
│   ├── docker-compose.yml      # MySQL + Neo4j
│   ├── .env                    # 环境变量
│   └── neo4j-entrypoint.sh     # 自动导入入口
├── scripts/                    # 数据库脚本
│   ├── mysql/                  # MySQL脚本
│   └── neo4j/                  # Neo4j脚本
└── data/                       # 数据文件
```

## 快速启动

### 1. 启动服务
```bash
# 进入数据层Docker目录
cd data-layer/docker

# 启动 MySQL 和 Neo4j
docker-compose up -d

# 查看运行状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 2. 停止服务
```bash
# 停止服务 (保留数据)
docker-compose down

# 停止服务并删除数据卷 (⚠️ 会清空所有数据!)
docker-compose down -v
```

### 3. 重启服务
```bash
docker-compose restart
```

## 访问地址

### MySQL
- 地址: `localhost:13306`
- 用户名: `root`
- 密码: `root123`
- 数据库: `learning_platform`

### Neo4j
- 浏览器: `http://localhost:17474`
- Bolt协议: `bolt://localhost:17687`
- 用户名: `neo4j`
- 密码: `neo4j123`

## 数据持久化

数据自动持久化到 Docker Volumes:
- `mysql_data`: MySQL 数据
- `neo4j_data`: Neo4j数据

即使容器删除，数据也不会丢失。

## 数据导入

### MySQL
启动Docker时自动执行 `../scripts/mysql/init.sql`

### Neo4j
启动Docker时自动导入 `../data/neo4j_import/` 下的CSV文件

## Neo4j数据导入

启动Docker时会自动导入 `../data/neo4j_import/` 下的CSV文件

如需重新导入：
```bash
cd data-layer/docker
docker-compose down -v  # ⚠️ 会清空所有数据
docker-compose up -d
```

## 备份与恢复

### 备份MySQL数据
```bash
# 备份整个数据库
docker exec learning-platform-mysql mysqldump -uroot -proot123 learning_platform > backup.sql

# 备份数据卷
docker run --rm -v learning-platform_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql-data.tar.gz /data
```

### 备份Neo4j数据
```bash
# 备份Neo4j数据库
docker exec learning-platform-neo4j neo4j-admin dump --to=/backups/neo4j-backup

# 恢复Neo4j数据库
docker exec learning-platform-neo4j neo4j-admin load --from=/backups/neo4j-backup
```

## 故障排查

### 查看容器日志
```bash
# 查看所有日志
docker-compose logs

# 查看MySQL日志
docker-compose logs mysql

# 查看Neo4j日志
docker-compose logs neo4j
```

### 进入容器
```bash
# 进入MySQL容器
docker exec -it learning-platform-mysql bash

# 进入Neo4j容器
docker exec -it learning-platform-neo4j bash
```

### 检查健康状态
```bash
docker ps
```

## 环境变量配置

可通过 `.env` 文件自定义配置:
```env
MYSQL_ROOT_PASSWORD=your_password
MYSQL_DATABASE=your_database
NEO4J_AUTH=neo4j/your_password
```

## 注意事项

1. **端口占用**: 确保 13306、17474、17687 端口未被占用
2. **数据备份**: 定期备份重要数据
3. **资源限制**: 建议至少分配 4GB 内存给 Docker
4. **网络隔离**: 数据层网络与后端网络隔离，通过端口映射访问

## 与后端协作

### 后端如何连接数据库

后端只需在 `application.yml` 中配置:
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:13306/learning_platform
    username: root
    password: root123
  
  neo4j:
    uri: bolt://localhost:17687
    authentication:
      username: neo4j
      password: neo4j123
```

**数据层负责维护数据库运行，后端负责连接使用，互不干扰。**
