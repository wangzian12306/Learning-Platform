<template>
  <div class="page-placeholder">
    <el-empty description="代码在线运行模块 — 待开发">
      <template #description>
        <p><strong>模块：</strong>代码实现与在线运行</p>
        <p><strong>owner：</strong>代码实现与在线运行负责人</p>
        <p><strong>主目录：</strong><code>frontend/src/views/CodePlayground/</code>、<code>frontend/src/components/CodeEditor/</code>、<code>frontend/src/components/Visualizer/</code></p>
        <p><strong>API：</strong><code>src/api/modules/code.js</code> 的 <code>runCode(data)</code></p>
        <p><strong>布局参考：</strong>左侧编辑器 + 右侧可视化/运行结果，参考 algorithm-visualizer</p>
      </template>
    </el-empty>
  </div>
</template>

<style scoped>
.page-placeholder { display: flex; align-items: center; justify-content: center; min-height: 400px; }
p { margin: 4px 0; color: #606266; font-size: 14px; }
</style>
