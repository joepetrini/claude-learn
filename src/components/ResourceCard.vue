<template>
  <div 
    class="bg-white rounded-lg shadow-md hover:shadow-lg transition-all duration-200 cursor-pointer group"
    @click="$emit('view-resource', resource)"
  >
    <!-- Header -->
    <div class="p-6 pb-4">
      <div class="flex items-start justify-between">
        <div class="flex items-center space-x-3">
          <span class="text-2xl">{{ resource.icon }}</span>
          <div>
            <h3 class="text-lg font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
              {{ resource.title }}
            </h3>
            <p class="text-sm text-gray-500 capitalize">{{ resource.type.replace('-', ' ') }}</p>
          </div>
        </div>
        
        <!-- Favorite star -->
        <button
          @click.stop="toggleFavorite"
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
          :class="{ 'text-yellow-500': resource.isFavorited, 'text-gray-400': !resource.isFavorited }"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
          </svg>
        </button>
      </div>
      
      <!-- Description -->
      <p class="text-gray-600 mt-3 text-sm line-clamp-2">
        {{ resource.description }}
      </p>
    </div>
    
    <!-- Footer -->
    <div class="px-6 py-4 bg-gray-50 rounded-b-lg">
      <div class="flex items-center justify-between">
        <!-- Tags -->
        <div class="flex flex-wrap gap-1">
          <span
            v-for="tag in resource.tags?.slice(0, 3)"
            :key="tag"
            class="inline-block px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full"
          >
            {{ tag }}
          </span>
          <span
            v-if="resource.tags?.length > 3"
            class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full"
          >
            +{{ resource.tags.length - 3 }}
          </span>
        </div>
        
        <!-- Stats -->
        <div class="flex items-center space-x-4 text-sm text-gray-500">
          <span v-if="resource.viewCount" class="flex items-center space-x-1">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
            <span>{{ resource.viewCount }}</span>
          </span>
          
          <span v-if="resource.featured" class="flex items-center space-x-1 text-blue-600">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
            <span>Featured</span>
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue'

const props = defineProps({
  resource: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['view-resource', 'toggle-favorite'])

const toggleFavorite = () => {
  emit('toggle-favorite', props.resource)
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>