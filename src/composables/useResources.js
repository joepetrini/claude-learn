import { ref, computed, watch } from 'vue'
import { resourceService } from '../services/resourceService'
import { useAuth } from './useAuth'

/**
 * Composable for managing course resources, favorites, and analytics
 */
export function useResources(courseId) {
  const { user } = useAuth()
  
  // Reactive state
  const resources = ref([])
  const resourceContent = ref({})
  const favorites = ref([])
  const recentlyViewed = ref([])
  const popularResources = ref([])
  const loading = ref(false)
  const error = ref(null)

  // Computed properties
  const favoriteResources = computed(() => {
    return resources.value.filter(resource => resource.isFavorited)
  })

  const resourcesByType = computed(() => {
    const grouped = {}
    resources.value.forEach(resource => {
      if (!grouped[resource.type]) {
        grouped[resource.type] = []
      }
      grouped[resource.type].push(resource)
    })
    return grouped
  })

  const featuredResources = computed(() => {
    return resources.value.filter(resource => resource.featured)
  })

  /**
   * Load resources for the current course
   */
  const loadResources = async () => {
    if (!courseId) return
    
    loading.value = true
    error.value = null
    
    try {
      const data = await resourceService.getCourseResources(courseId)
      resources.value = data.resources || []
    } catch (err) {
      error.value = err.message
      console.error('Failed to load resources:', err)
    } finally {
      loading.value = false
    }
  }

  /**
   * Load content for a specific resource
   */
  const loadResourceContent = async (resourcePath, resourceId) => {
    if (!courseId || !resourcePath) return null
    
    // Return cached content if available
    if (resourceContent.value[resourceId]) {
      return resourceContent.value[resourceId]
    }
    
    loading.value = true
    error.value = null
    
    try {
      const content = await resourceService.getResourceContent(courseId, resourcePath)
      resourceContent.value[resourceId] = content
      
      // Update view count in local state
      const resource = resources.value.find(r => r.id === resourceId)
      if (resource) {
        resource.viewCount = (resource.viewCount || 0) + 1
        resource.lastViewed = new Date().toISOString()
      }
      
      return content
    } catch (err) {
      error.value = err.message
      console.error('Failed to load resource content:', err)
      return null
    } finally {
      loading.value = false
    }
  }

  /**
   * Toggle favorite status for a resource
   */
  const toggleFavorite = async (resourceId) => {
    if (!user.value || !courseId) return false
    
    const resource = resources.value.find(r => r.id === resourceId)
    if (!resource) return false
    
    try {
      const newFavoriteStatus = await resourceService.toggleFavorite(
        courseId, 
        resourceId
      )
      
      // Update local state
      resource.isFavorited = newFavoriteStatus
      
      // Update favorites list
      if (newFavoriteStatus) {
        if (!favorites.value.includes(resourceId)) {
          favorites.value.push(resourceId)
        }
      } else {
        const index = favorites.value.indexOf(resourceId)
        if (index > -1) {
          favorites.value.splice(index, 1)
        }
      }
      
      // Dispatch event to notify other components
      window.dispatchEvent(new CustomEvent('favorite-changed'))
      
      return true
    } catch (err) {
      error.value = err.message
      console.error('Failed to toggle favorite:', err)
      return false
    }
  }

  /**
   * Load user's recently viewed resources
   */
  const loadRecentlyViewed = async (limit = 10) => {
    if (!user.value) return
    
    try {
      const recent = await resourceService.getRecentlyViewed(user.value.id, limit)
      recentlyViewed.value = recent
    } catch (err) {
      console.error('Failed to load recently viewed:', err)
    }
  }

  /**
   * Load popular resources across all courses
   */
  const loadPopularResources = async (limit = 10) => {
    try {
      const popular = await resourceService.getPopularResources(limit)
      popularResources.value = popular
    } catch (err) {
      console.error('Failed to load popular resources:', err)
    }
  }

  /**
   * Search resources
   */
  const searchResources = async (query, type = null) => {
    if (!query.trim()) return []
    
    try {
      return await resourceService.searchResources(query, courseId, type)
    } catch (err) {
      console.error('Failed to search resources:', err)
      return []
    }
  }

  /**
   * Get resource by ID
   */
  const getResourceById = (resourceId) => {
    return resources.value.find(r => r.id === resourceId)
  }

  /**
   * Get resources by type
   */
  const getResourcesByType = (type) => {
    return resources.value.filter(r => r.type === type)
  }

  /**
   * Check if resource is favorited
   */
  const isResourceFavorited = (resourceId) => {
    const resource = resources.value.find(r => r.id === resourceId)
    return resource?.isFavorited || false
  }

  /**
   * Get resource analytics
   */
  const getResourceAnalytics = async () => {
    if (!courseId) return {}
    
    try {
      return await resourceService.getResourceAnalytics(courseId)
    } catch (err) {
      console.error('Failed to get resource analytics:', err)
      return {}
    }
  }

  /**
   * Track resource view manually (for special cases)
   */
  const trackView = async (resourceId) => {
    if (!user.value || !courseId) return false
    
    try {
      return await resourceService.trackResourceView(user.value.id, courseId, resourceId)
    } catch (err) {
      console.error('Failed to track view:', err)
      return false
    }
  }

  /**
   * Refresh all data
   */
  const refresh = async () => {
    await Promise.all([
      loadResources(),
      user.value ? loadRecentlyViewed() : Promise.resolve(),
      loadPopularResources()
    ])
  }

  // Watch for auth changes and reload data
  watch(
    () => user.value,
    async (newUser) => {
      if (newUser) {
        await loadRecentlyViewed()
      } else {
        recentlyViewed.value = []
        favorites.value = []
        // Clear favorite status from resources
        resources.value.forEach(resource => {
          resource.isFavorited = false
        })
      }
    }
  )

  // Auto-load resources when courseId changes
  watch(
    () => courseId,
    async () => {
      if (courseId) {
        await loadResources()
      }
    },
    { immediate: true }
  )

  return {
    // State
    resources,
    resourceContent,
    favorites,
    recentlyViewed,
    popularResources,
    loading,
    error,
    
    // Computed
    favoriteResources,
    resourcesByType,
    featuredResources,
    
    // Methods
    loadResources,
    loadResourceContent,
    toggleFavorite,
    loadRecentlyViewed,
    loadPopularResources,
    searchResources,
    getResourceById,
    getResourcesByType,
    isResourceFavorited,
    getResourceAnalytics,
    trackView,
    refresh
  }
}