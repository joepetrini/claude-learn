<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold mb-6">Quiz for Module {{ moduleId }}</h1>
      <p class="text-gray-600">Quiz questions will be loaded here...</p>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const moduleId = computed(() => route.params.id)
</script>