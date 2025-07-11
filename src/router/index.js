import { createRouter, createWebHashHistory } from 'vue-router'
import Home from '../views/Home.vue'

const routes = [
  {
    path: '/',
    name: 'home',
    component: Home
  },
  {
    path: '/module/:id',
    name: 'module',
    component: () => import('../views/Module.vue')
  },
  {
    path: '/quiz/:id',
    name: 'quiz',
    component: () => import('../views/Quiz.vue')
  },
  {
    path: '/results',
    name: 'results',
    component: () => import('../views/Results.vue')
  }
]

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes
})

export default router