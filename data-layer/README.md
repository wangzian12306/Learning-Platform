# 数据层目录

## 目录结构

```
data-layer/
├── docker/                     # Docker配置
│   ├── docker-compose.yml      # MySQL + Neo4j
│   ├── .env                    # 环境变量
│   └── neo4j-entrypoint.sh     # 自动导入入口
├── scripts/                    # 数据库脚本
│   ├── mysql/                  # MySQL脚本
│   │   ├── init.sql            # 初始化脚本
│   │   └── mysql-modules/      # 各模块数据
│   └── neo4j/                  # Neo4j脚本
│       ├── schema.cql          # 索引和约束
│       └── auto_import.sh      # 自动导入脚本
└── data/                       # 数据文件
    ├── neo4j_import/           # Neo4j导入数据
    │   ├── nodes/              # 节点CSV
    │   └── relationships/      # 关系CSV
    └── dictionary/             # 数据字典
        └── knowledge_point_dict.md
```

## 快速开始

### 启动服务
```bash
cd docker
docker-compose up -d
```

### 访问地址
- MySQL: `localhost:13306` (root/root123)
- Neo4j: `http://localhost:17474` (neo4j/neo4j123)
- Neo4j Bolt: `bolt://localhost:17687`

## 数据导入

### MySQL数据
启动Docker时自动执行 `scripts/mysql/init.sql`

### Neo4j数据
启动Docker时自动导入 `data/neo4j_import/` 下的CSV文件

## 协作流程

1. 填写 `data/dictionary/knowledge_point_dict.md`
2. 编写 `scripts/mysql/mysql-modules/` 下的模块SQL
3. 数据层负责人审核并生成CSV
4. 重启Docker自动导入

## 注意事项

- 端口已调整避免与本地服务冲突
- 数据持久化到Docker Volumes
- CSV文件需放置在 `data/neo4j_import/` 目录
