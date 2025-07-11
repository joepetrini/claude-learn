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
        <div v-if="loading" class="text-center py-12">
          <p class="text-gray-500">Loading modules...</p>
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <router-link
            v-for="module in modules"
            :key="module.id"
            :to="`/module/${module.id}`"
            class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow"
          >
            <div class="text-4xl mb-4">{{ module.icon }}</div>
            <h3 class="text-lg font-semibold mb-2">{{ module.title }}</h3>
            <p class="text-sm text-gray-600 mb-4">{{ module.description }}</p>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-500">{{ module.estimatedTime }}</span>
              <span class="text-blue-600 font-medium">Start →</span>
            </div>
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const modules = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const response = await fetch(import.meta.env.BASE_URL + 'data/modules.json')
    const data = await response.json()
    modules.value = data.modules
  } catch (error) {
    console.error('Failed to load modules:', error)
  } finally {
    loading.value = false
  }
})
</script>