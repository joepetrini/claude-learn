<template>
  <div id="app">
    <!-- Global Search Button -->
    <button
      @click="openCommandPalette"
      class="fixed bottom-4 right-4 z-40 bg-blue-600 text-white rounded-full p-3 shadow-lg hover:bg-blue-700 transition-colors md:hidden"
      title="Search (Cmd+K)"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
      </svg>
    </button>

    <!-- Desktop Search Hint -->
    <div class="hidden md:block fixed top-4 right-4 z-40">
      <button
        @click="openCommandPalette"
        class="flex items-center gap-2 px-4 py-2 bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow"
      >
        <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <span class="text-sm text-gray-600">Search</span>
        <kbd class="ml-2 px-1.5 py-0.5 text-xs bg-gray-100 rounded border">⌘K</kbd>
      </button>
    </div>


    <router-view />
    
    <!-- Search Modal -->
    <SearchModal 
      :is-open="searchOpen" 
      :modules="modules"
      @close="toggleSearch"
    />
    
    <!-- Help Modal -->
    <HelpModal
      :is-open="helpOpen"
      @close="toggleHelp"
    />
    
    <!-- Command Palette -->
    <CommandPalette
      :is-open="isCommandPaletteOpen"
      @close="closeCommandPalette"
      @open-resource="handleOpenResource"
    />
    
    <!-- Resource Modal -->
    <ResourceModal
      :is-open="showResourceModal"
      :resource="selectedResource"
      :course-id="selectedResource?.courseId || 'claude-code-training'"
      @close="closeResourceModal"
      @toggle-favorite="handleToggleFavoriteFromModal"
    />
    
    <!-- Global Notification Center -->
    <NotificationCenter />
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import SearchModal from './components/SearchModal.vue'
import HelpModal from './components/HelpModal.vue'
import NotificationCenter from './components/NotificationCenter.vue'
import CommandPalette from './components/CommandPalette.vue'
import ResourceModal from './components/ResourceModal.vue'
import { useKeyboardNavigation } from './composables/useKeyboardNavigation.js'
import { useKeyboardShortcuts } from './composables/useKeyboardShortcuts.js'
import { useAuth } from './composables/useAuth.js'

const searchOpen = ref(false)
const helpOpen = ref(false)
const modules = ref([])

// Initialize authentication
const { initAuth } = useAuth()

// Initialize keyboard shortcuts and command palette
const { 
  isCommandPaletteOpen, 
  closeCommandPalette,
  openCommandPalette 
} = useKeyboardShortcuts()

const selectedResource = ref(null)
const showResourceModal = ref(false)

const toggleSearch = () => {
  searchOpen.value = !searchOpen.value
}

const toggleHelp = () => {
  helpOpen.value = !helpOpen.value
}

// Handle command palette resource opening
const handleOpenResource = (resource) => {
  
  // Ensure the resource has a path property for ResourceModal to load content
  const fullResource = {
    ...resource,
    // Add path if missing, using type to construct it
    path: resource.path || `resources/${resource.type}.json`,
    // Ensure id property exists (some resources have resourceId instead)
    id: resource.id || resource.resourceId
  }
  
  selectedResource.value = fullResource
  showResourceModal.value = true
}

// Handle resource modal closing
const closeResourceModal = () => {
  showResourceModal.value = false
  selectedResource.value = null
}

// Handle favorite toggle from resource modal
const handleToggleFavoriteFromModal = async (resource) => {
  try {
    // Import resourceService here to avoid circular dependencies
    const { resourceService } = await import('./services/resourceService')
    
    const newFavoriteStatus = await resourceService.toggleFavorite(
      resource.courseId || 'claude-code-training',
      resource.id || resource.resourceId
    )
    
    
    // Update the selected resource to reflect new favorite status
    if (selectedResource.value) {
      selectedResource.value.isFavorited = newFavoriteStatus
    }
    
    // Dispatch event to update other components
    window.dispatchEvent(new CustomEvent('favorite-changed'))
    
  } catch (error) {
    console.error('[App.vue] Error toggling favorite from modal:', error)
  }
}


// Initialize keyboard navigation
useKeyboardNavigation()

// Load modules for search and initialize auth
onMounted(async () => {
  // Initialize authentication state
  await initAuth()
  
  // Module search is deprecated in favor of resource search
  // Keeping modules empty for backward compatibility
  modules.value = []
  
  // Listen for keyboard navigation events
  window.addEventListener('toggle-search', toggleSearch)
  window.addEventListener('show-help', toggleHelp)
  
  // Listen for resource opening from navigation
  window.addEventListener('open-resource', (event) => {
    handleOpenResource(event.detail)
  })
})

// Clean up event listeners
onUnmounted(() => {
  window.removeEventListener('toggle-search', toggleSearch)
  window.removeEventListener('show-help', toggleHelp)
  window.removeEventListener('open-resource', handleOpenResource)
})

</script>

<style>
#app {
  min-height: 100vh;
  background-color: #f3f4f6;
}

kbd {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: opacity 0.2s, transform 0.2s;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}
</style>