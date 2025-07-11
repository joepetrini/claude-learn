<template>
  <div id="app">
    <!-- Global Search Button -->
    <button
      @click="toggleSearch"
      class="fixed bottom-4 right-4 z-40 bg-blue-600 text-white rounded-full p-3 shadow-lg hover:bg-blue-700 transition-colors md:hidden"
      title="Search"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
      </svg>
    </button>

    <!-- Desktop Search Hint -->
    <div class="hidden md:block fixed top-4 right-4 z-40">
      <button
        @click="toggleSearch"
        class="flex items-center gap-2 px-4 py-2 bg-white rounded-lg shadow-md hover:shadow-lg transition-shadow"
      >
        <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <span class="text-sm text-gray-600">Search</span>
      </button>
    </div>

    <router-view />
    
    <!-- Search Modal -->
    <SearchModal 
      :is-open="searchOpen" 
      :modules="modules"
      @close="toggleSearch"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import SearchModal from './components/SearchModal.vue'

const searchOpen = ref(false)
const modules = ref([])

const toggleSearch = () => {
  searchOpen.value = !searchOpen.value
}

// Load modules for search
onMounted(async () => {
  try {
    const response = await fetch(import.meta.env.BASE_URL + 'data/modules.json')
    const data = await response.json()
    modules.value = data.modules
  } catch (error) {
    console.error('Failed to load modules for search:', error)
  }
})

// Removed keyboard shortcut - using click only
</script>

<style>
#app {
  min-height: 100vh;
  background-color: #f3f4f6;
}

kbd {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
}
</style>