import { ref } from 'vue'

// Shared state
const modules = ref([])
const currentModule = ref(null)
const isLoading = ref(false)
const error = ref(null)

export function useModules() {
  // Load modules from JSON based on category/course path
  async function loadModules(coursePath) {
    isLoading.value = true
    error.value = null
    modules.value = []

    try {
      const response = await fetch(
        import.meta.env.BASE_URL + `data/${coursePath}/modules.json`
      )
      if (!response.ok) {
        throw new Error('Failed to load modules')
      }
      const data = await response.json()
      modules.value = data.modules || []
    } catch (err) {
      console.error('Failed to load modules:', err)
      error.value = 'Failed to load modules'
      modules.value = []
    } finally {
      isLoading.value = false
    }
  }

  // Load a single module by slug within a course
  async function loadModule(coursePath, moduleSlug) {
    isLoading.value = true
    error.value = null
    currentModule.value = null

    try {
      // First load all modules if not already loaded
      if (modules.value.length === 0) {
        await loadModules(coursePath)
      }

      // Find the module by slug
      const module = modules.value.find(m => m.slug === moduleSlug)
      if (!module) {
        throw new Error('Module not found')
      }

      // Load the module content
      const contentResponse = await fetch(
        import.meta.env.BASE_URL + `data/${coursePath}/${moduleSlug}/content.json`
      )
      if (!contentResponse.ok) {
        throw new Error('Failed to load module content')
      }
      const contentData = await contentResponse.json()
      
      // Merge module metadata with content
      const fullModule = {
        ...module,
        ...contentData.module,
        sections: contentData.module.sections || []
      }

      currentModule.value = fullModule
      return fullModule
    } catch (err) {
      console.error('Failed to load module:', err)
      error.value = 'Failed to load module'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Get module by slug from loaded modules
  function getModuleBySlug(moduleSlug) {
    return modules.value.find(m => m.slug === moduleSlug)
  }

  // Reset state
  function resetModules() {
    modules.value = []
    currentModule.value = null
    error.value = null
  }

  return {
    // State
    modules,
    currentModule,
    isLoading,
    error,

    // Methods
    loadModules,
    loadModule,
    getModuleBySlug,
    resetModules
  }
}