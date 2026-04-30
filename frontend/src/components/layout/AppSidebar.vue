<template>
  <el-menu
    :collapse="collapsed"
    :default-active="activeRoute"
    router
    background-color="#001529"
    text-color="#ffffffa6"
    active-text-color="#ffffff"
    class="sidebar-menu"
  >
    <div class="logo-area">
      <span v-if="!collapsed" class="logo-text">数据结构学习平台</span>
      <span v-else class="logo-icon">DS</span>
    </div>

    <el-menu-item v-for="item in menuItems" :key="item.path" :index="item.path">
      <el-icon><component :is="item.icon" /></el-icon>
      <template #title>{{ item.label }}</template>
    </el-menu-item>
  </el-menu>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import {
  House,
  Share,
  List,
  Document,
  Monitor,
  EditPen,
  DataLine,
  ChatDotRound,
  VideoPlay,
} from '@element-plus/icons-vue'

defineProps({
  collapsed: { type: Boolean, default: false },
})

const route = useRoute()
const activeRoute = computed(() => '/' + route.path.split('/')[1])

const menuItems = [
  { path: '/home',        label: '首页',        icon: House },
  { path: '/graph',       label: '知识图谱',    icon: Share },
  { path: '/knowledge',   label: '学习目录',    icon: List },
  { path: '/playground',  label: '代码运行',    icon: Monitor },
  { path: '/exercise',    label: '习题练习',    icon: EditPen },
  { path: '/statistics',  label: '学习统计',    icon: DataLine },
  { path: '/ai-chat',     label: 'AI 辅助',     icon: ChatDotRound },
  { path: '/video',       label: '视频讲解',    icon: VideoPlay },
]
</script>

<style scoped>
.sidebar-menu {
  height: 100%;
  border-right: none;
}

.logo-area {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid #ffffff1a;
  margin-bottom: 8px;
}

.logo-text {
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
}

.logo-icon {
  color: #fff;
  font-size: 16px;
  font-weight: 700;
}
</style>
