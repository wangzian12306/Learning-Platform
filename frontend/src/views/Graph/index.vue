<template>
  <div class="page-placeholder">
    <el-empty description="知识图谱可视化模块 — 待开发">
      <template #description>
        <p><strong>模块：</strong>知识图谱交互式可视化</p>
        <p><strong>owner：</strong>知识图谱交互式可视化负责人</p>
        <p><strong>主目录：</strong><code>frontend/src/views/Graph/</code>、<code>frontend/src/components/KnowledgeGraph/</code></p>
        <p><strong>数据来源：</strong>调用 <code>src/api/modules/graph.js</code> 中的 <code>getGraphData()</code></p>
      </template>
    </el-empty>
  </div>
</template>

<style scoped>
.page-placeholder { display: flex; align-items: center; justify-content: center; min-height: 400px; }
p { margin: 4px 0; color: #606266; font-size: 14px; }
</style>
