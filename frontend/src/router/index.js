import { createRouter, createWebHistory } from 'vue-router'
import ExerciseDetail from '../views/Exercise/ExerciseDetail.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/exercise/1'
    },
    {
      path: '/exercise/:id',
      name: 'exercise',
      component: ExerciseDetail,
      props: true
    },
  ],
})

export default router
