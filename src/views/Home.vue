<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    <div class="container mx-auto px-4 py-8">
      <header class="text-center mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">
          Company Learning Hub
        </h1>
        <p class="text-xl text-gray-600 max-w-2xl mx-auto">
          Access training resources across all departments
        </p>
        
        <!-- Overall Progress -->
        <div class="mt-6 max-w-md mx-auto">
          <div class="bg-white rounded-lg p-4 shadow-sm">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Overall Progress</span>
              <span class="text-sm text-gray-600">{{ overallProgress.completed }} / {{ overallProgress.total }} modules</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
              <div 
                class="bg-gradient-to-r from-blue-500 to-blue-600 h-3 rounded-full transition-all duration-1000 ease-out relative overflow-hidden"
                :style="`width: ${overallProgress.percentage}%`"
              >
                <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-shimmer"></div>
              </div>
            </div>
            <p class="text-xs text-gray-500 mt-2 text-center">{{ overallProgress.percentage }}% Complete</p>
          </div>
        </div>
      </header>

      <div class="max-w-6xl mx-auto">
        <!-- New Content Notification -->
        <div v-if="hasNewContentInFavorites" class="mb-8">
          <div class="bg-green-50 border border-green-200 rounded-lg p-4 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <div class="p-2 bg-green-100 rounded-lg">
                <svg class="w-5 h-5 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
              </div>
              <div>
                <h3 class="text-green-900 font-medium">New content available!</h3>
                <p class="text-green-700 text-sm">Check your favorite categories for new courses and modules.</p>
              </div>
            </div>
            <button
              @click="dismissNewContentNotification"
              class="text-green-600 hover:text-green-800 p-1"
            >
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Favorite Categories (if any) -->
        <div v-if="favoriteCategories.length > 0" class="mb-12">
          <h2 class="text-2xl font-semibold mb-6 flex items-center gap-2">
            <svg class="w-6 h-6 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
            Your Favorites
          </h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            <CategoryCard
              v-for="category in sortedCategories.filter(cat => isCategoryFavorited(cat.slug))"
              :key="category.slug"
              :category="category"
              :is-favorited="true"
              @toggle-favorite="handleToggleFavorite"
            />
          </div>
        </div>

        <!-- All Categories -->
        <div>
          <h2 class="text-2xl font-semibold mb-6">
            {{ favoriteCategories.length > 0 ? 'All Categories' : 'Training Categories' }}
          </h2>
          <LoadingSkeletons v-if="isLoading" type="module-cards" :count="4" />
          <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <CategoryCard
              v-for="category in sortedCategories"
              :key="category.slug"
              :category="category"
              :is-favorited="isCategoryFavorited(category.slug)"
              @toggle-favorite="handleToggleFavorite"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useSupabaseProgress } from '../composables/useSupabaseProgress.js'
import { useCategories } from '../composables/useCategories.js'
import { globalErrorHandler } from '../composables/useErrorHandler.js'
import Navigation from '../components/Navigation.vue'
import LoadingSkeletons from '../components/LoadingSkeletons.vue'
import CategoryCard from '../components/CategoryCard.vue'

// Use composables
const { overallProgress, loadProgress } = useSupabaseProgress()
const { 
  sortedCategories, 
  favoriteCategories,
  isLoading, 
  loadCategories, 
  toggleFavorite,
  isCategoryFavorited 
} = useCategories()

// Local state
const hasNewContentInFavorites = ref(false)

// Handle favorite toggle
async function handleToggleFavorite(categorySlug) {
  const success = await toggleFavorite(categorySlug)
  if (success) {
    const action = isCategoryFavorited(categorySlug) ? 'added to' : 'removed from'
    globalErrorHandler.addSuccess(`Category ${action} favorites!`)
  }
}

// Check if there's new content in favorite categories
function checkForNewContent() {
  // Check if notification was already dismissed
  const dismissedDate = localStorage.getItem('new_content_notification_dismissed')
  if (dismissedDate) {
    const daysSinceDismissed = (new Date() - new Date(dismissedDate)) / (1000 * 60 * 60 * 24)
    if (daysSinceDismissed < 7) {
      return // Don't show notification for 7 days after dismissal
    }
  }
  
  // Check if any favorite categories have new content
  if (favoriteCategories.value.length > 0) {
    // For demo purposes, show notification if user has favorites
    // In a real app, this would check actual content dates
    hasNewContentInFavorites.value = true
  }
}

// Dismiss new content notification
function dismissNewContentNotification() {
  hasNewContentInFavorites.value = false
  localStorage.setItem('new_content_notification_dismissed', new Date().toISOString())
}

onMounted(async () => {
  // Load progress and categories in parallel
  await Promise.all([
    loadProgress(),
    loadCategories()
  ])
  
  // Check for new content after loading
  checkForNewContent()
})
</script>