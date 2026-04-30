<template>
  <div class="page-home">
    <el-card class="welcome-card">
      <h2>欢迎使用《数据结构》智慧学习平台</h2>
      <p>请通过左侧导航栏选择功能模块开始学习。</p>
      <el-row :gutter="16" style="margin-top: 24px">
        <el-col :span="6" v-for="item in cards" :key="item.path">
          <el-card shadow="hover" class="nav-card" @click="router.push(item.path)">
            <el-icon :size="28"><component :is="item.icon" /></el-icon>
            <div class="nav-card-label">{{ item.label }}</div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { Share, List, Monitor, EditPen, DataLine, ChatDotRound, VideoPlay } from '@element-plus/icons-vue'

const router = useRouter()
const cards = [
  { path: '/graph',      label: '知识图谱',  icon: Share },
  { path: '/knowledge',  label: '学习目录',  icon: List },
  { path: '/playground', label: '代码运行',  icon: Monitor },
  { path: '/exercise',   label: '习题练习',  icon: EditPen },
  { path: '/statistics', label: '学习统计',  icon: DataLine },
  { path: '/ai-chat',    label: 'AI 辅助',   icon: ChatDotRound },
  { path: '/video',      label: '视频讲解',  icon: VideoPlay },
]
</script>

<style scoped>
.page-home { max-width: 960px; margin: 0 auto; }
.welcome-card h2 { margin: 0 0 8px; }
.welcome-card p  { color: #606266; margin: 0; }
.nav-card {
  text-align: center;
  cursor: pointer;
  padding: 16px 0;
  margin-bottom: 16px;
}
.nav-card-label { margin-top: 8px; font-size: 14px; }
</style>
