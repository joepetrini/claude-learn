<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <!-- Breadcrumb Bar -->
    <div class="bg-white shadow-sm border-b">
      <div class="container mx-auto px-4 py-4">
        <div class="text-sm">
          <router-link to="/" class="text-blue-600 hover:text-blue-800">
            Categories
          </router-link>
          <span class="mx-2 text-gray-500">/</span>
          <router-link 
            :to="`/category/${categorySlug}`" 
            class="text-blue-600 hover:text-blue-800"
          >
            {{ categoryName }}
          </router-link>
          <span class="mx-2 text-gray-500">/</span>
          <router-link 
            :to="`/category/${categorySlug}/course/${courseSlug}`" 
            class="text-blue-600 hover:text-blue-800"
          >
            {{ courseName }}
          </router-link>
          <span class="mx-2 text-gray-500">/</span>
          <span class="text-gray-700">{{ module?.title || 'Module' }}</span>
        </div>
      </div>
    </div>

    <div class="container mx-auto px-4 py-8">
      <LoadingSkeletons v-if="loading" type="module-content" />
      
      <div v-else-if="module" class="max-w-4xl mx-auto">
        <!-- Module Header -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-6">
          <div class="flex items-start justify-between">
            <div>
              <h1 class="text-3xl font-bold mb-2 flex items-center gap-3">
                <span class="text-4xl">{{ module.icon }}</span>
                {{ module.title }}
              </h1>
              <p class="text-gray-600">{{ module.description }}</p>
            </div>
            <div class="text-sm text-gray-500">
              {{ module.estimatedTime }}
            </div>
          </div>
          
          <!-- Progress Bar -->
          <div class="mt-6">
            <div class="flex justify-between text-sm text-gray-600 mb-2">
              <span>Section {{ currentSectionIndex + 1 }} of {{ module.sections.length }}</span>
              <span>{{ progressPercentage }}% complete</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div 
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                :style="`width: ${progressPercentage}%`"
              ></div>
            </div>
          </div>
        </div>
        
        <!-- Module Content -->
        <div class="bg-white rounded-lg shadow-md p-8">
          <h2 class="text-2xl font-semibold mb-4">
            {{ currentSection.title }}
          </h2>
          
          <div class="prose prose-lg max-w-none" v-html="currentSection.content"></div>
          
          <!-- Code Example -->
          <div v-if="currentSection.example" class="mt-6">
            <h3 class="text-lg font-semibold mb-3 text-gray-800">Example:</h3>
            <pre class="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto"><code>{{ currentSection.example }}</code></pre>
          </div>
          
          <!-- Navigation Buttons -->
          <div class="flex justify-between items-center mt-12 pt-6 border-t">
            <button
              @click="previousSection"
              :disabled="currentSectionIndex === 0"
              class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              ← Previous
            </button>
            
            <span class="text-sm text-gray-500">
              {{ currentSectionIndex + 1 }} / {{ module.sections.length }}
            </span>
            
            <button
              v-if="currentSectionIndex < module.sections.length - 1"
              @click="nextSection"
              class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Next →
            </button>
            
            <router-link
              v-else
              :to="`/category/${categorySlug}/course/${courseSlug}/quiz/${moduleId}`"
              class="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors inline-block"
            >
              Take Quiz →
            </router-link>
          </div>
        </div>
      </div>
      
      <div v-else class="text-center py-12">
        <p class="text-red-600">Module not found</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useModuleKeyboard } from '../composables/useKeyboardNavigation.js'
import { useSupabaseProgress } from '../composables/useSupabaseProgress.js'
import { useModules } from '../composables/useModules.js'
import { useCategories } from '../composables/useCategories.js'
import Navigation from '../components/Navigation.vue'
import LoadingSkeletons from '../components/LoadingSkeletons.vue'

const route = useRoute()
const categorySlug = computed(() => route.params.categorySlug)
const courseSlug = computed(() => route.params.courseSlug)
const moduleId = computed(() => route.params.moduleId)

const module = ref(null)
const loading = ref(true)
const currentSectionIndex = ref(0)
const categoryName = ref('')
const courseName = ref('')

// Initialize composables
const { markModuleStarted, getModuleProgress, updateModuleProgress, loadProgress } = useSupabaseProgress()
const { loadModule } = useModules()
const { getCategoryBySlug, loadCategoryCourses } = useCategories()

const currentSection = computed(() => {
  return module.value?.sections[currentSectionIndex.value] || {}
})

const progressPercentage = computed(() => {
  if (!module.value) return 0
  return Math.round(((currentSectionIndex.value + 1) / module.value.sections.length) * 100)
})

const loadModuleData = async () => {
  loading.value = true
  try {
    // Load progress first to ensure we have latest data
    await loadProgress()
    
    // Get category and course info
    const category = getCategoryBySlug(categorySlug.value)
    if (category) {
      categoryName.value = category.name
      const courses = await loadCategoryCourses(categorySlug.value)
      const course = courses.find(c => c.slug === courseSlug.value)
      if (course) {
        courseName.value = course.title
      }
    }
    
    // Load module with new path structure
    const coursePath = `${categorySlug.value}/${courseSlug.value}`
    const moduleData = await loadModule(coursePath, moduleId.value)
    module.value = moduleData
    
    // Load saved progress from Supabase composable
    const savedProgress = getModuleProgress(moduleId.value)
    if (savedProgress && savedProgress.section) {
      currentSectionIndex.value = savedProgress.section
    }
  } catch (error) {
    console.error('Failed to load module:', error)
  } finally {
    loading.value = false
  }
}

const nextSection = () => {
  if (currentSectionIndex.value < module.value.sections.length - 1) {
    currentSectionIndex.value++
    window.scrollTo(0, 0)
  }
}

const previousSection = () => {
  if (currentSectionIndex.value > 0) {
    currentSectionIndex.value--
    window.scrollTo(0, 0)
  }
}

// Save progress whenever section changes
watch(currentSectionIndex, (newIndex) => {
  updateModuleProgress(moduleId.value, newIndex)
})

// Initialize module keyboard navigation
useModuleKeyboard()

// Mark module as started
onMounted(async () => {
  await loadModuleData()
  
  // Use Supabase progress composable to mark module as started
  await markModuleStarted(moduleId.value)
  
  // Listen for keyboard navigation events
  window.addEventListener('keyboard-next', nextSection)
  window.addEventListener('keyboard-previous', previousSection)
})

// Clean up event listeners
onUnmounted(() => {
  window.removeEventListener('keyboard-next', nextSection)
  window.removeEventListener('keyboard-previous', previousSection)
})
</script>

<style scoped>
.prose h3 {
  @apply text-lg font-semibold mb-3 text-gray-800;
}

.prose ul {
  @apply list-disc list-inside space-y-2;
}

.prose p {
  @apply mb-4;
}

pre {
  white-space: pre-wrap;
  word-wrap: break-word;
}
</style>