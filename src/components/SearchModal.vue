<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto" @click.self="closeSearch">
    <div class="flex items-start justify-center min-h-screen pt-20 px-4">
      <div class="fixed inset-0 bg-gray-900 bg-opacity-50 transition-opacity"></div>
          
          <div class="relative bg-white rounded-lg shadow-xl max-w-2xl w-full">
            <!-- Search Input -->
            <div class="border-b border-gray-200">
              <div class="flex items-center px-4 py-3">
                <svg class="w-5 h-5 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <input
                  ref="searchInput"
                  v-model="searchQuery"
                  type="text"
                  placeholder="Search modules, commands, or concepts..."
                  class="flex-1 outline-none text-lg"
                  @keydown.escape="closeSearch"
                  @keydown.enter="selectResult(highlightedIndex)"
                  @keydown.arrow-up.prevent="navigateUp"
                  @keydown.arrow-down.prevent="navigateDown"
                >
                <button @click="closeSearch" class="text-gray-400 hover:text-gray-600 ml-3">
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
            
            <!-- Search Results -->
            <div class="max-h-96 overflow-y-auto">
              <div v-if="searchQuery.length === 0" class="p-8 text-center text-gray-500">
                <p>Start typing to search...</p>
                <div class="mt-4 text-sm">
                  <p class="mb-2">Try searching for:</p>
                  <div class="flex flex-wrap gap-2 justify-center">
                    <button 
                      v-for="suggestion in suggestions" 
                      :key="suggestion"
                      @click="searchQuery = suggestion"
                      class="px-3 py-1 bg-gray-100 rounded-full hover:bg-gray-200 transition-colors"
                    >
                      {{ suggestion }}
                    </button>
                  </div>
                </div>
              </div>
              
              <div v-else-if="loading" class="p-8 text-center text-gray-500">
                Searching...
              </div>
              
              <div v-else-if="results.length === 0" class="p-8 text-center text-gray-500">
                No results found for "{{ searchQuery }}"
              </div>
              
              <div v-else>
                <div
                  v-for="(result, index) in results"
                  :key="`${result.moduleId}-${result.sectionIndex}`"
                  @click="selectResult(index)"
                  @mouseenter="highlightedIndex = index"
                  :class="{ 'bg-blue-50': highlightedIndex === index }"
                  class="px-4 py-3 border-b border-gray-100 cursor-pointer hover:bg-blue-50 transition-colors"
                >
                  <div class="flex items-start">
                    <span class="text-2xl mr-3">{{ result.icon }}</span>
                    <div class="flex-1 min-w-0">
                      <h3 class="font-semibold text-gray-900">
                        {{ result.moduleTitle }}
                        <span class="text-gray-500 text-sm font-normal ml-2">
                          › {{ result.sectionTitle }}
                        </span>
                      </h3>
                      <p class="text-sm text-gray-600 mt-1" v-html="result.highlight"></p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Footer -->
            <div class="border-t border-gray-200 px-4 py-3 text-xs text-gray-500 flex items-center justify-between">
              <div class="flex items-center gap-4">
                <span><kbd class="px-2 py-1 bg-gray-100 rounded">↑↓</kbd> Navigate</span>
                <span><kbd class="px-2 py-1 bg-gray-100 rounded">Enter</kbd> Select</span>
                <span><kbd class="px-2 py-1 bg-gray-100 rounded">Esc</kbd> Close</span>
              </div>
              <div v-if="results.length > 0">
                {{ results.length }} results
              </div>
            </div>
          </div>
        </div>
    </div>
</template>

<script setup>
import { ref, watch, computed, nextTick, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  isOpen: Boolean,
  modules: Array
})

const emit = defineEmits(['close'])

const router = useRouter()
const searchInput = ref(null)
const searchQuery = ref('')
const results = ref([])
const loading = ref(false)
const highlightedIndex = ref(0)

const suggestions = [
  '/review',
  'extended thinking',
  'screenshot',
  'CLAUDE.md',
  'MCP',
  'hooks'
]

// Create searchable index from modules
const searchIndex = computed(() => {
  const index = []
  
  props.modules.forEach(module => {
    module.sections.forEach((section, sectionIndex) => {
      // Strip HTML tags for searching
      const contentText = section.content.replace(/<[^>]*>/g, ' ').toLowerCase()
      const exampleText = (section.example || '').toLowerCase()
      
      index.push({
        moduleId: module.id,
        moduleTitle: module.title,
        icon: module.icon,
        sectionIndex,
        sectionTitle: section.title,
        content: contentText,
        example: exampleText,
        searchText: `${module.title} ${section.title} ${contentText} ${exampleText}`.toLowerCase()
      })
    })
  })
  
  return index
})

// Fuzzy search function
const fuzzySearch = (query, text) => {
  const queryChars = query.toLowerCase().split('')
  let searchIndex = 0
  
  for (const char of queryChars) {
    searchIndex = text.indexOf(char, searchIndex)
    if (searchIndex === -1) return false
    searchIndex++
  }
  
  return true
}

// Highlight matching text
const highlightMatch = (text, query) => {
  const regex = new RegExp(`(${query.split('').join('.*?')})`, 'gi')
  const match = text.match(regex)
  
  if (!match) return text.substring(0, 150) + '...'
  
  const startIndex = Math.max(0, text.indexOf(match[0]) - 50)
  const endIndex = Math.min(text.length, startIndex + 200)
  let excerpt = text.substring(startIndex, endIndex)
  
  if (startIndex > 0) excerpt = '...' + excerpt
  if (endIndex < text.length) excerpt += '...'
  
  // Highlight the match
  excerpt = excerpt.replace(regex, '<mark class="bg-yellow-200">$1</mark>')
  
  return excerpt
}

// Search function
const performSearch = () => {
  if (searchQuery.value.length < 2) {
    results.value = []
    return
  }
  
  loading.value = true
  
  // Simulate search delay for better UX
  setTimeout(() => {
    const query = searchQuery.value
    const searchResults = []
    
    searchIndex.value.forEach(item => {
      // Check for exact match first
      if (item.searchText.includes(query.toLowerCase())) {
        searchResults.push({
          ...item,
          highlight: highlightMatch(item.content, query),
          score: 2
        })
      }
      // Then fuzzy match
      else if (fuzzySearch(query, item.searchText)) {
        searchResults.push({
          ...item,
          highlight: highlightMatch(item.content, query),
          score: 1
        })
      }
    })
    
    // Sort by score and limit results
    results.value = searchResults
      .sort((a, b) => b.score - a.score)
      .slice(0, 20)
    
    highlightedIndex.value = 0
    loading.value = false
    
    // Save to search history
    saveSearchHistory(query)
  }, 150)
}

// Save search history
const saveSearchHistory = (query) => {
  const history = JSON.parse(localStorage.getItem('searchHistory') || '[]')
  const filtered = history.filter(item => item !== query)
  filtered.unshift(query)
  localStorage.setItem('searchHistory', JSON.stringify(filtered.slice(0, 10)))
}

// Navigation functions
const navigateUp = () => {
  if (highlightedIndex.value > 0) {
    highlightedIndex.value--
  }
}

const navigateDown = () => {
  if (highlightedIndex.value < results.value.length - 1) {
    highlightedIndex.value++
  }
}

const selectResult = (index) => {
  if (results.value[index]) {
    const result = results.value[index]
    router.push(`/module/${result.moduleId}`)
    
    // Set the section in localStorage so the module opens at the right place
    localStorage.setItem(`module_${result.moduleId}_section`, result.sectionIndex.toString())
    
    closeSearch()
  }
}

const closeSearch = () => {
  searchQuery.value = ''
  results.value = []
  emit('close')
}

// Watch search query
watch(searchQuery, () => {
  performSearch()
})

// Focus input when opened
watch(() => props.isOpen, async (newVal) => {
  if (newVal) {
    await nextTick()
    searchInput.value?.focus()
  }
})

// Removed global keyboard shortcut
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .relative,
.modal-leave-active .relative {
  transition: transform 0.2s ease;
}

.modal-enter-from .relative {
  transform: scale(0.95) translateY(-10px);
}

.modal-leave-to .relative {
  transform: scale(0.95) translateY(-10px);
}

kbd {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
  font-size: 0.75rem;
}
</style>