import { ref, computed } from 'vue'

// Progress data structure
const progress = ref({
  startedModules: [],
  completedModules: [],
  completedQuizzes: {},
  moduleProgress: {},
  lastAccessed: null,
  currentModule: null
})

// Load progress from localStorage
function loadProgress() {
  const saved = localStorage.getItem('claudeLearnProgress')
  if (saved) {
    try {
      const parsed = JSON.parse(saved)
      progress.value = { ...progress.value, ...parsed }
    } catch (e) {
      console.error('Failed to parse saved progress:', e)
    }
  }
}

// Save progress to localStorage
function saveProgress() {
  localStorage.setItem('claudeLearnProgress', JSON.stringify(progress.value))
}

// Initialize on first load
loadProgress()

export function useProgress() {
  // Module management
  function markModuleStarted(moduleId) {
    if (!progress.value.startedModules.includes(moduleId)) {
      progress.value.startedModules.push(moduleId)
    }
    progress.value.currentModule = moduleId
    progress.value.lastAccessed = new Date().toISOString()
    saveProgress()
  }

  function markModuleCompleted(moduleId) {
    if (!progress.value.completedModules.includes(moduleId)) {
      progress.value.completedModules.push(moduleId)
    }
    saveProgress()
  }

  function getModuleProgress(moduleId) {
    return progress.value.moduleProgress[moduleId] || { section: 0 }
  }

  function updateModuleProgress(moduleId, section) {
    if (!progress.value.moduleProgress[moduleId]) {
      progress.value.moduleProgress[moduleId] = {}
    }
    progress.value.moduleProgress[moduleId].section = section
    progress.value.moduleProgress[moduleId].lastUpdated = new Date().toISOString()
    saveProgress()
  }

  // Quiz management
  function saveQuizScore(moduleId, score, total) {
    if (!progress.value.completedQuizzes) {
      progress.value.completedQuizzes = {}
    }
    
    progress.value.completedQuizzes[moduleId] = {
      score,
      total,
      percentage: Math.round((score / total) * 100),
      completedAt: new Date().toISOString()
    }
    
    // Mark module as completed if score is 60% or higher
    if ((score / total) >= 0.6) {
      markModuleCompleted(moduleId)
    }
    
    saveProgress()
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

  // Export/Import functionality
  function exportProgress() {
    return JSON.stringify(progress.value, null, 2)
  }

  function importProgress(data) {
    try {
      const parsed = JSON.parse(data)
      progress.value = { ...progress.value, ...parsed }
      saveProgress()
      return true
    } catch (e) {
      console.error('Failed to import progress:', e)
      return false
    }
  }

  // Reset progress
  function resetProgress() {
    progress.value = {
      startedModules: [],
      completedModules: [],
      completedQuizzes: {},
      moduleProgress: {},
      lastAccessed: null,
      currentModule: null
    }
    saveProgress()
  }

  return {
    // State
    progress,
    overallProgress,
    
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
    
    // Utility methods
    exportProgress,
    importProgress,
    resetProgress,
    loadProgress,
    saveProgress
  }
}