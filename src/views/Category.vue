<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    <div class="container mx-auto px-4 py-8">
      <!-- Category Header -->
      <div v-if="category" class="mb-8">
        <router-link to="/" class="text-blue-600 hover:text-blue-800 mb-4 inline-flex items-center gap-2">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back to Categories
        </router-link>
        
        <div class="bg-white rounded-lg shadow-sm p-6">
          <div class="flex items-start gap-4">
            <div 
              class="w-16 h-16 rounded-lg flex items-center justify-center text-3xl"
              :style="{ backgroundColor: category.color + '20' }"
            >
              {{ category.icon }}
            </div>
            <div class="flex-1">
              <h1 class="text-3xl font-bold text-gray-900 mb-2">
                {{ category.name }}
              </h1>
              <p class="text-lg text-gray-600">
                {{ category.description }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Courses Grid -->
      <div v-if="!isLoading && courses.length > 0">
        <h2 class="text-2xl font-semibold mb-6">Available Courses</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <CourseCard
            v-for="course in courses"
            :key="course.slug"
            :course="course"
            :category-slug="categorySlug"
          />
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="!isLoading && courses.length === 0" class="text-center py-12">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
          <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">No Courses Available</h3>
        <p class="text-gray-600">Check back soon for new training courses in this category.</p>
      </div>

      <!-- Loading State -->
      <LoadingSkeletons v-if="isLoading" type="module-cards" :count="3" />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useCategories } from '../composables/useCategories.js'
import Navigation from '../components/Navigation.vue'
import LoadingSkeletons from '../components/LoadingSkeletons.vue'
import CourseCard from '../components/CourseCard.vue'

const route = useRoute()
const { getCategoryBySlug, loadCategoryCourses } = useCategories()

// Route params
const categorySlug = computed(() => route.params.categorySlug)

// Local state
const category = ref(null)
const courses = ref([])
const isLoading = ref(true)

// Load category and courses
onMounted(async () => {
  isLoading.value = true
  
  // Get category details
  category.value = getCategoryBySlug(categorySlug.value)
  
  // Load courses for this category
  if (category.value) {
    courses.value = await loadCategoryCourses(categorySlug.value)
  }
  
  isLoading.value = false
})
</script>