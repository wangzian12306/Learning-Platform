<template>
  <el-container class="app-layout">
    <el-aside :width="isCollapsed ? '64px' : '220px'" class="app-aside">
      <AppSidebar :collapsed="isCollapsed" />
    </el-aside>
    <el-container class="main-container">
      <el-header class="app-header">
        <AppHeader @toggle-sidebar="isCollapsed = !isCollapsed" />
      </el-header>
      <el-main class="app-main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref } from 'vue'
import AppSidebar from './AppSidebar.vue'
import AppHeader from './AppHeader.vue'

const isCollapsed = ref(false)
</script>

<style scoped>
.app-layout {
  height: 100vh;
  overflow: hidden;
}

.app-aside {
  transition: width 0.25s;
  overflow: hidden;
  background-color: #001529;
}

.main-container {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.app-header {
  height: 56px;
  padding: 0;
  border-bottom: 1px solid #e8e8e8;
  background: #fff;
  display: flex;
  align-items: center;
}

.app-main {
  flex: 1;
  overflow-y: auto;
  background: #f5f7fa;
  padding: 24px;
}
</style>
