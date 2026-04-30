<template>
  <div class="page-placeholder">
    <el-empty description="视频讲解模块 — 待开发">
      <template #description>
        <p><strong>模块：</strong>视频讲解 + 全局整合</p>
        <p><strong>owner：</strong>视频讲解 + 全局整合负责人</p>
        <p><strong>主目录：</strong><code>frontend/src/views/VideoPlayer/</code>、<code>frontend/src/components/Video/</code></p>
        <p><strong>API：</strong><code>src/api/modules/video.js</code></p>
        <p><strong>注意：</strong>视频播放方案（直链/HLS）待架构 owner 确定后接入</p>
      </template>
    </el-empty>
  </div>
</template>

<style scoped>
.page-placeholder { display: flex; align-items: center; justify-content: center; min-height: 400px; }
p { margin: 4px 0; color: #606266; font-size: 14px; }
</style>
