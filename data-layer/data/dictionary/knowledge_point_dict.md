# 知识点数据字典

## 使用说明

本文档用于团队共同梳理和记录知识点信息。各模块负责人填写对应模块的知识点清单。

## 填写规范

### 必填字段
- **neo4j_id**: 按规范编号 (KP_模块前缀_序号)
- **name**: 知识点名称
- **code**: 知识点编码 (英文大写，下划线分隔)
- **module**: 所属模块
- **level**: 层级 (1/2/3)
- **difficulty**: 难度 (EASY/MEDIUM/HARD)

### 选填字段
- **description**: 知识点描述
- **core_points**: 核心考点
- **parent_id**: 父知识点ID (MySQL)
- **relations**: 关联知识点及关系类型

---

## 模块: 集合 (SET)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_SET_001 | 集合 | SET | 1 | EASY | 集合的基本概念 | 集合定义、性质 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 线性表 (LINEAR_LIST)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_LL_001 | 线性表 | LINEAR_LIST | 1 | EASY | 线性表的基本概念 | 线性表定义、特点 | NULL | - |
| KP_LL_002 | 数组 | ARRAY | 3 | EASY | 数组的实现和特点 | 连续内存、随机访问 | NULL | KP_LL_003 (PREREQUISITE, 5) |
| KP_LL_003 | 链表 | LINKED_LIST | 3 | MEDIUM | 链表的实现和特点 | 指针操作、动态分配 | NULL | KP_LL_002 (EXTENSION, 4) |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 树 (TREE)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_TREE_001 | 树 | TREE | 1 | EASY | 树的基本概念 | 树的定义、术语 | NULL | - |
| KP_TREE_002 | 二叉树 | BINARY_TREE | 2 | MEDIUM | 二叉树的定义和性质 | 二叉树特性、遍历 | KP_TREE_001 | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 图 (GRAPH)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_GRAPH_001 | 图 | GRAPH | 1 | MEDIUM | 图的基本概念 | 图的定义、术语 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 查找 (SEARCH)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_SEARCH_001 | 查找 | SEARCH | 1 | MEDIUM | 查找的基本概念 | 查找算法分类 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 模块: 排序 (SORT)

| neo4j_id | name | code | level | difficulty | description | core_points | parent_id | relations |
|----------|------|------|-------|------------|-------------|-------------|-----------|-----------|
| KP_SORT_001 | 排序 | SORT | 1 | MEDIUM | 排序的基本概念 | 排序算法分类 | NULL | - |
| | | | | | | | | |

**负责人**: XXX  
**最后更新**: 2024-XX-XX

---

## 关联关系说明

### 关系类型
- **PREREQUISITE**: 前置知识 (学习A之前需要先学习B)
- **EXTENSION**: 扩展知识 (学习A后可以进一步学习B)
- **COMPARISON**: 对比知识 (A和B可以对比学习)

### 关联强度
- **5**: 强关联 (必须一起学习)
- **4**: 较强关联
- **3**: 中等关联
- **2**: 较弱关联
- **1**: 弱关联

### 填写示例
```
KP_LL_002 (数组) -[PREREQUISITE, strength:5]-> KP_LL_003 (链表)
说明: 学习链表之前需要先掌握数组 (强度5)
```

---

## 编号规则

1. **模块前缀**: KP_SET_, KP_LL_, KP_TREE_, KP_GRAPH_, KP_SEARCH_, KP_SORT_
2. **序号**: 3位数字，不足补零 (001-999)
3. **编号顺序**: 按层级从上到下，同层级按逻辑顺序
4. **预留空号**: 便于后续插入新知识点

---

## 更新记录

| 日期 | 修改人 | 修改内容 |
|------|--------|----------|
| 2024-XX-XX | XXX | 初始版本 |
| | | |
