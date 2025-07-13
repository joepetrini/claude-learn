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
      class="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden"
      @click.stop
    >
      <!-- Modal header -->
      <div class="flex items-center justify-between p-6 border-b border-gray-200">
        <h2 class="text-xl font-bold text-gray-900">
          {{ isEdit ? 'Edit Resource' : 'Create New Resource' }}
        </h2>
        <button
          @click="$emit('close')"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors text-gray-400 hover:text-gray-600"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Modal body -->
      <div class="overflow-y-auto max-h-[calc(90vh-140px)]">
        <form @submit.prevent="handleSubmit" class="p-6 space-y-6">
          <!-- Basic Information -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Title -->
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Title *
              </label>
              <input
                v-model="form.title"
                type="text"
                required
                placeholder="Enter resource title"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>

            <!-- Course -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Course *
              </label>
              <select
                v-model="form.courseId"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">Select a course</option>
                <option v-for="course in courses" :key="course.id" :value="course.id">
                  {{ course.title }}
                </option>
              </select>
            </div>

            <!-- Type -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Type *
              </label>
              <select
                v-model="form.type"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="">Select type</option>
                <option value="cheat-sheet">Cheat Sheet</option>
                <option value="links">Links</option>
                <option value="glossary">Glossary</option>
                <option value="downloads">Downloads</option>
                <option value="videos">Videos</option>
                <option value="tools">Tools</option>
                <option value="faq">FAQ</option>
                <option value="exercises">Exercises</option>
              </select>
            </div>

            <!-- Icon -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Icon
              </label>
              <div class="flex items-center space-x-3">
                <input
                  v-model="form.icon"
                  type="text"
                  placeholder="📋"
                  class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
                <div class="w-10 h-10 border border-gray-300 rounded-lg flex items-center justify-center text-xl">
                  {{ form.icon || '📄' }}
                </div>
              </div>
              <p class="text-xs text-gray-500 mt-1">Use an emoji or Unicode character</p>
            </div>

            <!-- Status -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                v-model="form.status"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                <option value="draft">Draft</option>
                <option value="published">Published</option>
                <option value="archived">Archived</option>
              </select>
            </div>
          </div>

          <!-- Description -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Description *
            </label>
            <textarea
              v-model="form.description"
              required
              rows="3"
              placeholder="Enter a brief description of this resource"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            ></textarea>
          </div>

          <!-- Tags -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Tags
            </label>
            <div class="space-y-2">
              <!-- Tag input -->
              <div class="flex items-center space-x-2">
                <input
                  v-model="newTag"
                  type="text"
                  placeholder="Add a tag and press Enter"
                  @keyup.enter="addTag"
                  class="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
                <button
                  type="button"
                  @click="addTag"
                  class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Add
                </button>
              </div>
              
              <!-- Current tags -->
              <div v-if="form.tags.length > 0" class="flex flex-wrap gap-2">
                <span
                  v-for="(tag, index) in form.tags"
                  :key="index"
                  class="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full"
                >
                  {{ tag }}
                  <button
                    type="button"
                    @click="removeTag(index)"
                    class="ml-2 text-blue-600 hover:text-blue-800"
                  >
                    <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                    </svg>
                  </button>
                </span>
              </div>
            </div>
          </div>

          <!-- Resource Path/URL -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Resource Path
            </label>
            <input
              v-model="form.path"
              type="text"
              placeholder="resources/example.json"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
            <p class="text-xs text-gray-500 mt-1">
              Path to the resource file relative to the course data directory
            </p>
          </div>

          <!-- Featured -->
          <div class="flex items-center">
            <input
              v-model="form.featured"
              type="checkbox"
              id="featured"
              class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
            />
            <label for="featured" class="ml-2 text-sm text-gray-700">
              Feature this resource
            </label>
          </div>

          <!-- Content Editor (for JSON-based resources) -->
          <div v-if="showContentEditor">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              Content (JSON)
            </label>
            <textarea
              v-model="form.content"
              rows="10"
              placeholder="Enter the JSON content for this resource"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 font-mono text-sm"
            ></textarea>
            <div class="flex items-center justify-between mt-2">
              <p class="text-xs text-gray-500">
                Enter valid JSON content. Use the preview to validate structure.
              </p>
              <div class="flex items-center space-x-2">
                <button
                  type="button"
                  @click="formatJSON"
                  class="text-sm text-blue-600 hover:text-blue-800"
                >
                  Format JSON
                </button>
                <button
                  type="button"
                  @click="validateJSON"
                  class="text-sm text-green-600 hover:text-green-800"
                >
                  Validate
                </button>
              </div>
            </div>
            <div v-if="jsonError" class="mt-2 p-3 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-600">{{ jsonError }}</p>
            </div>
          </div>

          <!-- Preview Toggle -->
          <div class="flex items-center justify-between pt-4 border-t border-gray-200">
            <button
              type="button"
              @click="showContentEditor = !showContentEditor"
              class="text-sm text-blue-600 hover:text-blue-800"
            >
              {{ showContentEditor ? 'Hide' : 'Show' }} Content Editor
            </button>
            <div class="flex items-center space-x-4">
              <span class="text-sm text-gray-600">
                {{ isEdit ? 'Last updated' : 'Will be created' }}: {{ new Date().toLocaleDateString() }}
              </span>
            </div>
          </div>
        </form>
      </div>

      <!-- Modal footer -->
      <div class="border-t border-gray-200 px-6 py-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center space-x-4">
            <button
              type="button"
              @click="$emit('close')"
              class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Cancel
            </button>
            <button
              v-if="isEdit"
              type="button"
              @click="handleDuplicate"
              class="px-4 py-2 border border-blue-300 text-blue-600 rounded-lg text-sm font-medium hover:bg-blue-50 transition-colors"
            >
              Save as Copy
            </button>
          </div>
          <div class="flex items-center space-x-2">
            <button
              type="button"
              @click="handleSaveDraft"
              class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
            >
              Save as Draft
            </button>
            <button
              type="button"
              @click="handleSubmit"
              class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
            >
              {{ isEdit ? 'Update Resource' : 'Create Resource' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  },
  resource: {
    type: Object,
    default: null
  },
  courses: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const modalContent = ref(null)
const newTag = ref('')
const showContentEditor = ref(false)
const jsonError = ref('')

const isEdit = computed(() => !!props.resource?.id)

// Form data
const form = ref({
  title: '',
  description: '',
  type: '',
  icon: '',
  courseId: '',
  status: 'draft',
  tags: [],
  path: '',
  featured: false,
  content: ''
})

// Initialize form when resource changes
watch(
  () => props.resource,
  (resource) => {
    if (resource) {
      form.value = {
        ...resource,
        tags: resource.tags ? [...resource.tags] : [],
        content: resource.content || ''
      }
    } else {
      // Reset form for new resource
      form.value = {
        title: '',
        description: '',
        type: '',
        icon: '',
        courseId: '',
        status: 'draft',
        tags: [],
        path: '',
        featured: false,
        content: ''
      }
    }
    jsonError.value = ''
  },
  { immediate: true }
)

// Auto-generate path based on type and title
watch(
  [() => form.value.type, () => form.value.title],
  ([type, title]) => {
    if (type && title && !form.value.path) {
      const fileName = title.toLowerCase()
        .replace(/[^a-z0-9\s]/g, '')
        .replace(/\s+/g, '-')
      form.value.path = `resources/${fileName}.json`
    }
  }
)

// Methods
const addTag = () => {
  const tag = newTag.value.trim().toLowerCase()
  if (tag && !form.value.tags.includes(tag)) {
    form.value.tags.push(tag)
    newTag.value = ''
  }
}

const removeTag = (index) => {
  form.value.tags.splice(index, 1)
}

const formatJSON = () => {
  try {
    if (form.value.content.trim()) {
      const parsed = JSON.parse(form.value.content)
      form.value.content = JSON.stringify(parsed, null, 2)
      jsonError.value = ''
    }
  } catch (error) {
    jsonError.value = `Invalid JSON: ${error.message}`
  }
}

const validateJSON = () => {
  try {
    if (form.value.content.trim()) {
      JSON.parse(form.value.content)
      jsonError.value = ''
      alert('JSON is valid!')
    } else {
      jsonError.value = 'Content is empty'
    }
  } catch (error) {
    jsonError.value = `Invalid JSON: ${error.message}`
  }
}

const handleBackdropClick = (event) => {
  if (event.target === event.currentTarget) {
    emit('close')
  }
}

const handleSubmit = () => {
  // Validate required fields
  if (!form.value.title || !form.value.description || !form.value.type || !form.value.courseId) {
    alert('Please fill in all required fields')
    return
  }

  // Validate JSON content if provided
  if (form.value.content.trim()) {
    try {
      JSON.parse(form.value.content)
    } catch (error) {
      jsonError.value = `Invalid JSON: ${error.message}`
      return
    }
  }

  // Set status to published when saving normally
  const resourceData = {
    ...form.value,
    status: 'published'
  }

  emit('save', resourceData)
}

const handleSaveDraft = () => {
  // Validate required fields
  if (!form.value.title || !form.value.description || !form.value.type || !form.value.courseId) {
    alert('Please fill in all required fields')
    return
  }

  const resourceData = {
    ...form.value,
    status: 'draft'
  }

  emit('save', resourceData)
}

const handleDuplicate = () => {
  const resourceData = {
    ...form.value,
    id: null, // Remove ID to create new resource
    title: `${form.value.title} (Copy)`,
    status: 'draft'
  }

  emit('save', resourceData)
}

// Lifecycle
onMounted(() => {
  // Focus first input when modal opens
  if (props.isOpen) {
    setTimeout(() => {
      const firstInput = modalContent.value?.querySelector('input[type="text"]')
      firstInput?.focus()
    }, 100)
  }
})
</script>