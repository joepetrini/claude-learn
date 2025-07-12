<template>
  <router-link 
    :to="`/category/${categorySlug}/course/${courseSlug}/module/${module.id}`"
    class="block bg-white rounded-lg shadow-sm hover:shadow-lg hover:scale-[1.01] transition-all duration-200 p-6 relative animate-fade-in"
    :class="{ 'ring-2 ring-blue-500': isCompleted }"
  >
    <!-- Completion badge -->
    <div v-if="isCompleted" class="absolute top-4 right-4">
      <div class="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium flex items-center gap-1">
        <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
        </svg>
        Completed
      </div>
    </div>

    <!-- Module content -->
    <div class="flex items-start gap-4">
      <div class="flex-shrink-0 w-10 h-10 bg-blue-100 text-blue-600 rounded-lg flex items-center justify-center font-semibold">
        {{ index + 1 }}
      </div>
      <div class="flex-1">
        <h3 class="text-lg font-semibold text-gray-900 mb-2">
          {{ module.title }}
        </h3>
        <p class="text-sm text-gray-600 mb-3 line-clamp-2">
          {{ module.description }}
        </p>
        
        <!-- Module metadata -->
        <div class="flex items-center gap-4 text-xs text-gray-500">
          <div class="flex items-center gap-1">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{{ module.estimatedTime }}</span>
          </div>
          
          <div v-if="module.objectives" class="flex items-center gap-1">
            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>{{ module.objectives.length }} objectives</span>
          </div>
        </div>

        <!-- Progress indicator -->
        <div v-if="progress && !isCompleted" class="mt-3">
          <div class="flex items-center justify-between text-xs text-gray-600 mb-1">
            <span>Progress</span>
            <span>{{ Math.round((progress.current_section / module.sections.length) * 100) }}%</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-1.5">
            <div 
              class="bg-blue-500 h-1.5 rounded-full transition-all duration-500"
              :style="`width: ${(progress.current_section / module.sections.length) * 100}%`"
            ></div>
          </div>
        </div>
      </div>
    </div>
  </router-link>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  module: {
    type: Object,
    required: true
  },
  index: {
    type: Number,
    required: true
  },
  progress: {
    type: Object,
    default: null
  },
  categorySlug: {
    type: String,
    required: true
  },
  courseSlug: {
    type: String,
    required: true
  }
})

// Check if module is completed
const isCompleted = computed(() => {
  return props.progress?.completed === true
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