<template>
  <div class="animate-pulse">
    <!-- Module Card Skeleton -->
    <div v-if="type === 'module-card'" class="bg-white rounded-lg shadow-md p-6">
      <div class="flex items-start gap-4">
        <div class="w-12 h-12 bg-gray-200 rounded-lg"></div>
        <div class="flex-1">
          <div class="h-6 bg-gray-200 rounded w-3/4 mb-2"></div>
          <div class="h-4 bg-gray-200 rounded w-full mb-4"></div>
          <div class="flex items-center gap-4">
            <div class="h-4 bg-gray-200 rounded w-24"></div>
            <div class="h-4 bg-gray-200 rounded w-20"></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Module Content Skeleton -->
    <div v-else-if="type === 'module-content'">
      <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <div class="flex items-start justify-between">
          <div>
            <div class="flex items-center gap-3 mb-2">
              <div class="w-10 h-10 bg-gray-200 rounded"></div>
              <div class="h-8 bg-gray-200 rounded w-64"></div>
            </div>
            <div class="h-4 bg-gray-200 rounded w-96"></div>
          </div>
          <div class="h-4 bg-gray-200 rounded w-20"></div>
        </div>
        <div class="mt-6">
          <div class="h-2 bg-gray-200 rounded-full w-full"></div>
        </div>
      </div>
      <div class="bg-white rounded-lg shadow-md p-8">
        <div class="h-6 bg-gray-200 rounded w-48 mb-4"></div>
        <div class="space-y-3">
          <div class="h-4 bg-gray-200 rounded w-full"></div>
          <div class="h-4 bg-gray-200 rounded w-5/6"></div>
          <div class="h-4 bg-gray-200 rounded w-4/5"></div>
        </div>
      </div>
    </div>

    <!-- Quiz Skeleton -->
    <div v-else-if="type === 'quiz'" class="max-w-3xl mx-auto">
      <div class="bg-white rounded-lg shadow-md p-6 mb-6">
        <div class="h-6 bg-gray-200 rounded w-64 mb-2"></div>
        <div class="flex justify-between items-center">
          <div class="h-4 bg-gray-200 rounded w-32"></div>
          <div class="h-4 bg-gray-200 rounded w-24"></div>
        </div>
        <div class="mt-4">
          <div class="h-2 bg-gray-200 rounded-full w-full"></div>
        </div>
      </div>
      <div class="bg-white rounded-lg shadow-md p-8">
        <div class="h-6 bg-gray-200 rounded w-full mb-6"></div>
        <div class="space-y-3">
          <div class="h-12 bg-gray-200 rounded-lg w-full"></div>
          <div class="h-12 bg-gray-200 rounded-lg w-full"></div>
          <div class="h-12 bg-gray-200 rounded-lg w-full"></div>
          <div class="h-12 bg-gray-200 rounded-lg w-full"></div>
        </div>
      </div>
    </div>

    <!-- Text Lines Skeleton -->
    <div v-else-if="type === 'text'" class="space-y-3">
      <div class="h-4 bg-gray-200 rounded w-full"></div>
      <div class="h-4 bg-gray-200 rounded w-5/6"></div>
      <div class="h-4 bg-gray-200 rounded w-4/5"></div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  type: {
    type: String,
    default: 'text',
    validator: (value) => ['module-card', 'module-content', 'quiz', 'text'].includes(value)
  }
})
</script>