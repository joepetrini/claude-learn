import { ref, computed } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useAuth } from './useAuth'
import { globalErrorHandler } from './useErrorHandler'

// Progress data structure
const progress = ref({
  startedModules: [],
  completedModules: [],
  completedQuizzes: {},
  moduleProgress: {},
  lastAccessed: null,
  currentModule: null,
  isLoading: false,
  isLoaded: false
})

export function useSupabaseProgress() {
  const { user } = useAuth()

  // Test database connectivity
  async function testDatabaseTables() {
    try {
      console.log('[Supabase Progress] Testing database tables...')
      
      // Test each table
      const tables = ['profiles', 'module_progress', 'section_progress', 'quiz_attempts', 'quiz_answers']
      
      for (const table of tables) {
        const { data, error } = await supabase
          .from(table)
          .select('*')
          .limit(1)
        
        if (error) {
          console.error(`[Supabase Progress] Table ${table} error:`, error)
        } else {
          console.log(`[Supabase Progress] Table ${table} exists and accessible`)
        }
      }
    } catch (error) {
      console.error('[Supabase Progress] Database test failed:', error)
    }
  }

  // Ensure user profile exists
  async function ensureUserProfile() {
    if (!user.value) {
      console.warn('[Supabase Progress] No user found when ensuring profile')
      return false
    }

    try {
      const userId = user.value.id
      
      // Check if profile exists
      const { data: existingProfile, error: checkError } = await supabase
        .from('profiles')
        .select('id')
        .eq('id', userId)
        .single()

      if (checkError && checkError.code !== 'PGRST116') {
        // PGRST116 is "not found" - that's expected if profile doesn't exist
        console.error('[Supabase Progress] Error checking profile:', checkError)
        return false
      }

      if (existingProfile) {
        console.log('[Supabase Progress] User profile exists')
        return true
      }

      // Profile doesn't exist, create it
      console.log('[Supabase Progress] Creating user profile...')
      
      const { error: insertError } = await supabase
        .from('profiles')
        .insert({
          id: userId,
          email: user.value.email,
          full_name: user.value.user_metadata?.full_name || user.value.user_metadata?.name || 'User',
          avatar_url: user.value.user_metadata?.avatar_url,
          is_admin: false
        })

      if (insertError) {
        console.error('[Supabase Progress] Failed to create profile:', insertError)
        return false
      }

      console.log('[Supabase Progress] User profile created successfully')
      return true

    } catch (error) {
      console.error('[Supabase Progress] Error ensuring user profile:', error)
      return false
    }
  }

  // Load all progress data from Supabase
  async function loadProgress() {
    if (!user.value) {
      console.warn('Cannot load progress: user not authenticated')
      return
    }

    progress.value.isLoading = true
    
    try {
      // Ensure user profile exists first
      const profileExists = await ensureUserProfile()
      if (!profileExists) {
        console.error('[Supabase Progress] Cannot load progress: profile creation failed')
        progress.value.isLoading = false
        return
      }

      const userId = user.value.id
      
      console.log('[Supabase Progress] Loading progress for user:', userId)

      // Load module progress
      const { data: moduleData, error: moduleError } = await supabase
        .from('module_progress')
        .select('*')
        .eq('user_id', userId)

      if (moduleError) {
        console.error('[Supabase Progress] Module progress error:', moduleError)
        throw moduleError
      }

      // Load section progress
      const { data: sectionData, error: sectionError } = await supabase
        .from('section_progress')
        .select('*')
        .eq('user_id', userId)

      if (sectionError) throw sectionError

      // Load quiz attempts
      const { data: quizData, error: quizError } = await supabase
        .from('quiz_attempts')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })

      if (quizError) throw quizError

      // Process module progress data
      const startedModules = []
      const completedModules = []
      const moduleProgress = {}

      moduleData.forEach(module => {
        startedModules.push(module.module_id)
        if (module.status === 'completed') {
          completedModules.push(module.module_id)
        }
        
        // Find highest section for this module
        const moduleSections = sectionData.filter(s => s.module_id === module.module_id)
        const highestSection = moduleSections.length > 0 
          ? Math.max(...moduleSections.map(s => s.section_index))
          : 0
        
        moduleProgress[module.module_id] = {
          section: highestSection,
          lastUpdated: module.updated_at
        }
      })

      // Process quiz data - get latest attempt per module
      const completedQuizzes = {}
      const latestQuizzes = {}
      
      quizData.forEach(quiz => {
        if (!latestQuizzes[quiz.module_id] || 
            new Date(quiz.created_at) > new Date(latestQuizzes[quiz.module_id].created_at)) {
          latestQuizzes[quiz.module_id] = quiz
        }
      })

      Object.values(latestQuizzes).forEach(quiz => {
        completedQuizzes[quiz.module_id] = {
          score: quiz.score,
          total: quiz.total_questions,
          percentage: Math.round((quiz.score / quiz.total_questions) * 100),
          passed: quiz.passed,
          completedAt: quiz.completed_at
        }
      })

      // Update progress state
      progress.value = {
        ...progress.value,
        startedModules,
        completedModules,
        completedQuizzes,
        moduleProgress,
        lastAccessed: moduleData.length > 0 ? 
          Math.max(...moduleData.map(m => new Date(m.updated_at).getTime())) : null,
        currentModule: moduleData.find(m => m.updated_at === 
          moduleData.reduce((latest, current) => 
            new Date(current.updated_at) > new Date(latest.updated_at) ? current : latest
          ).updated_at)?.module_id || null,
        isLoaded: true
      }

    } catch (error) {
      console.error('Failed to load progress from Supabase:', error)
    } finally {
      progress.value.isLoading = false
    }
  }

  // Module management
  async function markModuleStarted(moduleId) {
    console.log('[Supabase Progress] Marking module as started:', moduleId)
    
    if (!user.value) {
      console.error('[Supabase Progress] No user found when marking module as started')
      return
    }
    
    // Ensure user profile exists first
    const profileExists = await ensureUserProfile()
    if (!profileExists) {
      console.error('[Supabase Progress] Cannot mark module as started: profile creation failed')
      return
    }
    
    const userId = user.value.id
    
    try {
      // Upsert module progress with conflict resolution
      const { error } = await supabase
        .from('module_progress')
        .upsert({
          user_id: userId,
          module_id: moduleId,
          status: 'started',
          started_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,module_id',
          ignoreDuplicates: false
        })

      if (error) {
        console.error('[Supabase Progress] Module start error:', error)
        throw error
      }

      console.log('[Supabase Progress] Module marked as started successfully')

      // Update local state
      if (!progress.value.startedModules.includes(moduleId)) {
        progress.value.startedModules.push(moduleId)
      }
      progress.value.currentModule = moduleId
      progress.value.lastAccessed = new Date().toISOString()

    } catch (error) {
      console.error('[Supabase Progress] Failed to mark module as started:', error)
      globalErrorHandler.addError(error, 'Failed to save module progress')
    }
  }

  async function markModuleCompleted(moduleId) {
    console.log('[Supabase Progress] Marking module as completed:', moduleId)
    
    if (!user.value) {
      console.error('[Supabase Progress] No user found when marking module as completed')
      return
    }
    
    const userId = user.value.id
    
    try {
      // Update module progress to completed
      const { error } = await supabase
        .from('module_progress')
        .upsert({
          user_id: userId,
          module_id: moduleId,
          status: 'completed',
          completed_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,module_id',
          ignoreDuplicates: false
        })

      if (error) {
        console.error('[Supabase Progress] Module completion error:', error)
        throw error
      }

      console.log('[Supabase Progress] Module marked as completed successfully')

      // Update local state
      if (!progress.value.completedModules.includes(moduleId)) {
        progress.value.completedModules.push(moduleId)
      }

    } catch (error) {
      console.error('[Supabase Progress] Failed to mark module as completed:', error)
      globalErrorHandler.addError(error, 'Failed to mark module as completed')
    }
  }

  function getModuleProgress(moduleId) {
    return progress.value.moduleProgress[moduleId] || { section: 0 }
  }

  async function updateModuleProgress(moduleId, sectionIndex) {
    console.log('[Supabase Progress] Updating module progress:', { moduleId, sectionIndex })
    
    if (!user.value) {
      console.error('[Supabase Progress] No user found when updating module progress')
      return
    }
    
    const userId = user.value.id
    
    try {
      // Insert section progress
      const { error } = await supabase
        .from('section_progress')
        .upsert({
          user_id: userId,
          module_id: moduleId,
          section_index: sectionIndex,
          completed_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,module_id,section_index',
          ignoreDuplicates: false
        })

      if (error) {
        console.error('[Supabase Progress] Section progress error:', error)
        throw error
      }

      console.log('[Supabase Progress] Section progress saved successfully')

      // Update module progress timestamp
      const { error: moduleError } = await supabase
        .from('module_progress')
        .upsert({
          user_id: userId,
          module_id: moduleId,
          status: 'started'
        }, {
          onConflict: 'user_id,module_id',
          ignoreDuplicates: false
        })

      if (moduleError) {
        console.error('[Supabase Progress] Module timestamp update error:', moduleError)
      }

      // Update local state
      if (!progress.value.moduleProgress[moduleId]) {
        progress.value.moduleProgress[moduleId] = {}
      }
      progress.value.moduleProgress[moduleId].section = sectionIndex
      progress.value.moduleProgress[moduleId].lastUpdated = new Date().toISOString()

      console.log('[Supabase Progress] Module progress updated successfully')

    } catch (error) {
      console.error('[Supabase Progress] Failed to update module progress:', error)
      console.error('[Supabase Progress] Error details:', error.message, error.details, error.hint)
    }
  }

  // Quiz management
  async function saveQuizScore(moduleId, score, total, answers = []) {
    console.log('[Supabase Progress] Saving quiz score:', { moduleId, score, total, answersLength: answers.length })
    
    if (!user.value) {
      console.error('[Supabase Progress] No user found when saving quiz score')
      return
    }
    
    const userId = user.value.id
    const passed = (score / total) >= 0.6
    
    console.log('[Supabase Progress] Quiz attempt data:', { userId, moduleId, score, total, passed })
    
    try {
      // Insert quiz attempt
      const { data: attemptData, error: attemptError } = await supabase
        .from('quiz_attempts')
        .insert({
          user_id: userId,
          module_id: moduleId,
          score,
          total_questions: total,
          passed,
          completed_at: new Date().toISOString()
        })
        .select()
        .single()

      if (attemptError) {
        console.error('[Supabase Progress] Quiz attempt error:', attemptError)
        throw attemptError
      }

      console.log('[Supabase Progress] Quiz attempt saved:', attemptData)

      // Insert quiz answers if provided
      if (answers.length > 0) {
        const answersData = answers.map((answer, index) => ({
          attempt_id: attemptData.id,
          question_index: index,
          selected_answer: answer.selected,
          is_correct: answer.correct
        }))

        console.log('[Supabase Progress] Saving quiz answers:', answersData)

        const { error: answersError } = await supabase
          .from('quiz_answers')
          .insert(answersData)

        if (answersError) {
          console.error('[Supabase Progress] Quiz answers error:', answersError)
          throw answersError
        }
        
        console.log('[Supabase Progress] Quiz answers saved successfully')
      } else {
        console.log('[Supabase Progress] No answers to save')
      }

      // Update local state
      progress.value.completedQuizzes[moduleId] = {
        score,
        total,
        percentage: Math.round((score / total) * 100),
        passed,
        completedAt: attemptData.completed_at
      }

      console.log('[Supabase Progress] Local state updated:', progress.value.completedQuizzes[moduleId])

      // Mark module as completed if passed
      if (passed) {
        console.log('[Supabase Progress] Quiz passed, marking module as completed')
        await markModuleCompleted(moduleId)
      }

    } catch (error) {
      console.error('[Supabase Progress] Failed to save quiz score:', error)
      console.error('[Supabase Progress] Error details:', error.message, error.details, error.hint)
      globalErrorHandler.addError(error, 'Failed to save quiz results')
    }
  }

  function getQuizScore(moduleId) {
    return progress.value.completedQuizzes[moduleId] || null
  }

  // Module status helpers
  function isModuleStarted(moduleId) {
    return progress.value.startedModules.includes(moduleId)
  }

  function isModuleCompleted(moduleId) {
    return progress.value.completedModules.includes(moduleId)
  }

  // Overall progress calculation
  const overallProgress = computed(() => {
    const totalModules = 12 // This should match the actual number of modules
    const completedCount = progress.value.completedModules.length
    const startedCount = progress.value.startedModules.length
    
    // Calculate weighted progress
    // Completed modules count as 100%, started modules count as 50%
    const completedWeight = completedCount * 1.0
    const startedWeight = (startedCount - completedCount) * 0.5
    
    const percentage = Math.round(((completedWeight + startedWeight) / totalModules) * 100)
    
    return {
      percentage,
      completed: completedCount,
      started: startedCount,
      total: totalModules
    }
  })

  // Admin functions
  async function getAllUsersProgress() {
    if (!user.value) return []
    
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select(`
          id,
          email,
          full_name,
          created_at,
          module_progress (
            module_id,
            status,
            started_at,
            completed_at
          ),
          quiz_attempts (
            module_id,
            score,
            total_questions,
            passed,
            completed_at
          )
        `)

      if (error) throw error
      return data

    } catch (error) {
      console.error('Failed to load all users progress:', error)
      return []
    }
  }

  // Export progress data
  function exportProgress() {
    return JSON.stringify(progress.value, null, 2)
  }

  // Reset local progress (for testing)
  function resetLocalProgress() {
    progress.value = {
      startedModules: [],
      completedModules: [],
      completedQuizzes: {},
      moduleProgress: {},
      lastAccessed: null,
      currentModule: null,
      isLoading: false,
      isLoaded: false
    }
  }

  // Debug helper - expose through window for console access
  if (import.meta.env.DEV) {
    window.supabaseProgressDebug = {
      testTables: testDatabaseTables,
      ensureProfile: ensureUserProfile,
      testQuizSave: async (moduleId = 'test-module', score = 3, total = 5) => {
        const answers = [
          { selected: 0, correct: true },
          { selected: 1, correct: false },
          { selected: 2, correct: true },
          { selected: 0, correct: true },
          { selected: 3, correct: false }
        ]
        console.log('Testing quiz save with:', { moduleId, score, total, answers })
        await saveQuizScore(moduleId, score, total, answers)
      },
      getProgress: () => progress.value,
      loadProgress: loadProgress
    }
  }

  // Get course progress (placeholder for now)
  async function getCourseProgress(courseSlug) {
    // In a full implementation, this would aggregate module progress
    // For now, return null to indicate no progress tracking yet
    return null
  }

  return {
    // State
    progress,
    overallProgress,
    
    // Core methods
    loadProgress,
    testDatabaseTables,
    ensureUserProfile,
    
    // Module methods
    markModuleStarted,
    markModuleCompleted,
    getModuleProgress,
    updateModuleProgress,
    isModuleStarted,
    isModuleCompleted,
    
    // Quiz methods
    saveQuizScore,
    getQuizScore,
    
    // Course methods
    getCourseProgress,
    
    // Admin methods
    getAllUsersProgress,
    
    // Utility methods
    exportProgress,
    resetLocalProgress
  }
}