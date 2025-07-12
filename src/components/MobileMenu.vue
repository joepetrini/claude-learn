<template>
  <div class="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t shadow-lg z-40">
    <div class="flex justify-around items-center py-2">
      <router-link
        to="/"
        class="flex flex-col items-center p-2 text-gray-600 hover:text-blue-600"
        :class="{ 'text-blue-600': $route.name === 'home' }"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        <span class="text-xs mt-1">Home</span>
      </router-link>
      
      <button
        @click="$emit('search')"
        class="flex flex-col items-center p-2 text-gray-600 hover:text-blue-600"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <span class="text-xs mt-1">Search</span>
      </button>
      
      <router-link
        to="/cheatsheet"
        class="flex flex-col items-center p-2 text-gray-600 hover:text-blue-600"
        :class="{ 'text-blue-600': $route.name === 'cheatsheet' }"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <span class="text-xs mt-1">Reference</span>
      </router-link>
      
      <button
        @click="$emit('help')"
        class="flex flex-col items-center p-2 text-gray-600 hover:text-blue-600"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span class="text-xs mt-1">Help</span>
      </button>
    </div>
  </div>
</template>

<script setup>
defineEmits(['search', 'help'])
</script>