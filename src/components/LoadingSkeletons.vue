<template>
  <!-- Module Cards Skeleton -->
  <div v-if="type === 'module-cards'" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    <div v-for="i in count" :key="i" class="bg-white rounded-lg shadow-md p-6 animate-pulse">
      <div class="w-12 h-12 bg-gray-200 rounded-lg mb-4"></div>
      <div class="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
      <div class="h-3 bg-gray-200 rounded w-full mb-4"></div>
      <div class="h-3 bg-gray-200 rounded w-1/2"></div>
    </div>
  </div>

  <!-- Module Content Skeleton -->
  <div v-else-if="type === 'module-content'" class="animate-pulse">
    <!-- Header -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <div class="flex items-start justify-between">
        <div class="flex-1">
          <div class="flex items-center gap-3 mb-2">
            <div class="w-10 h-10 bg-gray-200 rounded"></div>
            <div class="h-6 bg-gray-200 rounded w-1/2"></div>
          </div>
          <div class="h-4 bg-gray-200 rounded w-3/4"></div>
        </div>
        <div class="w-16 h-4 bg-gray-200 rounded"></div>
      </div>
      
      <!-- Progress Bar -->
      <div class="mt-6">
        <div class="flex justify-between mb-2">
          <div class="h-3 bg-gray-200 rounded w-24"></div>
          <div class="h-3 bg-gray-200 rounded w-20"></div>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-2"></div>
      </div>
    </div>
    
    <!-- Content -->
    <div class="bg-white rounded-lg shadow-md p-8">
      <div class="h-6 bg-gray-200 rounded w-1/2 mb-4"></div>
      <div class="space-y-3 mb-6">
        <div class="h-4 bg-gray-200 rounded w-full"></div>
        <div class="h-4 bg-gray-200 rounded w-5/6"></div>
        <div class="h-4 bg-gray-200 rounded w-4/5"></div>
        <div class="h-4 bg-gray-200 rounded w-full"></div>
        <div class="h-4 bg-gray-200 rounded w-3/4"></div>
      </div>
      
      <!-- Code Block -->
      <div class="bg-gray-100 rounded-lg p-4 mb-6">
        <div class="space-y-2">
          <div class="h-3 bg-gray-200 rounded w-1/3"></div>
          <div class="h-3 bg-gray-200 rounded w-1/2"></div>
          <div class="h-3 bg-gray-200 rounded w-2/3"></div>
          <div class="h-3 bg-gray-200 rounded w-1/4"></div>
        </div>
      </div>
      
      <!-- Navigation -->
      <div class="flex justify-between items-center pt-6 border-t">
        <div class="w-20 h-10 bg-gray-200 rounded"></div>
        <div class="w-16 h-4 bg-gray-200 rounded"></div>
        <div class="w-20 h-10 bg-gray-200 rounded"></div>
      </div>
    </div>
  </div>

  <!-- Quiz Skeleton -->
  <div v-else-if="type === 'quiz'" class="animate-pulse">
    <!-- Header -->
    <div class="bg-white rounded-lg shadow-md p-6 mb-6">
      <div class="h-6 bg-gray-200 rounded w-1/2 mb-2"></div>
      <div class="flex justify-between items-center mb-4">
        <div class="h-4 bg-gray-200 rounded w-32"></div>
        <div class="h-4 bg-gray-200 rounded w-24"></div>
      </div>
      <div class="w-full bg-gray-200 rounded-full h-2"></div>
    </div>
    
    <!-- Question -->
    <div class="bg-white rounded-lg shadow-md p-8">
      <div class="h-5 bg-gray-200 rounded w-3/4 mb-6"></div>
      
      <!-- Options -->
      <div class="space-y-3 mb-8">
        <div v-for="i in 4" :key="i" class="border-2 border-gray-200 rounded-lg p-4">
          <div class="flex items-center">
            <div class="w-6 h-6 bg-gray-200 rounded mr-3"></div>
            <div class="h-4 bg-gray-200 rounded w-2/3"></div>
          </div>
        </div>
      </div>
      
      <!-- Navigation -->
      <div class="flex justify-between">
        <div class="w-24 h-10 bg-gray-200 rounded"></div>
        <div class="w-24 h-10 bg-gray-200 rounded"></div>
      </div>
    </div>
  </div>

  <!-- User List Skeleton -->
  <div v-else-if="type === 'user-list'" class="bg-white rounded-lg shadow-md overflow-hidden animate-pulse">
    <div class="overflow-x-auto">
      <table class="min-w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3">
              <div class="h-3 bg-gray-200 rounded w-16"></div>
            </th>
            <th class="px-6 py-3">
              <div class="h-3 bg-gray-200 rounded w-20"></div>
            </th>
            <th class="px-6 py-3">
              <div class="h-3 bg-gray-200 rounded w-16"></div>
            </th>
            <th class="px-6 py-3">
              <div class="h-3 bg-gray-200 rounded w-16"></div>
            </th>
            <th class="px-6 py-3">
              <div class="h-3 bg-gray-200 rounded w-16"></div>
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="i in count" :key="i">
            <td class="px-6 py-4">
              <div class="flex items-center">
                <div class="w-10 h-10 bg-gray-200 rounded-full mr-4"></div>
                <div>
                  <div class="h-4 bg-gray-200 rounded w-32 mb-1"></div>
                  <div class="h-3 bg-gray-200 rounded w-48"></div>
                </div>
              </div>
            </td>
            <td class="px-6 py-4">
              <div class="h-4 bg-gray-200 rounded w-24 mb-2"></div>
              <div class="w-full bg-gray-200 rounded-full h-2 mb-1"></div>
              <div class="h-3 bg-gray-200 rounded w-16"></div>
            </td>
            <td class="px-6 py-4">
              <div class="h-4 bg-gray-200 rounded w-16 mb-1"></div>
              <div class="h-3 bg-gray-200 rounded w-20"></div>
            </td>
            <td class="px-6 py-4">
              <div class="h-4 bg-gray-200 rounded w-20"></div>
            </td>
            <td class="px-6 py-4">
              <div class="h-4 bg-gray-200 rounded w-24"></div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Analytics Cards Skeleton -->
  <div v-else-if="type === 'analytics-cards'" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 animate-pulse">
    <div v-for="i in 4" :key="i" class="bg-white rounded-lg shadow-md p-6">
      <div class="flex items-center">
        <div class="w-12 h-12 bg-gray-200 rounded-lg mr-4"></div>
        <div class="flex-1">
          <div class="h-3 bg-gray-200 rounded w-20 mb-2"></div>
          <div class="h-6 bg-gray-200 rounded w-12"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- Profile Skeleton -->
  <div v-else-if="type === 'profile'" class="space-y-8 animate-pulse">
    <!-- Profile Picture Section -->
    <div class="bg-white rounded-lg shadow-md p-6">
      <div class="h-5 bg-gray-200 rounded w-32 mb-6"></div>
      <div class="flex items-center space-x-6">
        <div class="w-24 h-24 bg-gray-200 rounded-full"></div>
        <div class="flex-1 space-y-3">
          <div class="h-4 bg-gray-200 rounded w-full"></div>
          <div class="h-3 bg-gray-200 rounded w-2/3"></div>
          <div class="h-8 bg-gray-200 rounded w-32"></div>
        </div>
      </div>
    </div>

    <!-- Form Section -->
    <div class="bg-white rounded-lg shadow-md p-6">
      <div class="h-5 bg-gray-200 rounded w-40 mb-6"></div>
      <div class="space-y-6">
        <div>
          <div class="h-4 bg-gray-200 rounded w-20 mb-2"></div>
          <div class="h-10 bg-gray-200 rounded w-full"></div>
        </div>
        <div>
          <div class="h-4 bg-gray-200 rounded w-24 mb-2"></div>
          <div class="h-10 bg-gray-200 rounded w-full"></div>
        </div>
        <div class="grid grid-cols-2 gap-6">
          <div>
            <div class="h-4 bg-gray-200 rounded w-28 mb-2"></div>
            <div class="h-4 bg-gray-200 rounded w-24"></div>
          </div>
          <div>
            <div class="h-4 bg-gray-200 rounded w-24 mb-2"></div>
            <div class="h-4 bg-gray-200 rounded w-20"></div>
          </div>
        </div>
        <div class="flex justify-end">
          <div class="h-10 bg-gray-200 rounded w-32"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- Text Lines Skeleton (Generic) -->
  <div v-else-if="type === 'text'" class="space-y-3 animate-pulse">
    <div v-for="i in count" :key="i" class="h-4 bg-gray-200 rounded" :class="getTextWidth(i)"></div>
  </div>

  <!-- Default Loading Spinner -->
  <div v-else class="flex items-center justify-center py-12">
    <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    <span class="ml-3 text-gray-500">Loading...</span>
  </div>
</template>

<script setup>
defineProps({
  type: {
    type: String,
    default: 'spinner',
    validator: (value) => [
      'module-cards',
      'module-content', 
      'quiz',
      'user-list',
      'analytics-cards',
      'profile',
      'text',
      'spinner'
    ].includes(value)
  },
  count: {
    type: Number,
    default: 6
  }
})

function getTextWidth(index) {
  const widths = ['w-full', 'w-5/6', 'w-4/5', 'w-full', 'w-3/4', 'w-5/6']
  return widths[index % widths.length]
}
</script>