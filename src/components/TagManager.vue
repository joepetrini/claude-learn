<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h3 class="text-lg font-semibold text-gray-900">Tag Management</h3>
        <p class="text-sm text-gray-600 mt-1">Organize and manage resource tags</p>
      </div>
      
      <!-- Quick actions -->
      <div class="flex items-center space-x-2">
        <button
          @click="showCreateModal = true"
          class="px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
        >
          Create Tag
        </button>
        <button
          @click="bulkCleanup"
          class="px-3 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors text-sm"
        >
          Cleanup Unused
        </button>
      </div>
    </div>

    <!-- Tag Filter and Search -->
    <div class="bg-white rounded-lg shadow-md p-4">
      <div class="flex flex-col md:flex-row gap-4">
        <!-- Search -->
        <div class="flex-1">
          <div class="relative">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search tags..."
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
            <svg class="absolute right-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
        
        <!-- Category filter -->
        <div class="w-full md:w-48">
          <select
            v-model="selectedCategory"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="">All Categories</option>
            <option v-for="category in categories" :key="category" :value="category">
              {{ formatCategoryName(category) }}
            </option>
          </select>
        </div>
        
        <!-- Sort by -->
        <div class="w-full md:w-48">
          <select
            v-model="sortBy"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="usage">Most Used</option>
            <option value="alphabetical">Alphabetical</option>
            <option value="recent">Recently Created</option>
            <option value="unused">Unused First</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Tag Statistics -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div class="bg-white rounded-lg shadow-md p-4">
        <div class="flex items-center">
          <div class="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center mr-3">
            <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
            </svg>
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900">{{ stats.total }}</p>
            <p class="text-sm text-gray-600">Total Tags</p>
          </div>
        </div>
      </div>
      
      <div class="bg-white rounded-lg shadow-md p-4">
        <div class="flex items-center">
          <div class="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center mr-3">
            <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900">{{ stats.used }}</p>
            <p class="text-sm text-gray-600">In Use</p>
          </div>
        </div>
      </div>
      
      <div class="bg-white rounded-lg shadow-md p-4">
        <div class="flex items-center">
          <div class="w-8 h-8 bg-yellow-100 rounded-lg flex items-center justify-center mr-3">
            <svg class="w-4 h-4 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z" />
            </svg>
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900">{{ stats.unused }}</p>
            <p class="text-sm text-gray-600">Unused</p>
          </div>
        </div>
      </div>
      
      <div class="bg-white rounded-lg shadow-md p-4">
        <div class="flex items-center">
          <div class="w-8 h-8 bg-purple-100 rounded-lg flex items-center justify-center mr-3">
            <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
          </div>
          <div>
            <p class="text-2xl font-bold text-gray-900">{{ stats.avgPerResource }}</p>
            <p class="text-sm text-gray-600">Avg per Resource</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Tags Grid -->
    <div class="bg-white rounded-lg shadow-md">
      <div class="p-4 border-b border-gray-200">
        <h4 class="text-lg font-semibold text-gray-900">
          Tags ({{ filteredTags.length }})
        </h4>
      </div>
      
      <div class="p-4">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="tag in paginatedTags"
            :key="tag.id"
            class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
          >
            <!-- Tag header -->
            <div class="flex items-center justify-between mb-3">
              <div class="flex items-center space-x-2">
                <span 
                  class="inline-block w-3 h-3 rounded-full"
                  :style="{ backgroundColor: tag.color }"
                ></span>
                <span class="font-medium text-gray-900">{{ tag.name }}</span>
                <span 
                  v-if="tag.category"
                  class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full"
                >
                  {{ formatCategoryName(tag.category) }}
                </span>
              </div>
              
              <!-- Actions dropdown -->
              <div class="relative">
                <button
                  @click="toggleDropdown(tag.id)"
                  class="p-1 text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
                  </svg>
                </button>
                
                <div
                  v-if="activeDropdown === tag.id"
                  class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-10 border border-gray-200"
                >
                  <button
                    @click="editTag(tag)"
                    class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Edit Tag
                  </button>
                  <button
                    @click="mergeTag(tag)"
                    class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    Merge with Another
                  </button>
                  <button
                    @click="deleteTag(tag)"
                    class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50"
                  >
                    Delete Tag
                  </button>
                </div>
              </div>
            </div>
            
            <!-- Tag description -->
            <p v-if="tag.description" class="text-sm text-gray-600 mb-3">
              {{ tag.description }}
            </p>
            
            <!-- Usage stats -->
            <div class="space-y-2">
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-500">Usage:</span>
                <span class="font-medium">{{ tag.usageCount }} resources</span>
              </div>
              
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-500">Created:</span>
                <span>{{ formatDate(tag.createdAt) }}</span>
              </div>
              
              <!-- Usage bar -->
              <div class="w-full bg-gray-200 rounded-full h-1.5">
                <div
                  class="bg-blue-600 h-1.5 rounded-full"
                  :style="{ width: `${(tag.usageCount / maxUsage) * 100}%` }"
                ></div>
              </div>
            </div>
            
            <!-- Recent resources using this tag -->
            <div v-if="tag.recentResources?.length > 0" class="mt-3 pt-3 border-t border-gray-100">
              <p class="text-xs text-gray-500 mb-2">Recent resources:</p>
              <div class="flex flex-wrap gap-1">
                <span
                  v-for="resource in tag.recentResources.slice(0, 3)"
                  :key="resource.id"
                  class="inline-block px-2 py-1 text-xs bg-blue-50 text-blue-700 rounded"
                >
                  {{ resource.title }}
                </span>
                <span
                  v-if="tag.recentResources.length > 3"
                  class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded"
                >
                  +{{ tag.recentResources.length - 3 }}
                </span>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Pagination -->
        <div v-if="totalPages > 1" class="mt-6 flex items-center justify-center">
          <div class="flex items-center space-x-2">
            <button
              @click="currentPage = Math.max(1, currentPage - 1)"
              :disabled="currentPage === 1"
              class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Previous
            </button>
            <span class="px-3 py-2 text-sm text-gray-700">
              Page {{ currentPage }} of {{ totalPages }}
            </span>
            <button
              @click="currentPage = Math.min(totalPages, currentPage + 1)"
              :disabled="currentPage === totalPages"
              class="px-3 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-500 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              Next
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Create/Edit Tag Modal -->
    <TagEditModal
      v-if="showCreateModal || showEditModal"
      :is-open="showCreateModal || showEditModal"
      :tag="editingTag"
      :categories="categories"
      @close="closeModals"
      @save="handleSaveTag"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import TagEditModal from './TagEditModal.vue'

// Reactive data
const searchQuery = ref('')
const selectedCategory = ref('')
const sortBy = ref('usage')
const activeDropdown = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingTag = ref(null)
const currentPage = ref(1)
const tagsPerPage = ref(12)

// Mock data
const tags = ref([
  {
    id: '1',
    name: 'commands',
    description: 'CLI commands and terminal operations',
    category: 'technical',
    color: '#3B82F6',
    usageCount: 15,
    createdAt: '2024-01-15',
    recentResources: [
      { id: '1', title: 'Claude Code Quick Reference' },
      { id: '2', title: 'Git Commands' }
    ]
  },
  {
    id: '2',
    name: 'shortcuts',
    description: 'Keyboard shortcuts and quick actions',
    category: 'productivity',
    color: '#10B981',
    usageCount: 12,
    createdAt: '2024-01-16',
    recentResources: [
      { id: '1', title: 'Claude Code Quick Reference' },
      { id: '3', title: 'VS Code Shortcuts' }
    ]
  },
  {
    id: '3',
    name: 'django',
    description: 'Django web framework concepts',
    category: 'framework',
    color: '#059669',
    usageCount: 8,
    createdAt: '2024-01-17',
    recentResources: [
      { id: '4', title: 'Django ORM Guide' },
      { id: '5', title: 'Django Best Practices' }
    ]
  },
  {
    id: '4',
    name: 'python',
    description: 'Python programming language',
    category: 'language',
    color: '#3B82F6',
    usageCount: 22,
    createdAt: '2024-01-14',
    recentResources: [
      { id: '6', title: 'Python Fundamentals' },
      { id: '7', title: 'Python Data Structures' }
    ]
  },
  {
    id: '5',
    name: 'unused-tag',
    description: 'This tag is not used by any resources',
    category: 'misc',
    color: '#6B7280',
    usageCount: 0,
    createdAt: '2024-01-20',
    recentResources: []
  }
])

const categories = computed(() => {
  const categorySet = new Set()
  tags.value.forEach(tag => {
    if (tag.category) categorySet.add(tag.category)
  })
  return Array.from(categorySet).sort()
})

const stats = computed(() => {
  const total = tags.value.length
  const used = tags.value.filter(tag => tag.usageCount > 0).length
  const unused = total - used
  const totalUsage = tags.value.reduce((sum, tag) => sum + tag.usageCount, 0)
  const avgPerResource = totalUsage > 0 ? (totalUsage / total).toFixed(1) : 0
  
  return { total, used, unused, avgPerResource }
})

const maxUsage = computed(() => {
  return Math.max(...tags.value.map(tag => tag.usageCount), 1)
})

const filteredTags = computed(() => {
  let filtered = tags.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(tag =>
      tag.name.toLowerCase().includes(query) ||
      tag.description?.toLowerCase().includes(query)
    )
  }

  // Category filter
  if (selectedCategory.value) {
    filtered = filtered.filter(tag => tag.category === selectedCategory.value)
  }

  // Sort
  filtered.sort((a, b) => {
    switch (sortBy.value) {
      case 'alphabetical':
        return a.name.localeCompare(b.name)
      case 'recent':
        return new Date(b.createdAt) - new Date(a.createdAt)
      case 'unused':
        return a.usageCount - b.usageCount
      case 'usage':
      default:
        return b.usageCount - a.usageCount
    }
  })

  return filtered
})

const totalPages = computed(() => {
  return Math.ceil(filteredTags.value.length / tagsPerPage.value)
})

const paginatedTags = computed(() => {
  const start = (currentPage.value - 1) * tagsPerPage.value
  const end = start + tagsPerPage.value
  return filteredTags.value.slice(start, end)
})

// Methods
const formatCategoryName = (category) => {
  return category.split('-').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}

const toggleDropdown = (tagId) => {
  activeDropdown.value = activeDropdown.value === tagId ? null : tagId
}

const editTag = (tag) => {
  editingTag.value = { ...tag }
  showEditModal.value = true
  activeDropdown.value = null
}

const deleteTag = (tag) => {
  if (tag.usageCount > 0) {
    if (!confirm(`Tag "${tag.name}" is used by ${tag.usageCount} resources. Delete anyway?`)) {
      return
    }
  }
  
  const index = tags.value.findIndex(t => t.id === tag.id)
  if (index > -1) {
    tags.value.splice(index, 1)
  }
  activeDropdown.value = null
}

const mergeTag = (tag) => {
  // In real app, this would show a merge dialog
  console.log('Merge tag:', tag.name)
  activeDropdown.value = null
}

const bulkCleanup = () => {
  const unusedCount = tags.value.filter(tag => tag.usageCount === 0).length
  if (unusedCount === 0) {
    alert('No unused tags found.')
    return
  }
  
  if (confirm(`Delete ${unusedCount} unused tags?`)) {
    tags.value = tags.value.filter(tag => tag.usageCount > 0)
  }
}

const closeModals = () => {
  showCreateModal.value = false
  showEditModal.value = false
  editingTag.value = null
}

const handleSaveTag = (tagData) => {
  if (tagData.id && showEditModal.value) {
    // Update existing tag
    const index = tags.value.findIndex(t => t.id === tagData.id)
    if (index > -1) {
      tags.value[index] = { ...tagData }
    }
  } else {
    // Create new tag
    tags.value.push({
      ...tagData,
      id: Date.now().toString(),
      usageCount: 0,
      createdAt: new Date().toISOString().split('T')[0],
      recentResources: []
    })
  }
  closeModals()
}

// Close dropdown when clicking outside
onMounted(() => {
  document.addEventListener('click', () => {
    activeDropdown.value = null
  })
})
</script>