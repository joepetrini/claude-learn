<template>
  <!-- Command Palette Modal -->
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-start justify-center pt-20 p-4 z-50"
    @click="handleBackdropClick"
  >
    <div
      ref="paletteContent"
      class="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[70vh] overflow-hidden"
      @click.stop
    >
      <!-- Search Input -->
      <div class="p-4 border-b border-gray-200">
        <div class="relative">
          <svg class="absolute left-3 top-3 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            ref="searchInput"
            v-model="searchQuery"
            type="text"
            placeholder="Search resources, navigate, or type a command..."
            class="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg"
            @keydown="handleKeyDown"
          />
        </div>
      </div>

      <!-- Results -->
      <div class="overflow-y-auto max-h-[50vh]">
        <!-- No results -->
        <div v-if="filteredResults.length === 0 && searchQuery" class="p-8 text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">No results found</h3>
          <p class="text-gray-600">Try searching for resources, courses, or commands</p>
        </div>

        <!-- Results sections -->
        <div v-else class="divide-y divide-gray-100">
          <!-- Quick Actions -->
          <div v-if="quickActions.length" class="p-2">
            <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
              Quick Actions
            </div>
            <div
              v-for="(action, index) in quickActions"
              :key="`action-${index}`"
              :class="{
                'bg-blue-50 border-blue-200': selectedIndex === getItemIndex('action', index),
                'hover:bg-gray-50': selectedIndex !== getItemIndex('action', index)
              }"
              class="flex items-center px-3 py-2 rounded-lg cursor-pointer border border-transparent"
              @click="executeAction(action)"
            >
              <div class="flex items-center space-x-3 flex-1">
                <div class="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
                  <span class="text-lg">{{ action.icon }}</span>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-900">{{ action.title }}</p>
                  <p class="text-xs text-gray-500">{{ action.description }}</p>
                </div>
                <kbd class="hidden sm:inline-block px-2 py-1 text-xs text-gray-500 bg-gray-100 rounded">
                  {{ action.shortcut }}
                </kbd>
              </div>
            </div>
          </div>

          <!-- Recent Resources -->
          <div v-if="recentResources.length" class="p-2">
            <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
              Recent Resources
            </div>
            <div
              v-for="(resource, index) in recentResources"
              :key="`recent-${resource.resourceId}`"
              :class="{
                'bg-blue-50 border-blue-200': selectedIndex === getItemIndex('recent', index),
                'hover:bg-gray-50': selectedIndex !== getItemIndex('recent', index)
              }"
              class="flex items-center px-3 py-2 rounded-lg cursor-pointer border border-transparent"
              @click="openResource(resource)"
            >
              <div class="flex items-center space-x-3 flex-1">
                <div class="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center">
                  <span class="text-lg">{{ resource.icon }}</span>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-900">{{ resource.title }}</p>
                  <p class="text-xs text-gray-500">{{ resource.description }}</p>
                </div>
                <div class="text-right">
                  <p class="text-xs text-gray-400">{{ formatTimeAgo(resource.viewedAt) }}</p>
                  <span class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full capitalize">
                    {{ resource.type?.replace('-', ' ') }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Favorite Resources -->
          <div v-if="favoriteResources.length" class="p-2">
            <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
              Favorite Resources
            </div>
            <div
              v-for="(resource, index) in favoriteResources"
              :key="`favorite-${resource.id}`"
              :class="{
                'bg-blue-50 border-blue-200': selectedIndex === getItemIndex('favorite', index),
                'hover:bg-gray-50': selectedIndex !== getItemIndex('favorite', index)
              }"
              class="flex items-center px-3 py-2 rounded-lg cursor-pointer border border-transparent"
              @click="openResourceById(resource)"
            >
              <div class="flex items-center space-x-3 flex-1">
                <div class="w-8 h-8 rounded-lg bg-yellow-100 flex items-center justify-center">
                  <span class="text-lg">{{ resource.icon }}</span>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-900">{{ resource.title }}</p>
                  <p class="text-xs text-gray-500">{{ resource.description }}</p>
                </div>
                <div class="flex items-center space-x-2">
                  <svg class="w-4 h-4 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                  </svg>
                  <span class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full capitalize">
                    {{ resource.type?.replace('-', ' ') }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Search Results -->
          <div v-if="searchResults.length" class="p-2">
            <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
              Search Results
            </div>
            <div
              v-for="(resource, index) in searchResults"
              :key="`search-${resource.courseId}-${resource.resourceId}`"
              :class="{
                'bg-blue-50 border-blue-200': selectedIndex === getItemIndex('search', index),
                'hover:bg-gray-50': selectedIndex !== getItemIndex('search', index)
              }"
              class="flex items-center px-3 py-2 rounded-lg cursor-pointer border border-transparent"
              @click="openSearchResult(resource)"
            >
              <div class="flex items-center space-x-3 flex-1">
                <div class="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
                  <span class="text-lg">{{ resource.icon || '📄' }}</span>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-900">{{ resource.title }}</p>
                  <p class="text-xs text-gray-500">{{ resource.description }}</p>
                </div>
                <div class="text-right">
                  <span class="inline-block px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full">
                    {{ resource.courseTitle }}
                  </span>
                  <span class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full capitalize mt-1">
                    {{ resource.type?.replace('-', ' ') }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <!-- Navigation -->
          <div v-if="navigationResults.length" class="p-2">
            <div class="px-3 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wide">
              Navigation
            </div>
            <div
              v-for="(nav, index) in navigationResults"
              :key="`nav-${nav.path}`"
              :class="{
                'bg-blue-50 border-blue-200': selectedIndex === getItemIndex('navigation', index),
                'hover:bg-gray-50': selectedIndex !== getItemIndex('navigation', index)
              }"
              class="flex items-center px-3 py-2 rounded-lg cursor-pointer border border-transparent"
              @click="navigateTo(nav.path)"
            >
              <div class="flex items-center space-x-3 flex-1">
                <div class="w-8 h-8 rounded-lg bg-green-100 flex items-center justify-center">
                  <span class="text-lg">{{ nav.icon }}</span>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm font-medium text-gray-900">{{ nav.title }}</p>
                  <p class="text-xs text-gray-500">{{ nav.description }}</p>
                </div>
                <span class="text-xs text-gray-400">{{ nav.path }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="p-3 border-t border-gray-200 bg-gray-50">
        <div class="flex items-center justify-between text-xs text-gray-500">
          <div class="flex items-center space-x-4">
            <span class="flex items-center space-x-1">
              <kbd class="px-1.5 py-0.5 bg-white border border-gray-300 rounded text-xs">↑↓</kbd>
              <span>Navigate</span>
            </span>
            <span class="flex items-center space-x-1">
              <kbd class="px-1.5 py-0.5 bg-white border border-gray-300 rounded text-xs">↵</kbd>
              <span>Select</span>
            </span>
            <span class="flex items-center space-x-1">
              <kbd class="px-1.5 py-0.5 bg-white border border-gray-300 rounded text-xs">ESC</kbd>
              <span>Close</span>
            </span>
          </div>
          <span>{{ filteredResults.length }} results</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useResources } from '../composables/useResources'
import { resourceService } from '../services/resourceService'
import { useAuth } from '../composables/useAuth'

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'open-resource'])

const router = useRouter()
const { isAuthenticated } = useAuth()
const searchInput = ref(null)
const paletteContent = ref(null)
const searchQuery = ref('')
const selectedIndex = ref(0)

// Mock data - in real app, these would come from composables
const recentResources = ref([])
const favoriteResources = ref([])
const searchResults = ref([])

// Quick actions that appear when no search query
const quickActions = computed(() => [
  {
    title: 'Go to Home',
    description: 'Return to the main dashboard',
    icon: '🏠',
    shortcut: 'Ctrl+H',
    action: () => navigateTo('/')
  },
  {
    title: 'My Favorites',
    description: 'View all your favorite resources',
    icon: '⭐',
    shortcut: 'Ctrl+F',
    action: () => showFavorites()
  },
  {
    title: 'Recent Activity',
    description: 'See your recently viewed resources',
    icon: '🕒',
    shortcut: 'Ctrl+R',
    action: () => showRecent()
  },
  {
    title: 'All Courses',
    description: 'Browse all available courses',
    icon: '📚',
    shortcut: 'Ctrl+C',
    action: () => navigateTo('/courses')
  }
])

// Navigation results when searching
const navigationResults = computed(() => {
  if (!searchQuery.value) return []
  
  const query = searchQuery.value.toLowerCase()
  const routes = [
    { title: 'Home Dashboard', description: 'Main learning dashboard', icon: '🏠', path: '/' },
    { title: 'Software Development', description: 'Software development courses', icon: '💻', path: '/category/software-dev' },
    { title: 'Claude Code Training', description: 'Learn to use Claude Code effectively', icon: '🤖', path: '/category/software-dev/claude-code-training' },
    { title: 'Admin Panel', description: 'Administrative tools and settings', icon: '⚙️', path: '/admin' },
    { title: 'Profile Settings', description: 'Manage your account and preferences', icon: '👤', path: '/profile' }
  ]
  
  return routes.filter(route => 
    route.title.toLowerCase().includes(query) ||
    route.description.toLowerCase().includes(query) ||
    route.path.toLowerCase().includes(query)
  )
})

// All filtered results
const filteredResults = computed(() => {
  const results = []
  
  if (!searchQuery.value) {
    // Show quick actions, recent, and favorites when no search
    results.push(...quickActions.value)
    results.push(...recentResources.value)
    results.push(...favoriteResources.value)
  } else {
    // Show search results when searching
    results.push(...quickActions.value.filter(action => 
      action.title.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      action.description.toLowerCase().includes(searchQuery.value.toLowerCase())
    ))
    results.push(...searchResults.value)
    results.push(...navigationResults.value)
  }
  
  return results
})

// Get the absolute index of an item across all sections
const getItemIndex = (section, index) => {
  let currentIndex = 0
  
  // Quick actions
  if (section === 'action') return currentIndex + index
  if (!searchQuery.value) {
    currentIndex += quickActions.value.length
  } else {
    currentIndex += quickActions.value.filter(action => 
      action.title.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      action.description.toLowerCase().includes(searchQuery.value.toLowerCase())
    ).length
  }
  
  // Recent resources
  if (section === 'recent') return currentIndex + index
  if (!searchQuery.value) {
    currentIndex += recentResources.value.length
  }
  
  // Favorite resources
  if (section === 'favorite') return currentIndex + index
  if (!searchQuery.value) {
    currentIndex += favoriteResources.value.length
  }
  
  // Search results
  if (section === 'search') return currentIndex + index
  if (searchQuery.value) {
    currentIndex += searchResults.value.length
  }
  
  // Navigation
  if (section === 'navigation') return currentIndex + index
  
  return currentIndex
}

// Handle keyboard navigation
const handleKeyDown = (event) => {
  const totalResults = filteredResults.value.length
  
  switch (event.key) {
    case 'ArrowDown':
      event.preventDefault()
      selectedIndex.value = (selectedIndex.value + 1) % totalResults
      break
    case 'ArrowUp':
      event.preventDefault()
      selectedIndex.value = selectedIndex.value === 0 ? totalResults - 1 : selectedIndex.value - 1
      break
    case 'Enter':
      event.preventDefault()
      selectCurrentItem()
      break
    case 'Escape':
      emit('close')
      break
  }
}

// Select the currently highlighted item
const selectCurrentItem = () => {
  let currentIndex = 0
  
  // Check quick actions
  const visibleQuickActions = !searchQuery.value ? quickActions.value : 
    quickActions.value.filter(action => 
      action.title.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
      action.description.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  
  if (selectedIndex.value < currentIndex + visibleQuickActions.length) {
    const actionIndex = selectedIndex.value - currentIndex
    executeAction(visibleQuickActions[actionIndex])
    return
  }
  currentIndex += visibleQuickActions.length
  
  // Check recent resources
  if (!searchQuery.value && selectedIndex.value < currentIndex + recentResources.value.length) {
    const resourceIndex = selectedIndex.value - currentIndex
    openResource(recentResources.value[resourceIndex])
    return
  }
  if (!searchQuery.value) currentIndex += recentResources.value.length
  
  // Check favorite resources
  if (!searchQuery.value && selectedIndex.value < currentIndex + favoriteResources.value.length) {
    const resourceIndex = selectedIndex.value - currentIndex
    openResourceById(favoriteResources.value[resourceIndex])
    return
  }
  if (!searchQuery.value) currentIndex += favoriteResources.value.length
  
  // Check search results
  if (searchQuery.value && selectedIndex.value < currentIndex + searchResults.value.length) {
    const resourceIndex = selectedIndex.value - currentIndex
    openSearchResult(searchResults.value[resourceIndex])
    return
  }
  if (searchQuery.value) currentIndex += searchResults.value.length
  
  // Check navigation
  if (searchQuery.value && selectedIndex.value < currentIndex + navigationResults.value.length) {
    const navIndex = selectedIndex.value - currentIndex
    navigateTo(navigationResults.value[navIndex].path)
    return
  }
}

// Action handlers
const executeAction = (action) => {
  action.action()
  emit('close')
}

const openResource = (resource) => {
  emit('open-resource', resource)
  emit('close')
}

const openResourceById = (resource) => {
  // Convert favorite resource to full resource object
  const fullResource = {
    ...resource,
    courseId: resource.courseId || 'claude-code-training', // fallback
    path: `resources/${resource.type}.json` // construct path
  }
  emit('open-resource', fullResource)
  emit('close')
}

const openSearchResult = (resource) => {
  emit('open-resource', resource)
  emit('close')
}

const navigateTo = (path) => {
  router.push(path)
  emit('close')
}

const showFavorites = () => {
  // Implementation would show favorites view
  console.log('Show favorites')
}

const showRecent = () => {
  // Implementation would show recent view
  console.log('Show recent')
}

// Load favorite resources from database
const loadFavoriteResources = async () => {
  if (!isAuthenticated.value) {
    favoriteResources.value = []
    return
  }
  
  try {
    const favorites = await resourceService.getFavoriteResources()
    favoriteResources.value = favorites
  } catch (error) {
    console.error('Error loading favorite resources:', error)
    favoriteResources.value = []
  }
}

// Handle backdrop click
const handleBackdropClick = (event) => {
  if (event.target === event.currentTarget) {
    emit('close')
  }
}

// Search for resources
const performSearch = async (query) => {
  if (!query) {
    searchResults.value = []
    return
  }
  
  try {
    // Mock search results - in real app, this would call the resource service
    searchResults.value = [
      {
        resourceId: 'quick-reference',
        courseId: 'claude-code-training',
        courseTitle: 'Claude Code Training',
        title: 'Claude Code Quick Reference',
        description: 'Essential commands and workflows for Python/Django developers',
        type: 'cheat-sheet',
        icon: '📋'
      },
      {
        resourceId: 'official-docs',
        courseId: 'claude-code-training',
        courseTitle: 'Claude Code Training',
        title: 'Documentation & Resources',
        description: 'Official documentation and community resources',
        type: 'links',
        icon: '🔗'
      }
    ].filter(resource => 
      resource.title.toLowerCase().includes(query.toLowerCase()) ||
      resource.description.toLowerCase().includes(query.toLowerCase())
    )
  } catch (error) {
    console.error('Search failed:', error)
    searchResults.value = []
  }
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

// Watch for search changes
watch(searchQuery, (newQuery) => {
  selectedIndex.value = 0
  performSearch(newQuery)
}, { immediate: true })

// Reset state when opened
watch(() => props.isOpen, async (isOpen) => {
  if (isOpen) {
    searchQuery.value = ''
    selectedIndex.value = 0
    await nextTick()
    searchInput.value?.focus()
    
    // Load recent and favorite resources
    // In real app, these would come from composables
    recentResources.value = [
      {
        resourceId: 'quick-reference',
        courseId: 'claude-code-training',
        title: 'Claude Code Quick Reference',
        description: 'Essential commands and workflows',
        type: 'cheat-sheet',
        icon: '📋',
        viewedAt: new Date(Date.now() - 2 * 60 * 60 * 1000) // 2 hours ago
      }
    ]
    
    // Load real favorite resources
    await loadFavoriteResources()
  }
})

// Prevent body scroll when open
watch(() => props.isOpen, async (isOpen) => {
  if (isOpen) {
    document.body.style.overflow = 'hidden'
    // Reload favorites when palette opens to ensure fresh data
    await loadFavoriteResources()
  } else {
    document.body.style.overflow = ''
  }
})

// Listen for favorite changes from other components
onMounted(() => {
  window.addEventListener('favorite-changed', loadFavoriteResources)
})

onUnmounted(() => {
  window.removeEventListener('favorite-changed', loadFavoriteResources)
})
</script>