<template>
  <!-- Modal backdrop -->
  <div
    v-if="isOpen"
    class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50"
    @click="handleBackdropClick"
  >
    <!-- Modal content -->
    <div
      ref="modalContent"
      class="bg-white rounded-xl shadow-2xl max-w-6xl w-full max-h-[90vh] overflow-hidden"
      @click.stop
    >
      <!-- Modal header -->
      <div class="flex items-center justify-between p-6 border-b border-gray-200 bg-gray-50">
        <div class="flex items-center space-x-3">
          <span class="text-2xl">{{ resource?.icon }}</span>
          <div>
            <h2 class="text-xl font-bold text-gray-900">{{ resource?.title }}</h2>
            <p class="text-sm text-gray-500 capitalize">{{ resource?.type?.replace('-', ' ') }}</p>
          </div>
        </div>
        
        <div class="flex items-center space-x-2">
          <!-- Favorite button -->
          <button
            @click="handleToggleFavorite"
            class="p-2 rounded-full hover:bg-gray-200 transition-colors"
            :class="{ 'text-yellow-500': resource?.isFavorited, 'text-gray-400': !resource?.isFavorited }"
          >
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
          </button>
          
          <!-- Close button -->
          <button
            @click="$emit('close')"
            class="p-2 rounded-full hover:bg-gray-200 transition-colors text-gray-400 hover:text-gray-600"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>

      <!-- Modal body -->
      <div class="overflow-y-auto max-h-[calc(90vh-120px)]">
        <div class="p-6">
          <!-- Loading state -->
          <div v-if="loading" class="flex items-center justify-center py-12">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>

          <!-- Error state -->
          <div v-else-if="error" class="text-center py-12">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4">
              <svg class="w-8 h-8 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Failed to Load Resource</h3>
            <p class="text-gray-600 mb-4">{{ error }}</p>
            <button
              @click="loadContent"
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Try Again
            </button>
          </div>

          <!-- Resource content -->
          <div v-else-if="content">
            <!-- Cheat Sheet Viewer -->
            <CheatSheetViewer
              v-if="resource?.type === 'cheat-sheet'"
              :content="content"
            />

            <!-- Links Viewer -->
            <LinksViewer
              v-else-if="resource?.type === 'links'"
              :content="content"
            />

            <!-- Glossary Viewer -->
            <GlossaryViewer
              v-else-if="resource?.type === 'glossary'"
              :content="content"
            />

            <!-- Generic viewer for other types -->
            <div v-else class="space-y-4">
              <h1 class="text-2xl font-bold text-gray-900">{{ content.title || resource.title }}</h1>
              <p class="text-gray-600">{{ content.description || resource.description }}</p>
              
              <!-- Display content based on structure -->
              <div v-if="content.sections" class="space-y-6">
                <div
                  v-for="section in content.sections"
                  :key="section.title"
                  class="bg-gray-50 rounded-lg p-6"
                >
                  <h2 class="text-xl font-semibold mb-4">{{ section.title }}</h2>
                  
                  <!-- Items list -->
                  <div v-if="section.items" class="space-y-2">
                    <div
                      v-for="item in section.items"
                      :key="item.title || item.name"
                      class="border-l-4 border-blue-500 pl-4"
                    >
                      <h3 class="font-medium">{{ item.title || item.name }}</h3>
                      <p class="text-gray-600 text-sm">{{ item.description || item.content }}</p>
                    </div>
                  </div>
                  
                  <!-- Raw content -->
                  <div v-else-if="section.content" class="prose max-w-none">
                    <p>{{ section.content }}</p>
                  </div>
                </div>
              </div>
              
              <!-- Fallback: display as JSON (for debugging) -->
              <div v-else class="bg-gray-100 rounded-lg p-4">
                <pre class="text-sm text-gray-800 whitespace-pre-wrap">{{ JSON.stringify(content, null, 2) }}</pre>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal footer -->
      <div class="border-t border-gray-200 bg-gray-50 px-6 py-4">
        <div class="flex items-center justify-between text-sm text-gray-500">
          <div class="flex items-center space-x-4">
            <span v-if="resource?.tags?.length" class="flex items-center space-x-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
              </svg>
              <span>{{ resource.tags.slice(0, 3).join(', ') }}</span>
              <span v-if="resource.tags.length > 3">+{{ resource.tags.length - 3 }}</span>
            </span>
            
            <span v-if="resource?.viewCount" class="flex items-center space-x-1">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
              </svg>
              <span>{{ resource.viewCount }} views</span>
            </span>
          </div>
          
          <div class="flex items-center space-x-4">
            <span>ESC to close</span>
            <span>{{ formatDate(content?.lastUpdated) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import CheatSheetViewer from './viewers/CheatSheetViewer.vue'
import LinksViewer from './viewers/LinksViewer.vue'
import GlossaryViewer from './viewers/GlossaryViewer.vue'

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  },
  resource: {
    type: Object,
    default: null
  },
  courseId: {
    type: String,
    required: true
  }
})


const emit = defineEmits(['close', 'toggle-favorite'])

const modalContent = ref(null)
const content = ref(null)
const loading = ref(false)
const error = ref(null)

// Load resource content when resource changes
watch(
  () => props.resource,
  async (newResource) => {
    if (newResource && props.isOpen) {
      await loadContent()
    }
  },
  { immediate: true }
)

// Load content when modal opens
watch(
  () => props.isOpen,
  async (isOpen) => {
    if (isOpen && props.resource) {
      await loadContent()
    } else {
      // Clear content when modal closes
      content.value = null
      error.value = null
    }
  }
)

// Load resource content
const loadContent = async () => {
  if (!props.resource?.path) return


  loading.value = true
  error.value = null

  try {
    const response = await fetch(`${import.meta.env.BASE_URL}data/software-dev/${props.courseId}/${props.resource.path}`)
    
    if (!response.ok) {
      throw new Error(`Failed to load resource: ${response.status} ${response.statusText}`)
    }

    const jsonContent = await response.json()
    content.value = jsonContent
  } catch (err) {
    error.value = err.message
    console.error('Error loading resource content:', err)
  } finally {
    loading.value = false
  }
}

// Handle backdrop click
const handleBackdropClick = (event) => {
  if (event.target === event.currentTarget) {
    emit('close')
  }
}

// Handle toggle favorite
const handleToggleFavorite = () => {
  emit('toggle-favorite', props.resource)
}

// Handle escape key
const handleEscape = (event) => {
  if (event.key === 'Escape' && props.isOpen) {
    emit('close')
  }
}

// Format date
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}

// Lifecycle
onMounted(() => {
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleEscape)
})

// Prevent body scroll when modal is open
watch(
  () => props.isOpen,
  (isOpen) => {
    if (isOpen) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
  }
)
</script>