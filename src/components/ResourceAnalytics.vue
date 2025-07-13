<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h2 class="text-2xl font-bold text-gray-900">Resource Analytics</h2>
        <p class="text-gray-600 mt-1">Insights into resource usage and engagement</p>
      </div>
      
      <!-- Time period selector -->
      <div class="flex items-center space-x-2">
        <label class="text-sm text-gray-600">Period:</label>
        <select
          v-model="selectedPeriod"
          @change="loadAnalytics"
          class="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
          <option value="7d">Last 7 days</option>
          <option value="30d">Last 30 days</option>
          <option value="90d">Last 90 days</option>
          <option value="1y">Last year</option>
        </select>
      </div>
    </div>

    <!-- Key Metrics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <!-- Total Views -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center">
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-600">Total Views</p>
            <p class="text-3xl font-bold text-gray-900">{{ formatNumber(metrics.totalViews) }}</p>
            <p class="text-sm text-green-600 mt-1">
              <svg class="inline w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L10 4.414 4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
              +{{ metrics.viewsGrowth }}% from last period
            </p>
          </div>
          <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Unique Users -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center">
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-600">Unique Users</p>
            <p class="text-3xl font-bold text-gray-900">{{ formatNumber(metrics.uniqueUsers) }}</p>
            <p class="text-sm text-green-600 mt-1">
              <svg class="inline w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L10 4.414 4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
              +{{ metrics.usersGrowth }}% from last period
            </p>
          </div>
          <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Favorites -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center">
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-600">Total Favorites</p>
            <p class="text-3xl font-bold text-gray-900">{{ formatNumber(metrics.totalFavorites) }}</p>
            <p class="text-sm text-blue-600 mt-1">
              <svg class="inline w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L10 4.414 4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
              +{{ metrics.favoritesGrowth }}% from last period
            </p>
          </div>
          <div class="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Average Views per Resource -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center">
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-600">Avg Views/Resource</p>
            <p class="text-3xl font-bold text-gray-900">{{ formatNumber(metrics.avgViewsPerResource) }}</p>
            <p class="text-sm text-purple-600 mt-1">
              <svg class="inline w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M3.293 9.707a1 1 0 010-1.414l6-6a1 1 0 011.414 0l6 6a1 1 0 01-1.414 1.414L10 4.414 4.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
              </svg>
              +{{ metrics.avgViewsGrowth }}% from last period
            </p>
          </div>
          <div class="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Views Over Time Chart -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Views Over Time</h3>
        <div class="h-64 flex items-end justify-between space-x-2">
          <div
            v-for="(day, index) in viewsChart"
            :key="index"
            class="bg-blue-500 rounded-t-md min-w-0 flex-1 relative group"
            :style="{ height: `${(day.views / Math.max(...viewsChart.map(d => d.views))) * 100}%` }"
          >
            <!-- Tooltip -->
            <div class="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-2 py-1 bg-gray-900 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
              {{ day.date }}: {{ day.views }} views
            </div>
          </div>
        </div>
        <div class="flex justify-between text-xs text-gray-500 mt-2">
          <span>{{ viewsChart[0]?.date }}</span>
          <span>{{ viewsChart[viewsChart.length - 1]?.date }}</span>
        </div>
      </div>

      <!-- Resource Type Distribution -->
      <div class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Resource Type Distribution</h3>
        <div class="space-y-4">
          <div
            v-for="type in resourceTypes"
            :key="type.name"
            class="flex items-center justify-between"
          >
            <div class="flex items-center space-x-3">
              <span class="text-lg">{{ type.icon }}</span>
              <span class="text-sm font-medium text-gray-900 capitalize">{{ type.name.replace('-', ' ') }}</span>
            </div>
            <div class="flex items-center space-x-3">
              <div class="w-24 bg-gray-200 rounded-full h-2">
                <div
                  class="h-2 rounded-full"
                  :class="type.color"
                  :style="{ width: `${type.percentage}%` }"
                ></div>
              </div>
              <span class="text-sm text-gray-600 w-12 text-right">{{ type.percentage }}%</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Top Resources Tables -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Most Viewed Resources -->
      <div class="bg-white rounded-lg shadow-md">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Most Viewed Resources</h3>
          <p class="text-sm text-gray-600 mt-1">Top performing resources by views</p>
        </div>
        <div class="divide-y divide-gray-200">
          <div
            v-for="(resource, index) in topResources.mostViewed"
            :key="`viewed-${resource.id}`"
            class="p-4 hover:bg-gray-50"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <span class="w-6 h-6 bg-blue-100 text-blue-600 text-xs font-bold rounded-full flex items-center justify-center">
                  {{ index + 1 }}
                </span>
                <span class="text-lg">{{ resource.icon }}</span>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-medium text-gray-900 truncate">{{ resource.title }}</p>
                  <p class="text-xs text-gray-500 truncate">{{ resource.course }}</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm font-semibold text-gray-900">{{ formatNumber(resource.views) }}</p>
                <p class="text-xs text-gray-500">views</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Most Favorited Resources -->
      <div class="bg-white rounded-lg shadow-md">
        <div class="p-6 border-b border-gray-200">
          <h3 class="text-lg font-semibold text-gray-900">Most Favorited Resources</h3>
          <p class="text-sm text-gray-600 mt-1">Resources users love most</p>
        </div>
        <div class="divide-y divide-gray-200">
          <div
            v-for="(resource, index) in topResources.mostFavorited"
            :key="`favorited-${resource.id}`"
            class="p-4 hover:bg-gray-50"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-3">
                <span class="w-6 h-6 bg-yellow-100 text-yellow-600 text-xs font-bold rounded-full flex items-center justify-center">
                  {{ index + 1 }}
                </span>
                <span class="text-lg">{{ resource.icon }}</span>
                <div class="min-w-0 flex-1">
                  <p class="text-sm font-medium text-gray-900 truncate">{{ resource.title }}</p>
                  <p class="text-xs text-gray-500 truncate">{{ resource.course }}</p>
                </div>
              </div>
              <div class="text-right">
                <p class="text-sm font-semibold text-gray-900">{{ formatNumber(resource.favorites) }}</p>
                <p class="text-xs text-gray-500">favorites</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- User Engagement Insights -->
    <div class="bg-white rounded-lg shadow-md p-6">
      <h3 class="text-lg font-semibold text-gray-900 mb-4">User Engagement Insights</h3>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <!-- Average Session Duration -->
        <div class="text-center">
          <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-3">
            <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <p class="text-2xl font-bold text-gray-900">{{ metrics.avgSessionDuration }}</p>
          <p class="text-sm text-gray-600">Avg Session Duration</p>
        </div>

        <!-- Return Rate -->
        <div class="text-center">
          <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
            <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </div>
          <p class="text-2xl font-bold text-gray-900">{{ metrics.returnRate }}%</p>
          <p class="text-sm text-gray-600">7-Day Return Rate</p>
        </div>

        <!-- Favorite Rate -->
        <div class="text-center">
          <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-3">
            <svg class="w-8 h-8 text-yellow-600" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
          </div>
          <p class="text-2xl font-bold text-gray-900">{{ metrics.favoriteRate }}%</p>
          <p class="text-sm text-gray-600">View to Favorite Rate</p>
        </div>
      </div>
    </div>

    <!-- Export Actions -->
    <div class="flex justify-end space-x-4">
      <button
        @click="exportAnalytics('csv')"
        class="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
      >
        Export CSV
      </button>
      <button
        @click="exportAnalytics('pdf')"
        class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition-colors"
      >
        Export Report
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

// Reactive data
const selectedPeriod = ref('30d')
const loading = ref(false)

// Mock analytics data
const metrics = ref({
  totalViews: 12847,
  viewsGrowth: 23.5,
  uniqueUsers: 2341,
  usersGrowth: 18.2,
  totalFavorites: 1247,
  favoritesGrowth: 31.7,
  avgViewsPerResource: 428,
  avgViewsGrowth: 12.4,
  avgSessionDuration: '4m 32s',
  returnRate: 68,
  favoriteRate: 9.7
})

const viewsChart = ref([
  { date: 'Nov 1', views: 245 },
  { date: 'Nov 2', views: 312 },
  { date: 'Nov 3', views: 278 },
  { date: 'Nov 4', views: 389 },
  { date: 'Nov 5', views: 445 },
  { date: 'Nov 6', views: 523 },
  { date: 'Nov 7', views: 678 },
  { date: 'Nov 8', views: 567 },
  { date: 'Nov 9', views: 634 },
  { date: 'Nov 10', views: 712 },
  { date: 'Nov 11', views: 589 },
  { date: 'Nov 12', views: 623 },
  { date: 'Nov 13', views: 745 },
  { date: 'Nov 14', views: 856 }
])

const resourceTypes = ref([
  { name: 'cheat-sheet', icon: '📋', percentage: 45, color: 'bg-blue-500' },
  { name: 'links', icon: '🔗', percentage: 28, color: 'bg-green-500' },
  { name: 'glossary', icon: '📚', percentage: 18, color: 'bg-purple-500' },
  { name: 'downloads', icon: '📁', percentage: 9, color: 'bg-yellow-500' }
])

const topResources = ref({
  mostViewed: [
    { id: 1, title: 'Claude Code Quick Reference', course: 'Claude Code Training', icon: '📋', views: 3421 },
    { id: 2, title: 'Django Commands Cheat Sheet', course: 'Django Mastery', icon: '📋', views: 2876 },
    { id: 3, title: 'Python Best Practices', course: 'Python Fundamentals', icon: '🐍', views: 2543 },
    { id: 4, title: 'Git Workflow Guide', course: 'Version Control', icon: '📝', views: 2187 },
    { id: 5, title: 'API Documentation Links', course: 'REST APIs', icon: '🔗', views: 1954 }
  ],
  mostFavorited: [
    { id: 1, title: 'Claude Code Quick Reference', course: 'Claude Code Training', icon: '📋', favorites: 543 },
    { id: 2, title: 'Django ORM Glossary', course: 'Django Mastery', icon: '📚', favorites: 421 },
    { id: 3, title: 'Python Debugging Tools', course: 'Python Fundamentals', icon: '🔧', favorites: 387 },
    { id: 4, title: 'React Hooks Guide', course: 'React Development', icon: '⚛️', favorites: 312 },
    { id: 5, title: 'CSS Grid Examples', course: 'Frontend Design', icon: '🎨', favorites: 289 }
  ]
})

// Methods
const loadAnalytics = async () => {
  loading.value = true
  // Mock API call - in real app, this would fetch data based on selectedPeriod
  await new Promise(resolve => setTimeout(resolve, 1000))
  loading.value = false
}

const formatNumber = (num) => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  } else if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num.toString()
}

const exportAnalytics = (format) => {
  if (format === 'csv') {
    // Create CSV content
    const csvContent = [
      ['Metric', 'Value'],
      ['Total Views', metrics.value.totalViews],
      ['Unique Users', metrics.value.uniqueUsers],
      ['Total Favorites', metrics.value.totalFavorites],
      ['Avg Views per Resource', metrics.value.avgViewsPerResource],
      ['Return Rate', `${metrics.value.returnRate}%`],
      ['Favorite Rate', `${metrics.value.favoriteRate}%`]
    ].map(row => row.join(',')).join('\n')
    
    const blob = new Blob([csvContent], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `resource-analytics-${selectedPeriod.value}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } else if (format === 'pdf') {
    // In real app, this would generate a PDF report
    alert('PDF export would be implemented with a library like jsPDF')
  }
}

onMounted(() => {
  loadAnalytics()
})
</script>