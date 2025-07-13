import { ref, computed } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useAuth } from './useAuth'
import { globalErrorHandler } from './useErrorHandler'

// Progress data structure for JSON modules
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

export function useJsonModuleProgress() {
  const { user } = useAuth()

  // Load all progress data from Supabase for JSON modules
  async function loadProgress(categorySlug, courseSlug) {
    if (!user.value) {
      console.warn('Cannot load progress: user not authenticated')
      return
    }

    progress.value.isLoading = true
    
    try {
      const userId = user.value.id
      
      console.log('[JSON Module Progress] Loading progress for user:', userId)
      console.log('[JSON Module Progress] Category:', categorySlug, 'Course:', courseSlug)

      // Load module progress
      const { data: moduleData, error: moduleError } = await supabase
        .from('module_progress_json')
        .select('*')
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)

      if (moduleError) {
        console.error('[JSON Module Progress] Module progress error:', moduleError)
        throw moduleError
      }
      
      console.log('[JSON Module Progress] Loaded module data:', moduleData)

      // Load section progress
      const { data: sectionData, error: sectionError } = await supabase
        .from('section_progress_json')
        .select('*')
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)

      if (sectionError) throw sectionError

      // Load quiz attempts
      const { data: quizData, error: quizError } = await supabase
        .from('quiz_attempts_json')
        .select('*')
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)
        .order('created_at', { ascending: false })

      if (quizError) throw quizError

      // Process module progress data
      const startedModules = []
      const completedModules = []
      const moduleProgress = {}

      moduleData.forEach(module => {
        startedModules.push(module.module_slug)
        if (module.status === 'completed') {
          completedModules.push(module.module_slug)
        }
        
        // Find highest section for this module
        const moduleSections = sectionData.filter(s => s.module_slug === module.module_slug)
        const highestSection = moduleSections.length > 0 
          ? Math.max(...moduleSections.map(s => s.section_index))
          : module.current_section || 0
        
        moduleProgress[module.module_slug] = {
          section: highestSection,
          lastUpdated: module.updated_at
        }
      })

      // Process quiz data - get latest attempt per module
      const completedQuizzes = {}
      const latestQuizzes = {}
      
      quizData.forEach(quiz => {
        if (!latestQuizzes[quiz.module_slug] || 
            new Date(quiz.created_at) > new Date(latestQuizzes[quiz.module_slug].created_at)) {
          latestQuizzes[quiz.module_slug] = quiz
        }
      })

      Object.values(latestQuizzes).forEach(quiz => {
        completedQuizzes[quiz.module_slug] = {
          score: quiz.score,
          total: quiz.total_questions,
          percentage: Math.round((quiz.score / quiz.total_questions) * 100),
          passed: quiz.passed,
          completedAt: quiz.created_at
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
          ).updated_at)?.module_slug || null,
        isLoaded: true
      }

    } catch (error) {
      console.error('Failed to load progress from Supabase:', error)
    } finally {
      progress.value.isLoading = false
    }
  }

  // Module management
  async function markModuleStarted(categorySlug, courseSlug, moduleSlug) {
    console.log('[JSON Module Progress] Marking module as started:', moduleSlug)
    
    if (!user.value) {
      console.error('[JSON Module Progress] No user found when marking module as started')
      return
    }
    
    const userId = user.value.id
    
    try {
      // Check if progress exists
      const { data: existing } = await supabase
        .from('module_progress_json')
        .select('id, status')
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)
        .eq('module_slug', moduleSlug)
        .single()

      if (existing) {
        // Update existing progress
        if (existing.status === 'not_started') {
          const { error } = await supabase
            .from('module_progress_json')
            .update({
              status: 'started',
              started_at: new Date().toISOString(),
              last_accessed_at: new Date().toISOString()
            })
            .eq('id', existing.id)

          if (error) throw error
        }
      } else {
        // Insert new progress
        const { error } = await supabase
          .from('module_progress_json')
          .insert({
            user_id: userId,
            category_slug: categorySlug,
            course_slug: courseSlug,
            module_slug: moduleSlug,
            status: 'started',
            started_at: new Date().toISOString()
          })

        if (error) throw error
      }

      console.log('[JSON Module Progress] Module marked as started successfully')

      // Update local state
      if (!progress.value.startedModules.includes(moduleSlug)) {
        progress.value.startedModules.push(moduleSlug)
      }
      progress.value.currentModule = moduleSlug
      progress.value.lastAccessed = new Date().toISOString()

    } catch (error) {
      console.error('[JSON Module Progress] Failed to mark module as started:', error)
      globalErrorHandler.addError(error, 'Failed to save module progress')
    }
  }

  async function markModuleCompleted(categorySlug, courseSlug, moduleSlug) {
    console.log('[JSON Module Progress] Marking module as completed:', moduleSlug)
    
    if (!user.value) {
      console.error('[JSON Module Progress] No user found when marking module as completed')
      return
    }
    
    const userId = user.value.id
    
    try {
      // Update module progress to completed
      const { error } = await supabase
        .from('module_progress_json')
        .update({
          status: 'completed',
          completed_at: new Date().toISOString(),
          last_accessed_at: new Date().toISOString()
        })
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)
        .eq('module_slug', moduleSlug)

      if (error) {
        console.error('[JSON Module Progress] Module completion error:', error)
        throw error
      }

      console.log('[JSON Module Progress] Module marked as completed successfully')

      // Update local state
      if (!progress.value.completedModules.includes(moduleSlug)) {
        progress.value.completedModules.push(moduleSlug)
      }

    } catch (error) {
      console.error('[JSON Module Progress] Failed to mark module as completed:', error)
      globalErrorHandler.addError(error, 'Failed to save module completion')
    }
  }

  // Section progress management
  async function updateModuleProgress(categorySlug, courseSlug, moduleSlug, sectionIndex) {
    if (!user.value) return

    const userId = user.value.id

    try {
      // Update current section in module progress
      const { error: moduleError } = await supabase
        .from('module_progress_json')
        .update({
          current_section: sectionIndex,
          status: 'in_progress',
          last_accessed_at: new Date().toISOString()
        })
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)
        .eq('module_slug', moduleSlug)

      if (moduleError) throw moduleError

      // Track section progress
      const { error: sectionError } = await supabase
        .from('section_progress_json')
        .upsert({
          user_id: userId,
          category_slug: categorySlug,
          course_slug: courseSlug,
          module_slug: moduleSlug,
          section_index: sectionIndex,
          completed: true,
          completed_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,category_slug,course_slug,module_slug,section_index'
        })

      if (sectionError) throw sectionError

      // Update local state
      if (!progress.value.moduleProgress[moduleSlug]) {
        progress.value.moduleProgress[moduleSlug] = {}
      }
      progress.value.moduleProgress[moduleSlug].section = sectionIndex

    } catch (error) {
      console.error('[JSON Module Progress] Failed to update section progress:', error)
      globalErrorHandler.addError(error, 'Failed to save section progress')
    }
  }

  // Quiz management
  async function saveQuizScore(categorySlug, courseSlug, moduleSlug, score, total, timeTaken = null) {
    console.log('[saveQuizScore] Called with:', { categorySlug, courseSlug, moduleSlug, score, total })
    
    if (!user.value) return null

    const userId = user.value.id
    const passed = (score / total) >= 0.7
    console.log('[saveQuizScore] Quiz passed:', passed, 'Score percentage:', (score / total) * 100)

    try {
      // Get attempt number
      const { data: previousAttempts } = await supabase
        .from('quiz_attempts_json')
        .select('attempt_number')
        .eq('user_id', userId)
        .eq('category_slug', categorySlug)
        .eq('course_slug', courseSlug)
        .eq('module_slug', moduleSlug)
        .order('attempt_number', { ascending: false })
        .limit(1)

      const attemptNumber = previousAttempts?.[0]?.attempt_number ? 
        previousAttempts[0].attempt_number + 1 : 1

      // Save quiz attempt
      const { data, error } = await supabase
        .from('quiz_attempts_json')
        .insert({
          user_id: userId,
          category_slug: categorySlug,
          course_slug: courseSlug,
          module_slug: moduleSlug,
          score,
          total_questions: total,
          passed,
          time_taken: timeTaken,
          attempt_number: attemptNumber
        })
        .select()
        .single()

      if (error) throw error

      // Update local state
      progress.value.completedQuizzes[moduleSlug] = {
        score,
        total,
        percentage: Math.round((score / total) * 100),
        passed,
        completedAt: new Date().toISOString()
      }

      // Mark module as completed if passed
      if (passed) {
        await markModuleCompleted(categorySlug, courseSlug, moduleSlug)
      }

      return data.id

    } catch (error) {
      console.error('[JSON Module Progress] Failed to save quiz score:', error)
      globalErrorHandler.addError(error, 'Failed to save quiz score')
      return null
    }
  }

  // Getters
  function getModuleProgress(moduleSlug) {
    return progress.value.moduleProgress[moduleSlug] || { section: 0 }
  }

  function isModuleStarted(moduleSlug) {
    return progress.value.startedModules.includes(moduleSlug)
  }

  function isModuleCompleted(moduleSlug) {
    return progress.value.completedModules.includes(moduleSlug)
  }

  function getQuizScore(moduleSlug) {
    return progress.value.completedQuizzes[moduleSlug] || null
  }

  // Computed values
  const totalCompleted = computed(() => progress.value.completedModules.length)
  const totalStarted = computed(() => progress.value.startedModules.length)

  return {
    // State
    progress,
    totalCompleted,
    totalStarted,

    // Methods
    loadProgress,
    markModuleStarted,
    markModuleCompleted,
    updateModuleProgress,
    saveQuizScore,

    // Getters
    getModuleProgress,
    isModuleStarted,
    isModuleCompleted,
    getQuizScore
  }
}