# 数据层目录说明

## 目录结构

```
data/
├── neo4j_import/              # Neo4j导入数据目录
│   ├── nodes/                 # 节点数据CSV
│   │   └── knowledge_points.csv  # 知识点节点数据
│   └── relationships/         # 关系数据CSV
│       ├── parent_of.csv      # 层级关系数据
│       └── related_to.csv     # 关联关系数据
└── dictionary/                # 数据字典
    └── knowledge_point_dict.md # 知识点数据字典模板
```

## 文件说明

### knowledge_points.csv
知识点节点数据，包含以下字段：
- neo4j_id: Neo4j节点唯一标识
- name: 知识点名称
- code: 知识点编码
- module: 所属模块
- level: 层级
- difficulty: 难度等级
- description: 知识点描述
- core_points: 核心考点
- mysql_id: 对应的MySQL记录ID

### parent_of.csv
知识点层级关系数据，包含以下字段：
- :START_ID: 父节点neo4j_id
- :END_ID: 子节点neo4j_id
- order: 排序序号

### related_to.csv
知识点关联关系数据，包含以下字段：
- :START_ID: 起始节点neo4j_id
- :END_ID: 目标节点neo4j_id
- type: 关联类型 (PREREQUISITE/EXTENSION/COMPARISON)
- strength: 关联强度 (1-5)

### knowledge_point_dict.md
知识点数据字典模板，用于团队共同梳理知识点信息。

## 使用说明

1. 各模块负责人在 `knowledge_point_dict.md` 中填写知识点信息
2. 数据层负责人审核后生成CSV文件
3. 使用 `sql/neo4j/import_template.cypher` 脚本导入Neo4j
4. 定期校验MySQL与Neo4j数据一致性
