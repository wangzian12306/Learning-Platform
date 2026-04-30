<template>
  <div class="page-placeholder">
    <el-empty description="知识点详情模块 — 待开发">
      <template #description>
        <p><strong>模块：</strong>知识点详细讲解（图文）</p>
        <p><strong>owner：</strong>知识点详细讲解负责人</p>
        <p><strong>主目录：</strong><code>frontend/src/views/KnowledgeDetail/</code></p>
        <p><strong>路由参数：</strong><code>$route.params.module</code>（模块）、<code>$route.params.id</code>（知识点 ID）</p>
        <p><strong>数据来源：</strong><code>src/api/modules/knowledge.js</code> 的 <code>getKnowledgeDetail(id)</code></p>
      </template>
    </el-empty>
  </div>
</template>

<style scoped>
.page-placeholder { display: flex; align-items: center; justify-content: center; min-height: 400px; }
p { margin: 4px 0; color: #606266; font-size: 14px; }
</style>
