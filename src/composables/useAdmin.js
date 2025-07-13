import { ref, computed } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useAuth } from './useAuth'

const adminData = ref({
  isAdmin: false,
  isLoading: true,
  users: [],
  userProgress: {},
  lastUpdated: null
})

export function useAdmin() {
  const { user } = useAuth()

  // Check if current user is admin
  async function checkAdminStatus() {
    if (!user.value) {
      adminData.value.isAdmin = false
      adminData.value.isLoading = false
      return false
    }

    try {
      console.log('[Admin] Checking admin status for user:', user.value.id)
      
      const { data: profile, error } = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', user.value.id)
        .single()

      if (error) {
        console.error('[Admin] Error checking admin status:', error)
        adminData.value.isAdmin = false
      } else {
        adminData.value.isAdmin = profile?.is_admin || false
        console.log('[Admin] Admin status:', adminData.value.isAdmin)
      }

    } catch (error) {
      console.error('[Admin] Failed to check admin status:', error)
      adminData.value.isAdmin = false
    } finally {
      adminData.value.isLoading = false
    }

    return adminData.value.isAdmin
  }

  // Load all users with their progress
  async function loadAllUsers() {
    if (!adminData.value.isAdmin) {
      console.warn('[Admin] Access denied: user is not admin')
      return []
    }

    try {
      console.log('[Admin] Loading all users and progress...')
      
      const { data: users, error } = await supabase
        .from('profiles')
        .select(`
          id,
          email,
          full_name,
          avatar_url,
          is_admin,
          created_at,
          module_progress_json (
            module_slug,
            status,
            started_at,
            completed_at
          ),
          quiz_attempts_json (
            module_slug,
            score,
            total_questions,
            passed,
            created_at
          )
        `)
        .order('created_at', { ascending: false })

      if (error) {
        console.error('[Admin] Error loading users:', error)
        return []
      }

      console.log('[Admin] Loaded users:', users?.length || 0)
      adminData.value.users = users || []
      adminData.value.lastUpdated = new Date().toISOString()

      return users || []

    } catch (error) {
      console.error('[Admin] Failed to load users:', error)
      return []
    }
  }

  // Get detailed progress for a specific user
  async function getUserProgress(userId) {
    if (!adminData.value.isAdmin) {
      console.warn('[Admin] Access denied: user is not admin')
      return null
    }

    try {
      console.log('[Admin] Loading progress for user:', userId)

      const { data: user, error: userError } = await supabase
        .from('profiles')
        .select(`
          id,
          email,
          full_name,
          avatar_url,
          created_at,
          module_progress (
            module_id,
            status,
            started_at,
            completed_at,
            created_at,
            updated_at
          ),
          section_progress (
            module_id,
            section_index,
            completed_at
          ),
          quiz_attempts (
            id,
            module_id,
            score,
            total_questions,
            passed,
            completed_at,
            quiz_answers (
              question_index,
              selected_answer,
              is_correct
            )
          )
        `)
        .eq('id', userId)
        .single()

      if (userError) {
        console.error('[Admin] Error loading user progress:', userError)
        return null
      }

      console.log('[Admin] Loaded detailed progress for user')
      return user

    } catch (error) {
      console.error('[Admin] Failed to load user progress:', error)
      return null
    }
  }

  // Get analytics summary
  const analytics = computed(() => {
    if (!adminData.value.users.length) {
      return {
        totalUsers: 0,
        activeUsers: 0,
        completedModules: 0,
        averageProgress: 0,
        quizzesTaken: 0,
        passRate: 0
      }
    }

    const users = adminData.value.users
    const totalUsers = users.length
    const activeUsers = users.filter(u => u.module_progress_json?.length > 0).length
    
    let totalModulesCompleted = 0
    let totalModulesStarted = 0
    let totalQuizzes = 0
    let passedQuizzes = 0

    users.forEach(user => {
      if (user.module_progress_json) {
        totalModulesStarted += user.module_progress_json.length
        totalModulesCompleted += user.module_progress_json.filter(m => m.status === 'completed').length
      }
      
      if (user.quiz_attempts_json) {
        totalQuizzes += user.quiz_attempts_json.length
        passedQuizzes += user.quiz_attempts_json.filter(q => q.passed).length
      }
    })

    return {
      totalUsers,
      activeUsers,
      completedModules: totalModulesCompleted,
      averageProgress: totalModulesStarted > 0 ? Math.round((totalModulesCompleted / totalModulesStarted) * 100) : 0,
      quizzesTaken: totalQuizzes,
      passRate: totalQuizzes > 0 ? Math.round((passedQuizzes / totalQuizzes) * 100) : 0
    }
  })

  // Export user data
  function exportUsersCSV() {
    if (!adminData.value.isAdmin || !adminData.value.users.length) {
      console.warn('[Admin] Cannot export: no data or not admin')
      return
    }

    const headers = ['Email', 'Full Name', 'Created At', 'Modules Started', 'Modules Completed', 'Quizzes Taken', 'Quiz Pass Rate']
    const rows = adminData.value.users.map(user => {
      const modulesStarted = user.module_progress?.length || 0
      const modulesCompleted = user.module_progress?.filter(m => m.status === 'completed').length || 0
      const quizzesTaken = user.quiz_attempts?.length || 0
      const quizzesPassed = user.quiz_attempts?.filter(q => q.passed).length || 0
      const passRate = quizzesTaken > 0 ? Math.round((quizzesPassed / quizzesTaken) * 100) : 0

      return [
        user.email,
        user.full_name || 'N/A',
        new Date(user.created_at).toLocaleDateString(),
        modulesStarted,
        modulesCompleted,
        quizzesTaken,
        `${passRate}%`
      ]
    })

    const csv = [headers, ...rows].map(row => row.join(',')).join('\n')
    
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `claude-learn-users-${new Date().toISOString().split('T')[0]}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)

    console.log('[Admin] Users data exported to CSV')
  }

  // Export progress data as JSON
  function exportProgressJSON() {
    if (!adminData.value.isAdmin || !adminData.value.users.length) {
      console.warn('[Admin] Cannot export: no data or not admin')
      return
    }

    const exportData = {
      exportedAt: new Date().toISOString(),
      totalUsers: adminData.value.users.length,
      users: adminData.value.users
    }

    const json = JSON.stringify(exportData, null, 2)
    
    const blob = new Blob([json], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `claude-learn-progress-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)

    console.log('[Admin] Progress data exported to JSON')
  }

  return {
    // State
    adminData,
    analytics,
    
    // Computed
    isAdmin: computed(() => adminData.value.isAdmin),
    isLoading: computed(() => adminData.value.isLoading),
    users: computed(() => adminData.value.users),
    
    // Methods
    checkAdminStatus,
    loadAllUsers,
    getUserProgress,
    exportUsersCSV,
    exportProgressJSON
  }
}