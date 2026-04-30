<template>
  <div class="header-inner">
    <el-button
      text
      :icon="Fold"
      class="collapse-btn"
      @click="emit('toggle-sidebar')"
    />
    <span class="page-title">{{ currentTitle }}</span>
    <div class="header-right">
      <el-dropdown>
        <el-avatar :size="32" class="user-avatar">
          {{ userInitial }}
        </el-avatar>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item>个人信息</el-dropdown-item>
            <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Fold } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user.js'

const emit = defineEmits(['toggle-sidebar'])
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const currentTitle = computed(() => route.meta?.title ?? '')
const userInitial = computed(() => userStore.userInfo?.username?.[0]?.toUpperCase() ?? 'U')

function handleLogout() {
  userStore.logout()
  router.push('/home')
}
</script>

<style scoped>
.header-inner {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  padding: 0 16px;
  gap: 12px;
}

.collapse-btn {
  font-size: 18px;
  flex-shrink: 0;
}

.page-title {
  font-size: 15px;
  font-weight: 500;
  color: #303133;
}

.header-right {
  margin-left: auto;
  cursor: pointer;
}

.user-avatar {
  background-color: #409eff;
  color: #fff;
  font-size: 13px;
}
</style>
