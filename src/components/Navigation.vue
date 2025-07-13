<template>
  <nav class="bg-white shadow-sm border-b border-gray-200">
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <!-- Logo/Home link -->
        <router-link to="/" class="flex items-center space-x-2">
          <span class="text-xl font-bold text-gray-900">Claude Learn</span>
        </router-link>
        
        <!-- Navigation items -->
        <div class="flex items-center space-x-4">
          <!-- My Resources dropdown -->
          <div v-if="isAuthenticated" class="relative" ref="resourcesDropdownRef">
            <button
              @click="resourcesDropdownOpen = !resourcesDropdownOpen"
              class="flex items-center text-sm font-medium text-gray-700 hover:text-gray-900 focus:outline-none px-3 py-2 rounded-md"
            >
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <span class="mr-1">My Resources</span>
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            
            <!-- Resources dropdown menu -->
            <transition name="dropdown">
              <div
                v-if="resourcesDropdownOpen"
                class="absolute right-0 mt-2 w-80 bg-white rounded-md shadow-lg py-1 z-50 border border-gray-200"
              >
                <!-- Header -->
                <div class="px-4 py-3 border-b border-gray-100">
                  <h3 class="text-sm font-semibold text-gray-900">Quick Access</h3>
                  <p class="text-xs text-gray-500 mt-1">Your favorite and recent resources</p>
                </div>
                
                <!-- Favorites section -->
                <div v-if="favoriteResources.length > 0" class="py-2">
                  <div class="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
                    Favorites ({{ favoriteResources.length }})
                  </div>
                  <div
                    v-for="resource in favoriteResources.slice(0, 3)"
                    :key="`nav-fav-${resource.id}`"
                    class="px-4 py-2 hover:bg-gray-50 cursor-pointer"
                    @click="openResourceFromNav(resource)"
                  >
                    <div class="flex items-center space-x-3">
                      <span class="text-lg">{{ resource.icon }}</span>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">{{ resource.title }}</p>
                        <p class="text-xs text-gray-500 truncate">{{ resource.description }}</p>
                      </div>
                      <button
                        @click.stop="toggleFavoriteFromNav(resource)"
                        class="flex-shrink-0 p-1 rounded hover:bg-gray-200 transition-colors"
                        title="Remove from favorites"
                      >
                        <svg class="w-4 h-4 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                        </svg>
                      </button>
                    </div>
                  </div>
                  <div v-if="favoriteResources.length > 3" class="px-4 py-2">
                    <button
                      @click="openAllFavorites"
                      class="text-sm text-blue-600 hover:text-blue-800"
                    >
                      View all {{ favoriteResources.length }} favorites
                    </button>
                  </div>
                </div>

                <!-- Recent section -->
                <div v-if="recentResources.length > 0" class="py-2 border-t border-gray-100">
                  <div class="px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
                    Recent
                  </div>
                  <div
                    v-for="resource in recentResources.slice(0, 3)"
                    :key="`nav-recent-${resource.resourceId}`"
                    class="px-4 py-2 hover:bg-gray-50 cursor-pointer"
                    @click="openResourceFromNav(resource)"
                  >
                    <div class="flex items-center space-x-3">
                      <span class="text-lg">{{ resource.icon }}</span>
                      <div class="flex-1 min-w-0">
                        <p class="text-sm font-medium text-gray-900 truncate">{{ resource.title }}</p>
                        <p class="text-xs text-gray-500 truncate">{{ formatTimeAgo(resource.viewedAt) }}</p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Actions -->
                <div class="border-t border-gray-100 py-2">
                  <button
                    @click="openCommandPalette"
                    class="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center"
                  >
                    <svg class="w-4 h-4 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    Search all resources
                    <kbd class="ml-auto px-1.5 py-0.5 text-xs bg-gray-100 rounded border">⌘K</kbd>
                  </button>
                </div>

                <!-- Empty state -->
                <div v-if="favoriteResources.length === 0 && recentResources.length === 0" class="py-8 text-center">
                  <svg class="w-8 h-8 text-gray-400 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  <p class="text-sm text-gray-500">No resources yet</p>
                  <p class="text-xs text-gray-400 mt-1">Start learning to see your favorites here</p>
                </div>
              </div>
            </transition>
          </div>
          
          <router-link
            v-if="isAuthenticated && isAdmin"
            to="/admin"
            class="text-purple-700 hover:text-purple-900 px-3 py-2 rounded-md text-sm font-medium"
          >
            Admin
          </router-link>
          
          <!-- User dropdown -->
          <div v-if="isAuthenticated" class="relative">
            <button
              @click="dropdownOpen = !dropdownOpen"
              class="flex items-center text-sm font-medium text-gray-700 hover:text-gray-900 focus:outline-none"
            >
              <span class="mr-2">{{ user?.email }}</span>
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            
            <!-- Dropdown menu -->
            <transition name="dropdown">
              <div
                v-if="dropdownOpen"
                class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50"
              >
                <router-link
                  to="/profile"
                  @click="dropdownOpen = false"
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Profile Settings
                </router-link>
                <hr class="my-1">
                <button
                  @click="handleLogout"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Sign out
                </button>
              </div>
            </transition>
          </div>
          
          <!-- Login button -->
          <router-link
            v-else
            to="/login"
            class="bg-blue-600 text-white hover:bg-blue-700 px-4 py-2 rounded-md text-sm font-medium"
          >
            Sign in
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useAdmin } from '../composables/useAdmin'
import { resourceService } from '../services/resourceService'

const { user, isAuthenticated, signOut } = useAuth()
const { isAdmin, checkAdminStatus } = useAdmin()
const dropdownOpen = ref(false)
const resourcesDropdownOpen = ref(false)
const resourcesDropdownRef = ref(null)

// Get favorite resources from resourceService
const favoriteResources = ref([])
const recentResources = ref([])

const handleLogout = async () => {
  dropdownOpen.value = false
  await signOut()
}

// Resource dropdown handlers
const openResourceFromNav = (resource) => {
  resourcesDropdownOpen.value = false
  
  // Add the path property that ResourceModal expects
  const fullResource = {
    ...resource,
    path: `resources/${resource.type}.json` // construct path based on type
  }
  
  // Emit event to open resource modal
  window.dispatchEvent(new CustomEvent('open-resource', { detail: fullResource }))
}

const openAllFavorites = () => {
  resourcesDropdownOpen.value = false
  // Open command palette
  window.dispatchEvent(new CustomEvent('open-command-palette'))
}

const openCommandPalette = () => {
  resourcesDropdownOpen.value = false
  // Open command palette
  window.dispatchEvent(new CustomEvent('open-command-palette'))
}

// Format time ago
const formatTimeAgo = (date) => {
  if (!date) return ''
  const now = new Date()
  const past = new Date(date)
  const diffMs = now - past
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
  
  if (diffHours < 1) return 'Just now'
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`
  return past.toLocaleDateString()
}


// Toggle favorite from navigation dropdown
const toggleFavoriteFromNav = async (resource) => {
  try {
    const result = await resourceService.toggleFavorite(resource.courseId, resource.id)
    
    if (result) {
      // Remove from favorites list
      favoriteResources.value = favoriteResources.value.filter(
        r => !(r.courseId === resource.courseId && r.id === resource.id)
      )
      // Dispatch event to notify other components
      window.dispatchEvent(new CustomEvent('favorite-changed'))
    }
  } catch (error) {
    console.error('[Navigation] Error toggling favorite:', error)
  }
}

// Load favorite resources
const loadFavoriteResources = async () => {
  if (!isAuthenticated.value) return
  
  try {
    const favorites = await resourceService.getFavoriteResources()
    favoriteResources.value = favorites
  } catch (error) {
    console.error('[Navigation] Error loading favorites:', error)
  }
}

// Load recent resources
const loadRecentResources = async () => {
  if (!isAuthenticated.value) return
  
  try {
    const recent = await resourceService.getRecentResources(5)
    recentResources.value = recent
  } catch (error) {
    console.error('[Navigation] Error loading recent resources:', error)
  }
}

onMounted(async () => {
  if (isAuthenticated.value) {
    await checkAdminStatus()
    await loadFavoriteResources()
    await loadRecentResources()
  }
  
  // Listen for favorite changes from other components
  window.addEventListener('favorite-changed', loadFavoriteResources)
})

// Watch for authentication changes
watch(isAuthenticated, async (newVal) => {
  if (newVal) {
    await loadFavoriteResources()
    await loadRecentResources()
  } else {
    favoriteResources.value = []
    recentResources.value = []
  }
})

// Handle click outside to close dropdown
const handleClickOutside = (event) => {
  if (resourcesDropdownRef.value && !resourcesDropdownRef.value.contains(event.target)) {
    resourcesDropdownOpen.value = false
  }
}

// Add click outside listener when dropdown is open
watch(resourcesDropdownOpen, (isOpen) => {
  if (isOpen) {
    document.addEventListener('click', handleClickOutside)
  } else {
    document.removeEventListener('click', handleClickOutside)
  }
})

// Cleanup event listeners
onUnmounted(() => {
  window.removeEventListener('favorite-changed', loadFavoriteResources)
  document.removeEventListener('click', handleClickOutside)
})

</script>