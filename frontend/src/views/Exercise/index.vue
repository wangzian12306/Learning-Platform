<template>
  <div class="page-placeholder">
    <el-empty description="习题模块 — 待开发">
      <template #description>
        <p><strong>模块：</strong>习题模块</p>
        <p><strong>owner：</strong>习题模块负责人</p>
        <p><strong>主目录：</strong><code>frontend/src/views/Exercise/</code></p>
        <p><strong>API：</strong><code>src/api/modules/exercise.js</code></p>
        <p><strong>做题结果：</strong>通过 <code>src/api/modules/statistics.js</code> 的 <code>recordBehavior()</code> 上报给统计模块</p>
      </template>
    </el-empty>
  </div>
</template>

<style scoped>
.page-placeholder { display: flex; align-items: center; justify-content: center; min-height: 400px; }
p { margin: 4px 0; color: #606266; font-size: 14px; }
</style>
