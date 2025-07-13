import { ref, computed } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useAuth } from './useAuth'

// Shared state
const categories = ref([])
const courses = ref({}) // Keyed by category slug
const favoriteCategories = ref([])
const isLoading = ref(false)
const error = ref(null)

export function useCategories() {
  const { user } = useAuth()

  // Load categories from JSON and database
  async function loadCategories() {
    isLoading.value = true
    error.value = null

    try {
      // Load categories from JSON
      const response = await fetch(import.meta.env.BASE_URL + 'data/categories.json')
      const data = await response.json()
      categories.value = data.categories

      // If user is logged in, load favorites
      if (user.value) {
        await loadFavorites()
      }
    } catch (err) {
      console.error('Failed to load categories:', err)
      error.value = 'Failed to load categories'
    } finally {
      isLoading.value = false
    }
  }

  // Load courses for a specific category
  async function loadCategoryCourses(categorySlug) {
    if (courses.value[categorySlug]) {
      return courses.value[categorySlug]
    }

    try {
      const response = await fetch(
        import.meta.env.BASE_URL + `data/${categorySlug}/courses.json`
      )
      const data = await response.json()
      courses.value[categorySlug] = data.courses
      return data.courses
    } catch (err) {
      console.error(`Failed to load courses for ${categorySlug}:`, err)
      return []
    }
  }

  // Load user's favorite categories
  async function loadFavorites() {
    if (!user.value) return

    try {
      const { data, error: favError } = await supabase
        .from('user_favorite_categories_simple')
        .select('category_slug, created_at')
        .eq('user_id', user.value.id)

      if (favError) throw favError

      // Map to expected format for compatibility
      favoriteCategories.value = (data || []).map(item => ({
        category_id: item.category_slug,
        created_at: item.created_at
      }))
    } catch (err) {
      console.error('Failed to load favorite categories:', err)
    }
  }

  // Toggle favorite status for a category
  async function toggleFavorite(categorySlug) {
    if (!user.value) {
      error.value = 'Please login to favorite categories'
      return false
    }

    const isFavorited = isCategoryFavorited(categorySlug)

    try {
      if (isFavorited) {
        // Remove favorite
        const { error: deleteError } = await supabase
          .from('user_favorite_categories_simple')
          .delete()
          .eq('user_id', user.value.id)
          .eq('category_slug', categorySlug)

        if (deleteError) throw deleteError

        favoriteCategories.value = favoriteCategories.value.filter(
          fav => fav.category_id !== categorySlug
        )
      } else {
        // Add favorite
        const { data, error: insertError } = await supabase
          .from('user_favorite_categories_simple')
          .insert({
            user_id: user.value.id,
            category_slug: categorySlug
          })
          .select()

        if (insertError) throw insertError

        favoriteCategories.value.push({
          category_id: categorySlug,
          created_at: new Date().toISOString()
        })
      }

      return true
    } catch (err) {
      console.error('Failed to toggle favorite:', err)
      error.value = 'Failed to update favorites'
      return false
    }
  }

  // Check if a category is favorited
  function isCategoryFavorited(categorySlug) {
    return favoriteCategories.value.some(fav => fav.category_id === categorySlug)
  }

  // Get category by slug
  function getCategoryBySlug(slug) {
    return categories.value.find(cat => cat.slug === slug)
  }

  // Computed: categories sorted with favorites first
  const sortedCategories = computed(() => {
    if (!user.value || favoriteCategories.value.length === 0) {
      return categories.value
    }

    const favoriteSlugs = favoriteCategories.value.map(fav => fav.category_id)
    
    return [...categories.value].sort((a, b) => {
      const aIsFavorite = favoriteSlugs.includes(a.slug)
      const bIsFavorite = favoriteSlugs.includes(b.slug)
      
      if (aIsFavorite && !bIsFavorite) return -1
      if (!aIsFavorite && bIsFavorite) return 1
      return a.sortOrder - b.sortOrder
    })
  })

  // Get category progress from database
  async function getCategoryProgress(categorySlug) {
    if (!user.value) return null

    try {
      // This would call a database function to get progress
      // For now, return mock data
      return {
        totalCourses: 0,
        totalModules: 0,
        completedModules: 0,
        progressPercentage: 0
      }
    } catch (err) {
      console.error('Failed to get category progress:', err)
      return null
    }
  }

  return {
    // State
    categories,
    courses,
    favoriteCategories,
    isLoading,
    error,

    // Methods
    loadCategories,
    loadCategoryCourses,
    toggleFavorite,
    isCategoryFavorited,
    getCategoryBySlug,
    getCategoryProgress,

    // Computed
    sortedCategories
  }
}