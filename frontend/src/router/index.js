import { createRouter, createWebHistory } from 'vue-router'
import AppLayout from '@/components/layout/AppLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: AppLayout,
      redirect: '/home',
      children: [
        {
          path: 'home',
          name: 'Home',
          component: () => import('@/views/Home/index.vue'),
          meta: { title: '首页' },
        },
        {
          path: 'graph',
          name: 'Graph',
          component: () => import('@/views/Graph/index.vue'),
          meta: { title: '知识图谱' },
        },
        {
          path: 'knowledge',
          component: () => import('@/views/LearningPath/index.vue'),
          redirect: '/knowledge/welcome',
          children: [
            {
              path: 'welcome',
              name: 'KnowledgeWelcome',
              component: () => import('@/views/KnowledgeDetail/index.vue'),
              meta: { title: '学习目录' },
            },
            {
              path: ':module',
              name: 'KnowledgeModule',
              component: () => import('@/views/KnowledgeDetail/index.vue'),
              meta: { title: '知识模块' },
            },
            {
              path: ':module/:id',
              name: 'KnowledgeDetail',
              component: () => import('@/views/KnowledgeDetail/index.vue'),
              meta: { title: '知识点详情' },
            },
          ],
        },
        {
          path: 'playground',
          name: 'CodePlayground',
          component: () => import('@/views/CodePlayground/index.vue'),
          meta: { title: '代码在线运行' },
        },
        {
          path: 'exercise',
          name: 'Exercise',
          component: () => import('@/views/Exercise/index.vue'),
          meta: { title: '习题模块' },
        },
        {
          path: 'exercise/:id',
          name: 'ExerciseDetail',
          component: () => import('@/views/Exercise/ExerciseDetail.vue'),
          meta: { title: '习题详情' },
        },
        {
          path: 'statistics',
          name: 'Statistics',
          component: () => import('@/views/Statistics/index.vue'),
          meta: { title: '学习统计' },
        },
        {
          path: 'ai-chat',
          name: 'AIChat',
          component: () => import('@/views/AIChat/index.vue'),
          meta: { title: 'AI 辅助' },
        },
        {
          path: 'video',
          name: 'VideoPlayer',
          component: () => import('@/views/VideoPlayer/index.vue'),
          meta: { title: '视频讲解' },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/home',
    },
  ],
})

router.beforeEach((to) => {
  if (to.meta?.title) {
    document.title = `${to.meta.title} — 数据结构智慧学习平台`
  }
})

export default router
