<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-2xl font-bold text-gray-900">Resource Management</h2>
        <p class="text-gray-600 mt-1">Manage course resources, analytics, and content</p>
      </div>
      
      <div class="flex items-center space-x-3">
        <!-- Bulk actions dropdown -->
        <div v-if="selectedResources.length > 0" class="relative">
          <button
            @click="showBulkActions = !showBulkActions"
            class="px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors flex items-center space-x-2"
          >
            <span>{{ selectedResources.length }} selected</span>
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
          
          <!-- Bulk actions menu -->
          <div
            v-if="showBulkActions"
            class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-10 border border-gray-200"
          >
            <button
              @click="bulkArchive"
              class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
            >
              Archive Resources
            </button>
            <button
              @click="bulkDelete"
              class="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50"
            >
              Delete Resources
            </button>
            <button
              @click="bulkExport"
              class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
            >
              Export Data
            </button>
          </div>
        </div>
        
        <!-- Add resource button -->
        <button
          @click="showCreateModal = true"
          class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center space-x-2"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          <span>Add Resource</span>
        </button>
      </div>
    </div>

    <!-- Filters and Search -->
    <div class="bg-white rounded-lg shadow-md p-6">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Search -->
        <div class="md:col-span-2">
          <label class="block text-sm font-medium text-gray-700 mb-2">Search Resources</label>
          <div class="relative">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search by title, description, or tags..."
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
            <svg class="absolute right-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
        
        <!-- Course filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Course</label>
          <select
            v-model="selectedCourse"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="">All Courses</option>
            <option v-for="course in courses" :key="course.id" :value="course.id">
              {{ course.title }}
            </option>
          </select>
        </div>
        
        <!-- Type filter -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Type</label>
          <select
            v-model="selectedType"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          >
            <option value="">All Types</option>
            <option value="cheat-sheet">Cheat Sheet</option>
            <option value="links">Links</option>
            <option value="glossary">Glossary</option>
            <option value="downloads">Downloads</option>
            <option value="videos">Videos</option>
            <option value="tools">Tools</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Resource Table -->
    <div class="bg-white rounded-lg shadow-md overflow-hidden">
      <!-- Table header -->
      <div class="px-6 py-4 border-b border-gray-200">
        <div class="flex items-center justify-between">
          <h3 class="text-lg font-semibold text-gray-900">
            Resources ({{ filteredResources.length }})
          </h3>
          
          <!-- View toggle -->
          <div class="flex items-center space-x-2">
            <button
              @click="viewMode = 'table'"
              :class="{ 'bg-blue-100 text-blue-600': viewMode === 'table', 'text-gray-500': viewMode !== 'table' }"
              class="p-2 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 10h16M4 14h16M4 18h16" />
              </svg>
            </button>
            <button
              @click="viewMode = 'grid'"
              :class="{ 'bg-blue-100 text-blue-600': viewMode === 'grid', 'text-gray-500': viewMode !== 'grid' }"
              class="p-2 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
              </svg>
            </button>
          </div>
        </div>
      </div>

      <!-- Table view -->
      <div v-if="viewMode === 'table'" class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left">
                <input
                  type="checkbox"
                  @change="toggleSelectAll"
                  :checked="selectedResources.length === filteredResources.length && filteredResources.length > 0"
                  class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                >
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Resource
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Course
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Type
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Views
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Favorites
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr
              v-for="resource in paginatedResources"
              :key="resource.id"
              class="hover:bg-gray-50"
            >
              <td class="px-6 py-4">
                <input
                  type="checkbox"
                  :value="resource.id"
                  v-model="selectedResources"
                  class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                >
              </td>
              <td class="px-6 py-4">
                <div class="flex items-center space-x-3">
                  <span class="text-2xl">{{ resource.icon }}</span>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ resource.title }}</p>
                    <p class="text-xs text-gray-500">{{ resource.description }}</p>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 text-sm text-gray-900">
                {{ resource.courseName }}
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full capitalize"
                  :class="getTypeColor(resource.type)">
                  {{ resource.type.replace('-', ' ') }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-900">
                {{ formatNumber(resource.views) }}
              </td>
              <td class="px-6 py-4 text-sm text-gray-900">
                {{ formatNumber(resource.favorites) }}
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                  :class="resource.status === 'published' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'">
                  {{ resource.status }}
                </span>
              </td>
              <td class="px-6 py-4 text-sm text-gray-500">
                <div class="flex items-center space-x-2">
                  <button
                    @click="viewResource(resource)"
                    class="text-blue-600 hover:text-blue-800"
                    title="View"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </button>
                  <button
                    @click="editResource(resource)"
                    class="text-gray-600 hover:text-gray-800"
                    title="Edit"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                  </button>
                  <button
                    @click="duplicateResource(resource)"
                    class="text-gray-600 hover:text-gray-800"
                    title="Duplicate"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                    </svg>
                  </button>
                  <button
                    @click="deleteResource(resource)"
                    class="text-red-600 hover:text-red-800"
                    title="Delete"
                  >
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Grid view -->
      <div v-else class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <div
            v-for="resource in paginatedResources"
            :key="resource.id"
            class="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
          >
            <!-- Resource card content -->
            <div class="flex items-start justify-between mb-3">
              <div class="flex items-center space-x-3">
                <input
                  type="checkbox"
                  :value="resource.id"
                  v-model="selectedResources"
                  class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                >
                <span class="text-2xl">{{ resource.icon }}</span>
              </div>
              <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                :class="resource.status === 'published' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'">
                {{ resource.status }}
              </span>
            </div>
            
            <h4 class="text-sm font-semibold text-gray-900 mb-2">{{ resource.title }}</h4>
            <p class="text-xs text-gray-600 mb-3 line-clamp-2">{{ resource.description }}</p>
            
            <!-- Metadata -->
            <div class="space-y-2 mb-4">
              <div class="flex items-center justify-between text-xs">
                <span class="text-gray-500">Course:</span>
                <span class="font-medium">{{ resource.courseName }}</span>
              </div>
              <div class="flex items-center justify-between text-xs">
                <span class="text-gray-500">Type:</span>
                <span class="capitalize">{{ resource.type.replace('-', ' ') }}</span>
              </div>
              <div class="flex items-center justify-between text-xs">
                <span class="text-gray-500">Views:</span>
                <span class="font-medium">{{ formatNumber(resource.views) }}</span>
              </div>
            </div>
            
            <!-- Actions -->
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-2">
                <button
                  @click="viewResource(resource)"
                  class="text-blue-600 hover:text-blue-800"
                  title="View"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                </button>
                <button
                  @click="editResource(resource)"
                  class="text-gray-600 hover:text-gray-800"
                  title="Edit"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                  </svg>
                </button>
              </div>
              <button
                @click="deleteResource(resource)"
                class="text-red-600 hover:text-red-800"
                title="Delete"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div class="px-6 py-4 border-t border-gray-200">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700">
            Showing {{ ((currentPage - 1) * itemsPerPage) + 1 }} to {{ Math.min(currentPage * itemsPerPage, filteredResources.length) }} of {{ filteredResources.length }} results
          </div>
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

    <!-- Create/Edit Resource Modal -->
    <ResourceEditModal
      v-if="showCreateModal || showEditModal"
      :is-open="showCreateModal || showEditModal"
      :resource="editingResource"
      :courses="courses"
      @close="closeModals"
      @save="handleSaveResource"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import ResourceEditModal from './ResourceEditModal.vue'

// Reactive data
const searchQuery = ref('')
const selectedCourse = ref('')
const selectedType = ref('')
const viewMode = ref('table')
const selectedResources = ref([])
const showBulkActions = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const editingResource = ref(null)
const currentPage = ref(1)
const itemsPerPage = ref(20)

// Mock data
const courses = ref([
  { id: 'claude-code-training', title: 'Claude Code Training' },
  { id: 'django-mastery', title: 'Django Mastery' },
  { id: 'python-fundamentals', title: 'Python Fundamentals' }
])

const resources = ref([
  {
    id: '1',
    title: 'Claude Code Quick Reference',
    description: 'Essential commands and workflows for Python/Django developers',
    type: 'cheat-sheet',
    icon: '📋',
    courseId: 'claude-code-training',
    courseName: 'Claude Code Training',
    views: 3421,
    favorites: 543,
    status: 'published',
    tags: ['commands', 'shortcuts', 'reference'],
    createdAt: '2024-01-15',
    updatedAt: '2024-01-20'
  },
  {
    id: '2',
    title: 'Documentation & Resources',
    description: 'Official documentation and community resources',
    type: 'links',
    icon: '🔗',
    courseId: 'claude-code-training',
    courseName: 'Claude Code Training',
    views: 2876,
    favorites: 421,
    status: 'published',
    tags: ['documentation', 'external', 'resources'],
    createdAt: '2024-01-16',
    updatedAt: '2024-01-21'
  },
  {
    id: '3',
    title: 'Claude Code Glossary',
    description: 'Key terms and concepts explained',
    type: 'glossary',
    icon: '📚',
    courseId: 'claude-code-training',
    courseName: 'Claude Code Training',
    views: 2543,
    favorites: 387,
    status: 'draft',
    tags: ['glossary', 'terms', 'definitions'],
    createdAt: '2024-01-17',
    updatedAt: '2024-01-22'
  }
])

// Computed properties
const filteredResources = computed(() => {
  let filtered = resources.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(resource =>
      resource.title.toLowerCase().includes(query) ||
      resource.description.toLowerCase().includes(query) ||
      resource.tags.some(tag => tag.toLowerCase().includes(query))
    )
  }

  // Course filter
  if (selectedCourse.value) {
    filtered = filtered.filter(resource => resource.courseId === selectedCourse.value)
  }

  // Type filter
  if (selectedType.value) {
    filtered = filtered.filter(resource => resource.type === selectedType.value)
  }

  return filtered
})

const paginatedResources = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredResources.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredResources.value.length / itemsPerPage.value)
})

// Methods
const formatNumber = (num) => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  } else if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num.toString()
}

const getTypeColor = (type) => {
  const colors = {
    'cheat-sheet': 'bg-blue-100 text-blue-800',
    'links': 'bg-green-100 text-green-800',
    'glossary': 'bg-purple-100 text-purple-800',
    'downloads': 'bg-yellow-100 text-yellow-800',
    'videos': 'bg-red-100 text-red-800',
    'tools': 'bg-indigo-100 text-indigo-800'
  }
  return colors[type] || 'bg-gray-100 text-gray-800'
}

const toggleSelectAll = () => {
  if (selectedResources.value.length === filteredResources.value.length) {
    selectedResources.value = []
  } else {
    selectedResources.value = filteredResources.value.map(r => r.id)
  }
}

const viewResource = (resource) => {
  // Open resource in modal or navigate to resource page
  console.log('View resource:', resource)
}

const editResource = (resource) => {
  editingResource.value = { ...resource }
  showEditModal.value = true
}

const duplicateResource = (resource) => {
  const duplicate = {
    ...resource,
    id: Date.now().toString(),
    title: `${resource.title} (Copy)`,
    status: 'draft'
  }
  resources.value.push(duplicate)
}

const deleteResource = (resource) => {
  if (confirm(`Are you sure you want to delete "${resource.title}"?`)) {
    const index = resources.value.findIndex(r => r.id === resource.id)
    if (index > -1) {
      resources.value.splice(index, 1)
    }
  }
}

const bulkArchive = () => {
  console.log('Bulk archive:', selectedResources.value)
  selectedResources.value = []
  showBulkActions.value = false
}

const bulkDelete = () => {
  if (confirm(`Are you sure you want to delete ${selectedResources.value.length} resources?`)) {
    resources.value = resources.value.filter(r => !selectedResources.value.includes(r.id))
    selectedResources.value = []
    showBulkActions.value = false
  }
}

const bulkExport = () => {
  console.log('Bulk export:', selectedResources.value)
  selectedResources.value = []
  showBulkActions.value = false
}

const closeModals = () => {
  showCreateModal.value = false
  showEditModal.value = false
  editingResource.value = null
}

const handleSaveResource = (resource) => {
  if (resource.id && showEditModal.value) {
    // Update existing resource
    const index = resources.value.findIndex(r => r.id === resource.id)
    if (index > -1) {
      resources.value[index] = { ...resource, updatedAt: new Date().toISOString().split('T')[0] }
    }
  } else {
    // Create new resource
    resources.value.push({
      ...resource,
      id: Date.now().toString(),
      views: 0,
      favorites: 0,
      createdAt: new Date().toISOString().split('T')[0],
      updatedAt: new Date().toISOString().split('T')[0]
    })
  }
  closeModals()
}

onMounted(() => {
  // Load initial data
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>