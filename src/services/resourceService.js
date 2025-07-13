import { supabase } from '../lib/supabaseClient'

/**
 * Service for managing course resources, favorites, and analytics
 */
export class ResourceService {
  /**
   * Fetch resources for a specific course
   * @param {string} courseId - The course identifier (e.g., 'claude-code-training')
   * @returns {Promise<Object>} Resources data with metadata
   */
  async getCourseResources(courseId) {
    try {
      // Fetch resources.json for the course
      const response = await fetch(`${import.meta.env.BASE_URL}data/software-dev/${courseId}/resources.json`)
      if (!response.ok) {
        throw new Error(`Failed to fetch resources: ${response.status}`)
      }
      
      const resourcesData = await response.json()
      
      // If user is authenticated, also fetch favorites and view counts
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        const [favorites, analytics] = await Promise.all([
          this.getUserFavorites(user.id, courseId),
          this.getResourceAnalytics(courseId)
        ])
        
        // Merge favorites and analytics data
        resourcesData.resources = resourcesData.resources.map(resource => ({
          ...resource,
          isFavorited: favorites.includes(resource.id),
          viewCount: analytics[resource.id]?.viewCount || 0,
          lastViewed: analytics[resource.id]?.lastViewed || null
        }))
      }
      
      return resourcesData
    } catch (error) {
      console.error('Error fetching course resources:', error)
      throw error
    }
  }

  /**
   * Fetch a specific resource content
   * @param {string} courseId - The course identifier
   * @param {string} resourcePath - Path to the resource file
   * @returns {Promise<Object>} Resource content
   */
  async getResourceContent(courseId, resourcePath) {
    try {
      const response = await fetch(`${import.meta.env.BASE_URL}data/software-dev/${courseId}/${resourcePath}`)
      if (!response.ok) {
        throw new Error(`Failed to fetch resource content: ${response.status}`)
      }
      
      const content = await response.json()
      
      // Track view if user is authenticated
      const { data: { user } } = await supabase.auth.getUser()
      if (user) {
        // Extract resource ID from path (e.g., 'resources/cheat-sheet.json' -> 'quick-reference')
        const resourceId = this.getResourceIdFromPath(resourcePath)
        if (resourceId) {
          await this.trackResourceView(user.id, courseId, resourceId)
        }
      }
      
      return content
    } catch (error) {
      console.error('Error fetching resource content:', error)
      throw error
    }
  }

  /**
   * Get user's favorite resources for a course
   * @param {string} userId - User ID
   * @param {string} courseId - Course identifier
   * @returns {Promise<string[]>} Array of favorited resource IDs
   */
  async getUserFavorites(userId, courseId) {
    try {
      const { data, error } = await supabase
        .from('user_favorite_resources_simple')
        .select('resource_id')
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .eq('is_favorited', true)
      
      if (error) throw error
      
      return data.map(item => item.resource_id)
    } catch (error) {
      console.error('Error fetching user favorites:', error)
      return []
    }
  }

  /**
   * Toggle favorite status for a resource (simplified interface)
   * @param {string} courseId - Course identifier
   * @param {string} resourceId - Resource ID
   * @returns {Promise<boolean>} New favorite status
   */
  async toggleFavorite(courseId, resourceId) {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('User not authenticated')

      // Check current favorite status
      const { data: existing, error: queryError } = await supabase
        .from('user_favorite_resources_simple')
        .select('is_favorited')
        .eq('user_id', user.id)
        .eq('course_id', courseId)
        .eq('resource_id', resourceId)
        .single()
      
      if (queryError && queryError.code !== 'PGRST116') {
        throw queryError
      }

      const currentlyFavorited = existing?.is_favorited || false
      const newStatus = !currentlyFavorited

      await this.setFavoriteStatus(user.id, courseId, resourceId, newStatus)
      return newStatus
    } catch (error) {
      console.error('Error toggling favorite:', error)
      throw error
    }
  }

  /**
   * Set favorite status for a resource
   * @param {string} userId - User ID
   * @param {string} courseId - Course identifier
   * @param {string} resourceId - Resource ID
   * @param {boolean} isFavorited - New favorite status
   * @returns {Promise<boolean>} Success status
   */
  async setFavoriteStatus(userId, courseId, resourceId, isFavorited) {
    try {
      if (isFavorited) {
        // Add to favorites
        const { error } = await supabase
          .from('user_favorite_resources_simple')
          .insert({
            user_id: userId,
            course_id: courseId,
            resource_id: resourceId,
            is_favorited: true,
            favorited_at: new Date().toISOString()
          })
        
        if (error && error.code !== '23505') { // Ignore duplicate key errors
          throw error
        }
      } else {
        // Remove from favorites
        const { error } = await supabase
          .from('user_favorite_resources_simple')
          .delete()
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .eq('resource_id', resourceId)
        
        if (error) throw error
      }
      
      return true
    } catch (error) {
      console.error('Error toggling favorite:', error)
      throw error
    }
  }

  /**
   * Track a resource view
   * @param {string} userId - User ID
   * @param {string} courseId - Course identifier
   * @param {string} resourceId - Resource ID
   * @returns {Promise<boolean>} Success status
   */
  async trackResourceView(userId, courseId, resourceId) {
    try {
      // First check if view exists
      const { data: existing } = await supabase
        .from('user_resource_views_simple')
        .select('view_count')
        .eq('user_id', userId)
        .eq('course_id', courseId)
        .eq('resource_id', resourceId)
        .single()
      
      if (existing) {
        // Update existing view
        const { error } = await supabase
          .from('user_resource_views_simple')
          .update({
            viewed_at: new Date().toISOString(),
            view_count: existing.view_count + 1
          })
          .eq('user_id', userId)
          .eq('course_id', courseId)
          .eq('resource_id', resourceId)
        
        if (error) throw error
      } else {
        // Insert new view
        const { error } = await supabase
          .from('user_resource_views_simple')
          .insert({
            user_id: userId,
            course_id: courseId,
            resource_id: resourceId,
            viewed_at: new Date().toISOString(),
            view_count: 1
          })
        
        if (error) throw error
      }
      
      return true
    } catch (error) {
      console.error('Error tracking resource view:', error)
      return false
    }
  }

  /**
   * Get resource analytics for a course
   * @param {string} courseId - Course identifier
   * @returns {Promise<Object>} Analytics data by resource ID
   */
  async getResourceAnalytics(courseId) {
    try {
      const { data, error } = await supabase
        .rpc('get_resource_analytics', { 
          course_id_param: courseId 
        })
      
      if (error) throw error
      
      // Convert to object keyed by resource_id
      const analytics = {}
      data.forEach(item => {
        analytics[item.resource_id] = {
          viewCount: item.total_views,
          uniqueViewers: item.unique_viewers,
          lastViewed: item.last_viewed
        }
      })
      
      return analytics
    } catch (error) {
      console.error('Error fetching resource analytics:', error)
      return {}
    }
  }

  /**
   * Get recent resources for current user across all courses  
   * @param {number} limit - Number of recent items to return
   * @returns {Promise<Array>} Recent resources with metadata
   */
  async getRecentResources(limit = 10) {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return []

      const { data, error } = await supabase
        .from('user_resource_views_simple')
        .select('course_id, resource_id, viewed_at, view_count')
        .eq('user_id', user.id)
        .order('viewed_at', { ascending: false })
        .limit(limit)

      if (error) throw error

      // For each recent view, get the resource metadata from JSON files
      const recentResources = []
      const courseResources = new Map()

      for (const view of data) {
        // Get course resources if not cached
        if (!courseResources.has(view.course_id)) {
          try {
            const courseData = await this.getCourseResourcesRaw(view.course_id)
            courseResources.set(view.course_id, courseData)
          } catch (error) {
            console.warn(`Could not load resources for course: ${view.course_id}`)
            continue
          }
        }

        const courseData = courseResources.get(view.course_id)
        const resource = courseData?.resources?.find(r => r.id === view.resource_id)
        
        if (resource) {
          recentResources.push({
            id: resource.id,
            resourceId: resource.id, // For compatibility
            courseId: view.course_id,
            title: resource.title,
            description: resource.description,
            icon: resource.icon,
            type: resource.type,
            viewedAt: view.viewed_at,
            viewCount: view.view_count
          })
        }
      }

      return recentResources
    } catch (error) {
      console.error('Error fetching recent resources:', error)
      return []
    }
  }

  /**
   * Get all favorite resources for the current user
   * @returns {Promise<Array>} Favorite resources with metadata
   */
  async getFavoriteResources() {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return []

      const { data, error } = await supabase
        .from('user_favorite_resources_simple')
        .select('course_id, resource_id, favorited_at')
        .eq('user_id', user.id)
        .eq('is_favorited', true)
        .order('favorited_at', { ascending: false })

      if (error) throw error

      // For each favorite, we need to get the resource metadata from the JSON files
      const favorites = []
      const courseResources = new Map()

      for (const fav of data) {
        // Get course resources if not cached
        if (!courseResources.has(fav.course_id)) {
          try {
            const courseData = await this.getCourseResourcesRaw(fav.course_id)
            courseResources.set(fav.course_id, courseData)
          } catch (error) {
            console.warn(`Could not load resources for course: ${fav.course_id}`)
            continue
          }
        }

        const courseData = courseResources.get(fav.course_id)
        const resource = courseData?.resources?.find(r => r.id === fav.resource_id)
        
        if (resource) {
          favorites.push({
            id: resource.id,
            courseId: fav.course_id,
            title: resource.title,
            description: resource.description,
            icon: resource.icon,
            type: resource.type,
            favoritedAt: fav.favorited_at
          })
        }
      }

      return favorites
    } catch (error) {
      console.error('Error fetching favorite resources:', error)
      return []
    }
  }

  /**
   * Get user's recently viewed resources
   * @param {string} userId - User ID
   * @param {number} limit - Number of recent items to return
   * @returns {Promise<Array>} Recent resources with metadata
   */
  async getRecentlyViewed(userId, limit = 10) {
    try {
      const { data, error } = await supabase
        .from('user_resource_views_simple')
        .select('course_id, resource_id, viewed_at, view_count')
        .eq('user_id', userId)
        .order('viewed_at', { ascending: false })
        .limit(limit)
      
      if (error) throw error
      
      // For now, return the data as-is
      // In a full implementation, we'd join with resource metadata
      return data.map(item => ({
        courseId: item.course_id,
        resourceId: item.resource_id,
        viewedAt: item.viewed_at,
        viewCount: item.view_count
      }))
    } catch (error) {
      console.error('Error fetching recently viewed:', error)
      return []
    }
  }

  /**
   * Get popular resources across all courses
   * @param {number} limit - Number of popular items to return
   * @returns {Promise<Array>} Popular resources with view counts
   */
  async getPopularResources(limit = 10) {
    try {
      const { data, error } = await supabase
        .rpc('get_popular_resources', { 
          limit_param: limit 
        })
      
      if (error) throw error
      
      return data.map(item => ({
        courseId: item.course_id,
        resourceId: item.resource_id,
        type: item.type,
        title: item.title,
        description: item.description,
        icon: item.icon,
        totalViews: item.total_views,
        uniqueViewers: item.unique_viewers
      }))
    } catch (error) {
      console.error('Error fetching popular resources:', error)
      return []
    }
  }

  /**
   * Search resources across courses
   * @param {string} query - Search query
   * @param {string} courseId - Optional course filter
   * @param {string} type - Optional resource type filter
   * @returns {Promise<Array>} Matching resources
   */
  async searchResources(query, courseId = null, type = null) {
    try {
      const { data, error } = await supabase
        .rpc('search_resources', {
          search_query: query,
          course_filter: courseId,
          type_filter: type
        })
      
      if (error) throw error
      
      return data
    } catch (error) {
      console.error('Error searching resources:', error)
      return []
    }
  }

  /**
   * Ensure a course_resources entry exists for tracking
   * @private
   */
  async ensureCourseResourceExists(courseId, resourceId) {
    try {
      // Check if entry exists
      const { data: existing, error: selectError } = await supabase
        .from('course_resources')
        .select('id')
        .eq('course_id', courseId)
        .eq('resource_id', resourceId)
        .single()
      
      if (selectError && selectError.code !== 'PGRST116') {
        throw selectError
      }
      
      // If doesn't exist, create it
      if (!existing) {
        // Get resource metadata from resources.json
        const resourcesData = await this.getCourseResourcesRaw(courseId)
        const resource = resourcesData.resources.find(r => r.id === resourceId)
        
        if (resource) {
          const { error: insertError } = await supabase
            .from('course_resources')
            .insert({
              course_id: courseId,
              resource_id: resourceId,
              type: resource.type,
              title: resource.title,
              description: resource.description,
              icon: resource.icon,
              tags: resource.tags || []
            })
          
          if (insertError) throw insertError
        }
      }
    } catch (error) {
      console.error('Error ensuring course resource exists:', error)
    }
  }

  /**
   * Get raw course resources without user data
   * @private
   */
  async getCourseResourcesRaw(courseId) {
    const response = await fetch(`${import.meta.env.BASE_URL}data/software-dev/${courseId}/resources.json`)
    if (!response.ok) {
      throw new Error(`Failed to fetch resources: ${response.status}`)
    }
    return response.json()
  }

  /**
   * Extract resource ID from resource path
   * @private
   */
  getResourceIdFromPath(resourcePath) {
    // Map common patterns - this could be made more sophisticated
    const pathMappings = {
      'resources/cheat-sheet.json': 'quick-reference',
      'resources/links.json': 'official-docs',
      'resources/glossary.json': 'terminology'
    }
    
    return pathMappings[resourcePath] || null
  }
}

// Export singleton instance
export const resourceService = new ResourceService()