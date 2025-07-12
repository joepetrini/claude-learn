<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    <div class="container mx-auto px-4 py-8">
      <!-- Breadcrumbs -->
      <div class="mb-4 text-sm">
        <router-link to="/" class="text-blue-600 hover:text-blue-800">
          Categories
        </router-link>
        <span class="mx-2 text-gray-500">/</span>
        <router-link 
          :to="`/category/${categorySlug}`" 
          class="text-blue-600 hover:text-blue-800"
        >
          {{ category?.name || categorySlug }}
        </router-link>
        <span class="mx-2 text-gray-500">/</span>
        <span class="text-gray-700">{{ course?.title || 'Course' }}</span>
      </div>

      <!-- Course Header -->
      <div v-if="course" class="bg-white rounded-lg shadow-sm p-6 mb-8">
        <div class="flex items-start gap-4">
          <div class="text-4xl">{{ course.icon }}</div>
          <div class="flex-1">
            <h1 class="text-3xl font-bold text-gray-900 mb-2">
              {{ course.title }}
            </h1>
            <p class="text-lg text-gray-600 mb-4">
              {{ course.description }}
            </p>
            
            <!-- Course metadata -->
            <div class="flex flex-wrap gap-4 text-sm text-gray-500">
              <div class="flex items-center gap-1">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                </svg>
                <span>{{ modules.length }} modules</span>
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
          </div>
        </div>

        <!-- Overall Progress -->
        <div v-if="overallProgress" class="mt-6">
          <div class="flex items-center justify-between text-sm text-gray-600 mb-2">
            <span class="font-medium">Course Progress</span>
            <span>{{ overallProgress.completed }} / {{ overallProgress.total }} modules completed</span>
          </div>
          <div class="w-full bg-gray-200 rounded-full h-3">
            <div 
              class="bg-gradient-to-r from-blue-500 to-blue-600 h-3 rounded-full transition-all duration-500"
              :style="`width: ${overallProgress.percentage}%`"
            ></div>
          </div>
        </div>
      </div>

      <!-- Modules Grid -->
      <div v-if="!isLoading && modules.length > 0">
        <h2 class="text-2xl font-semibold mb-6">Course Modules</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ModuleCard
            v-for="(module, index) in modules"
            :key="module.id"
            :module="module"
            :index="index"
            :progress="progress[module.id]"
            :category-slug="categorySlug"
            :course-slug="courseSlug"
          />
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="!isLoading && modules.length === 0" class="text-center py-12">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
          <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">No Modules Available</h3>
        <p class="text-gray-600">This course doesn't have any modules yet.</p>
      </div>

      <!-- Loading State -->
      <LoadingSkeletons v-if="isLoading" type="module-cards" :count="6" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useModules } from '../composables/useModules.js'
import { useSupabaseProgress } from '../composables/useSupabaseProgress.js'
import { useCategories } from '../composables/useCategories.js'
import Navigation from '../components/Navigation.vue'
import ModuleCard from '../components/ModuleCard.vue'
import LoadingSkeletons from '../components/LoadingSkeletons.vue'

const route = useRoute()
const { modules, loadModules } = useModules()
const { progress, overallProgress, loadProgress } = useSupabaseProgress()
const { getCategoryBySlug, loadCategoryCourses } = useCategories()

// Route params
const categorySlug = computed(() => route.params.categorySlug)
const courseSlug = computed(() => route.params.courseSlug)

// Local state
const category = ref(null)
const course = ref(null)
const isLoading = ref(true)

// Load course and modules
onMounted(async () => {
  isLoading.value = true
  
  // Get category
  category.value = getCategoryBySlug(categorySlug.value)
  
  // Load courses and find current course
  if (category.value) {
    const courses = await loadCategoryCourses(categorySlug.value)
    course.value = courses.find(c => c.slug === courseSlug.value)
  }
  
  // Load modules and progress with new path structure
  await Promise.all([
    loadModules(`${categorySlug.value}/${courseSlug.value}`),
    loadProgress()
  ])
  
  isLoading.value = false
})
</script>