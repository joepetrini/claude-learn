<template>
  <router-link 
    :to="`/category/${categorySlug}/course/${course.slug}`"
    class="block bg-white rounded-lg shadow-sm hover:shadow-lg hover:scale-[1.02] transition-all duration-200 p-6 group"
  >
    <!-- Course header -->
    <div class="flex items-start gap-4 mb-4">
      <div class="text-3xl">{{ course.icon }}</div>
      <div class="flex-1">
        <h3 class="text-lg font-semibold text-gray-900 mb-1">
          {{ course.title }}
        </h3>
        <p class="text-sm text-gray-600 line-clamp-2">
          {{ course.description }}
        </p>
      </div>
    </div>

    <!-- Course metadata -->
    <div class="flex flex-wrap gap-4 text-sm text-gray-500 mb-4">
      <div class="flex items-center gap-1">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
        </svg>
        <span>{{ course.moduleCount }} modules</span>
      </div>
      
      <div class="flex items-center gap-1">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>{{ course.estimatedDuration }}</span>
      </div>
      
      <div v-if="course.difficultyLevel" class="flex items-center gap-1">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3" />
        </svg>
        <span class="capitalize">{{ course.difficultyLevel }}</span>
      </div>
    </div>

    <!-- Tags -->
    <div v-if="course.tags && course.tags.length > 0" class="flex flex-wrap gap-2 mb-4">
      <span 
        v-for="tag in course.tags" 
        :key="tag"
        class="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full"
      >
        {{ tag }}
      </span>
    </div>

    <!-- Featured badge -->
    <div v-if="course.isFeatured" class="flex items-center gap-2 text-sm text-blue-600">
      <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
      <span class="font-medium">Featured Course</span>
    </div>

    <!-- Progress (if available) -->
    <div v-if="progress" class="mt-4">
      <div class="flex items-center justify-between text-sm text-gray-600 mb-2">
        <span>Progress</span>
        <span>{{ progress.completedModules }} / {{ progress.totalModules }} modules</span>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-2">
        <div 
          class="bg-blue-500 h-2 rounded-full transition-all duration-500"
          :style="`width: ${progress.percentage}%`"
        ></div>
      </div>
    </div>
  </router-link>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useSupabaseProgress } from '../composables/useSupabaseProgress.js'
import { useAuth } from '../composables/useAuth.js'

const props = defineProps({
  course: {
    type: Object,
    required: true
  },
  categorySlug: {
    type: String,
    required: true
  }
})

const { user } = useAuth()
const { getCourseProgress } = useSupabaseProgress()

// Local state for progress
const progress = ref(null)

// Load course progress if user is logged in
onMounted(async () => {
  if (user.value && props.course.slug) {
    const courseProgress = await getCourseProgress(props.course.slug)
    if (courseProgress) {
      progress.value = courseProgress
    }
  }
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