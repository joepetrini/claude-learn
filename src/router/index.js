import { createRouter, createWebHashHistory } from 'vue-router'
import Home from '../views/Home.vue'
import { supabase } from '../lib/supabaseClient'

const routes = [
  {
    path: '/',
    name: 'home',
    component: Home,
    meta: { requiresAuth: true }
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/dashboard',
    name: 'dashboard',
    component: () => import('../views/Dashboard.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('../views/Profile.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/module/:id',
    name: 'module',
    component: () => import('../views/Module.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/quiz/:id',
    name: 'quiz',
    component: () => import('../views/Quiz.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/results',
    name: 'results',
    component: () => import('../views/Results.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/cheatsheet',
    name: 'cheatsheet',
    component: () => import('../views/CheatSheet.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin',
    name: 'admin',
    component: () => import('../views/admin/AdminDashboard.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/users',
    name: 'admin-users',
    component: () => import('../views/admin/UsersList.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/users/:id',
    name: 'admin-user-progress',
    component: () => import('../views/admin/UserProgress.vue'),
    meta: { requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'catch-all',
    component: () => import('../views/Home.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes
})

router.beforeEach(async (to, from, next) => {
  // Only allow access without auth if explicitly set to false (login page)
  if (to.meta.requiresAuth === false) {
    next()
    return
  }
  
  // All other routes require authentication
  const { data } = await supabase.auth.getSession()
  
  if (!data.session) {
    next({ name: 'login', query: { redirect: to.fullPath } })
    return
  }

  // Check admin routes
  if (to.meta.requiresAdmin) {
    try {
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', data.session.user.id)
        .single()

      if (error || !profile?.is_admin) {
        console.warn('Access denied: user is not admin')
        next({ name: 'home' })
        return
      }
    } catch (error) {
      console.error('Error checking admin status:', error)
      next({ name: 'home' })
      return
    }
  }

  next()
})

export default router