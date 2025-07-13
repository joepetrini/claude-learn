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
      class="bg-white rounded-xl shadow-2xl max-w-md w-full"
      @click.stop
    >
      <!-- Modal header -->
      <div class="flex items-center justify-between p-6 border-b border-gray-200">
        <h2 class="text-xl font-bold text-gray-900">
          {{ isEdit ? 'Edit Tag' : 'Create New Tag' }}
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
      <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
        <!-- Tag name -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Tag Name *
          </label>
          <input
            v-model="form.name"
            type="text"
            required
            placeholder="Enter tag name"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
          <p class="text-xs text-gray-500 mt-1">Use lowercase letters, numbers, and hyphens only</p>
        </div>

        <!-- Description -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Description
          </label>
          <textarea
            v-model="form.description"
            rows="3"
            placeholder="Brief description of what this tag represents"
            class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          ></textarea>
        </div>

        <!-- Category -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Category
          </label>
          <div class="space-y-2">
            <select
              v-model="form.category"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">Select category</option>
              <option v-for="category in categories" :key="category" :value="category">
                {{ formatCategoryName(category) }}
              </option>
              <option value="custom">Create new category...</option>
            </select>
            
            <!-- Custom category input -->
            <input
              v-if="form.category === 'custom'"
              v-model="customCategory"
              type="text"
              placeholder="Enter new category name"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>

        <!-- Color -->
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">
            Color
          </label>
          <div class="flex items-center space-x-3">
            <!-- Color input -->
            <input
              v-model="form.color"
              type="color"
              class="w-12 h-10 border border-gray-300 rounded-lg cursor-pointer"
            />
            
            <!-- Preset colors -->
            <div class="flex space-x-2">
              <button
                v-for="color in presetColors"
                :key="color"
                type="button"
                @click="form.color = color"
                :class="{ 'ring-2 ring-offset-2 ring-gray-400': form.color === color }"
                class="w-8 h-8 rounded-full border border-gray-300 hover:scale-110 transition-transform"
                :style="{ backgroundColor: color }"
              ></button>
            </div>
            
            <!-- Color preview -->
            <div class="flex items-center space-x-2 ml-auto">
              <span 
                class="inline-block w-6 h-6 rounded-full border border-gray-300"
                :style="{ backgroundColor: form.color }"
              ></span>
              <span class="text-sm text-gray-600">{{ form.color }}</span>
            </div>
          </div>
        </div>

        <!-- Tag preview -->
        <div class="p-3 bg-gray-50 rounded-lg">
          <p class="text-sm font-medium text-gray-700 mb-2">Preview:</p>
          <div class="flex items-center space-x-2">
            <span 
              class="inline-flex items-center px-3 py-1 text-sm rounded-full border"
              :style="{ 
                backgroundColor: form.color + '20', 
                borderColor: form.color,
                color: form.color 
              }"
            >
              <span 
                class="inline-block w-2 h-2 rounded-full mr-2"
                :style="{ backgroundColor: form.color }"
              ></span>
              {{ form.name || 'tag-name' }}
            </span>
            <span
              v-if="form.category && form.category !== 'custom'"
              class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full"
            >
              {{ formatCategoryName(form.category) }}
            </span>
          </div>
        </div>
      </form>

      <!-- Modal footer -->
      <div class="border-t border-gray-200 px-6 py-4">
        <div class="flex items-center justify-between">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
          >
            Cancel
          </button>
          <button
            @click="handleSubmit"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
          >
            {{ isEdit ? 'Update Tag' : 'Create Tag' }}
          </button>
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
  tag: {
    type: Object,
    default: null
  },
  categories: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const modalContent = ref(null)
const customCategory = ref('')

const isEdit = computed(() => !!props.tag?.id)

// Preset colors for quick selection
const presetColors = [
  '#3B82F6', '#10B981', '#F59E0B', '#EF4444', 
  '#8B5CF6', '#EC4899', '#06B6D4', '#84CC16'
]

// Form data
const form = ref({
  name: '',
  description: '',
  category: '',
  color: '#3B82F6'
})

// Initialize form when tag changes
watch(
  () => props.tag,
  (tag) => {
    if (tag) {
      form.value = {
        ...tag
      }
    } else {
      // Reset form for new tag
      form.value = {
        name: '',
        description: '',
        category: '',
        color: '#3B82F6'
      }
    }
    customCategory.value = ''
  },
  { immediate: true }
)

// Auto-format tag name
watch(
  () => form.value.name,
  (newName) => {
    if (newName) {
      // Convert to lowercase and replace spaces/special chars with hyphens
      form.value.name = newName
        .toLowerCase()
        .replace(/[^a-z0-9\s-]/g, '')
        .replace(/\s+/g, '-')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '')
    }
  }
)

// Methods
const formatCategoryName = (category) => {
  return category.split('-').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')
}

const handleBackdropClick = (event) => {
  if (event.target === event.currentTarget) {
    emit('close')
  }
}

const handleSubmit = () => {
  // Validate required fields
  if (!form.value.name.trim()) {
    alert('Please enter a tag name')
    return
  }

  // Check for duplicate tag names (in real app, this would be server-side validation)
  // For now, we'll assume the parent component handles this

  // Prepare tag data
  const tagData = {
    ...form.value,
    category: form.value.category === 'custom' ? 
      customCategory.value.toLowerCase().replace(/\s+/g, '-') : 
      form.value.category
  }

  emit('save', tagData)
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