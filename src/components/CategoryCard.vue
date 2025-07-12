<template>
  <div class="bg-white rounded-lg shadow-sm hover:shadow-lg hover:scale-[1.02] transition-all duration-200 p-6 relative group">
    <!-- New content badge -->
    <div v-if="hasNewContent" class="absolute top-4 left-4">
      <span class="px-2 py-1 bg-green-100 text-green-800 text-xs font-medium rounded-full flex items-center gap-1">
        <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
        </svg>
        New
      </span>
    </div>

    <!-- Favorite button -->
    <button
      @click.stop="$emit('toggle-favorite', category.slug)"
      class="absolute top-4 right-4 p-2 rounded-full transition-all duration-200 opacity-0 group-hover:opacity-100"
      :class="isFavorited ? 'text-yellow-500 hover:bg-yellow-50 opacity-100' : 'text-gray-400 hover:bg-gray-100'"
      :title="isFavorited ? 'Remove from favorites' : 'Add to favorites'"
    >
      <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
        <path v-if="isFavorited" d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        <path v-else fill-rule="evenodd" d="M10 2.118l1.307 4.022a1 1 0 00.95.69h4.229c.6 0 .85.769.366 1.118l-3.422 2.485a1 1 0 00-.364 1.118l1.307 4.022c.165.507-.47 1.045-.937.79l-3.422-2.485a1 1 0 00-1.176 0l-3.422 2.485c-.467.34-1.102-.283-.937-.79l1.307-4.022a1 1 0 00-.364-1.118L2 8.948c-.484-.352-.234-1.118.366-1.118h4.229a1 1 0 00.95-.69L10 2.118z" clip-rule="evenodd" />
      </svg>
    </button>

    <!-- Category content -->
    <router-link :to="`/category/${category.slug}`" class="block">
      <!-- Icon and title -->
      <div class="flex items-start gap-4 mb-4">
        <div 
          class="w-12 h-12 rounded-lg flex items-center justify-center text-2xl"
          :style="{ backgroundColor: category.color + '20' }"
        >
          {{ category.icon }}
        </div>
        <div class="flex-1">
          <h3 class="text-lg font-semibold text-gray-900 mb-1">
            {{ category.name }}
          </h3>
          <p class="text-sm text-gray-600 line-clamp-2">
            {{ category.description }}
          </p>
        </div>
      </div>

      <!-- Category stats -->
      <div class="flex items-center gap-4 text-sm text-gray-500">
        <div class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
          </svg>
          <span>{{ courseCount }} {{ courseCount === 1 ? 'course' : 'courses' }}</span>
        </div>
        
        <div v-if="progress" class="flex items-center gap-1">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <span>{{ progress.progressPercentage }}% complete</span>
        </div>
      </div>

      <!-- Progress bar (if user has progress) -->
      <div v-if="progress && progress.progressPercentage > 0" class="mt-4">
        <div class="w-full bg-gray-200 rounded-full h-2">
          <div 
            class="h-2 rounded-full transition-all duration-500"
            :class="progressBarColor"
            :style="`width: ${progress.progressPercentage}%`"
          ></div>
        </div>
      </div>
    </router-link>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useCategories } from '../composables/useCategories.js'

const props = defineProps({
  category: {
    type: Object,
    required: true
  },
  isFavorited: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['toggle-favorite'])

const { loadCategoryCourses, getCategoryProgress } = useCategories()

// Local state
const courseCount = ref(0)
const progress = ref(null)
const hasNewContent = ref(false)

// Computed progress bar color based on percentage
const progressBarColor = computed(() => {
  if (!progress.value) return ''
  const pct = progress.value.progressPercentage
  if (pct >= 80) return 'bg-green-500'
  if (pct >= 50) return 'bg-blue-500'
  if (pct >= 20) return 'bg-yellow-500'
  return 'bg-gray-400'
})

// Check if category has new content (added in last 7 days)
function checkForNewContent() {
  // Check if category was recently added
  const lastViewedDate = localStorage.getItem(`category_viewed_${props.category.slug}`)
  const sevenDaysAgo = new Date()
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
  
  // For now, we'll check if there are any new items based on localStorage
  // In a real app, this would check against actual content dates
  if (!lastViewedDate) {
    // Never viewed before, so it's new to this user
    hasNewContent.value = true
  } else {
    const lastViewed = new Date(lastViewedDate)
    // Check if any content was added after last view
    // For demo purposes, we'll just check if it's been more than 7 days
    hasNewContent.value = false
  }
  
  // Mark as viewed when user clicks on the category
  if (hasNewContent.value) {
    localStorage.setItem(`category_viewed_${props.category.slug}`, new Date().toISOString())
  }
}

// Load course count and progress
onMounted(async () => {
  // Check for new content
  checkForNewContent()
  
  // Load courses to get count
  const courses = await loadCategoryCourses(props.category.slug)
  courseCount.value = courses.length

  // Load progress if available
  const categoryProgress = await getCategoryProgress(props.category.slug)
  if (categoryProgress) {
    progress.value = categoryProgress
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