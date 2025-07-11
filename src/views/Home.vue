<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <header class="text-center mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">
          Learn Claude Code
        </h1>
        <p class="text-xl text-gray-600 max-w-2xl mx-auto">
          Master the powerful AI coding assistant with interactive modules designed for Python/Django developers
        </p>
      </header>

      <div class="max-w-6xl mx-auto">
        <h2 class="text-2xl font-semibold mb-6">Core Learning Path</h2>
        <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <SkeletonLoader v-for="i in 6" :key="i" type="module-card" />
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <router-link
            v-for="module in modules"
            :key="module.id"
            :to="`/module/${module.id}`"
            class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow relative"
          >
            <!-- Progress indicator -->
            <div v-if="isModuleStarted(module.id)" class="absolute top-4 right-4">
              <div v-if="isModuleCompleted(module.id)" class="text-green-500">
                <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
              </div>
              <div v-else class="text-blue-500">
                <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
                </svg>
              </div>
            </div>
            
            <div class="text-4xl mb-4">{{ module.icon }}</div>
            <h3 class="text-lg font-semibold mb-2">{{ module.title }}</h3>
            <p class="text-sm text-gray-600 mb-4">{{ module.description }}</p>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-500">{{ module.estimatedTime }}</span>
              <span v-if="isModuleCompleted(module.id)" class="text-green-600 font-medium">
                Review →
              </span>
              <span v-else-if="isModuleStarted(module.id)" class="text-blue-600 font-medium">
                Continue →
              </span>
              <span v-else class="text-blue-600 font-medium">
                Start →
              </span>
            </div>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import SkeletonLoader from '../components/SkeletonLoader.vue'

const modules = ref([])
const loading = ref(true)
const progress = ref({})

const isModuleStarted = (moduleId) => {
  return progress.value.startedModules?.includes(moduleId) || false
}

const isModuleCompleted = (moduleId) => {
  return progress.value.completedModules?.includes(moduleId) || false
}

onMounted(async () => {
  // Load progress from localStorage
  progress.value = JSON.parse(localStorage.getItem('claudeLearnProgress') || '{}')
  
  try {
    const startTime = Date.now()
    const response = await fetch(import.meta.env.BASE_URL + 'data/modules.json')
    const data = await response.json()
    
    // Ensure minimum loading time of 500ms for better UX
    const loadTime = Date.now() - startTime
    if (loadTime < 500) {
      await new Promise(resolve => setTimeout(resolve, 500 - loadTime))
    }
    
    modules.value = data.modules
  } catch (error) {
    console.error('Failed to load modules:', error)
  } finally {
    loading.value = false
  }
})
</script>