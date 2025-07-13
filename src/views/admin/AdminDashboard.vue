<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <main class="max-w-7xl mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Admin Dashboard</h1>
        <p class="text-gray-600">Monitor user progress and learning analytics</p>
      </div>

      <!-- Loading State -->
      <div v-if="isLoading">
        <LoadingSkeletons type="analytics-cards" />
      </div>

      <!-- Access Denied -->
      <div v-else-if="!isAdmin" class="text-center py-12">
        <div class="bg-red-50 border border-red-200 rounded-lg p-6 max-w-md mx-auto">
          <h2 class="text-lg font-semibold text-red-800 mb-2">Access Denied</h2>
          <p class="text-red-600">You don't have admin privileges to view this page.</p>
          <router-link to="/" class="mt-4 inline-block px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            Back to Home
          </router-link>
        </div>
      </div>

      <!-- Admin Content -->
      <div v-else>
        <!-- Analytics Cards -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center">
              <div class="p-3 bg-blue-100 rounded-lg">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-3a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 01-3 0m3 0h1.5m-1.5 0v-3"></path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500">Total Users</p>
                <p class="text-2xl font-semibold text-gray-900">{{ analytics.totalUsers }}</p>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center">
              <div class="p-3 bg-green-100 rounded-lg">
                <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500">Active Users</p>
                <p class="text-2xl font-semibold text-gray-900">{{ analytics.activeUsers }}</p>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center">
              <div class="p-3 bg-purple-100 rounded-lg">
                <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500">Modules Completed</p>
                <p class="text-2xl font-semibold text-gray-900">{{ analytics.completedModules }}</p>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center">
              <div class="p-3 bg-yellow-100 rounded-lg">
                <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
              </div>
              <div class="ml-4">
                <p class="text-sm font-medium text-gray-500">Quiz Pass Rate</p>
                <p class="text-2xl font-semibold text-gray-900">{{ analytics.passRate }}%</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <!-- Users Overview -->
          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="flex items-center justify-between mb-4">
              <h2 class="text-lg font-semibold text-gray-900">Recent Users</h2>
              <router-link 
                to="/admin/users" 
                class="text-blue-600 hover:text-blue-800 text-sm font-medium"
              >
                View All →
              </router-link>
            </div>
            
            <div v-if="users.length === 0" class="text-center py-6">
              <p class="text-gray-500">No users found</p>
            </div>
            
            <div v-else class="space-y-3">
              <div 
                v-for="user in users.slice(0, 5)" 
                :key="user.id"
                class="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
              >
                <div class="flex items-center">
                  <img 
                    v-if="user.avatar_url" 
                    :src="user.avatar_url" 
                    :alt="user.full_name"
                    class="w-8 h-8 rounded-full mr-3"
                  >
                  <div v-else class="w-8 h-8 bg-gray-300 rounded-full mr-3 flex items-center justify-center">
                    <span class="text-gray-600 text-sm font-medium">
                      {{ (user.full_name || user.email).charAt(0).toUpperCase() }}
                    </span>
                  </div>
                  <div>
                    <p class="font-medium text-gray-900">{{ user.full_name || user.email }}</p>
                    <p class="text-sm text-gray-500">
                      {{ user.module_progress_json?.length || 0 }} modules started
                    </p>
                  </div>
                </div>
                <router-link 
                  :to="`/admin/users/${user.id}`"
                  class="text-blue-600 hover:text-blue-800 text-sm"
                >
                  View Details
                </router-link>
              </div>
            </div>
          </div>

          <!-- Admin Tools -->
          <div class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Admin Tools</h2>
            
            <div class="space-y-3">
              <router-link
                to="/admin/content-sync"
                class="block p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors"
              >
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <div class="p-2 bg-purple-100 rounded-lg">
                      <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                      </svg>
                    </div>
                    <div>
                      <h3 class="font-medium text-purple-900">Content Sync</h3>
                      <p class="text-sm text-purple-700">Synchronize JSON files with database</p>
                    </div>
                  </div>
                  <svg class="w-5 h-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                  </svg>
                </div>
              </router-link>
            </div>
          </div>

          <!-- Export Tools -->
          <div class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">Export Data</h2>
            
            <div class="space-y-4">
              <div>
                <h3 class="font-medium text-gray-700 mb-2">User Reports</h3>
                <p class="text-sm text-gray-500 mb-3">Export user list with progress summary</p>
                <button 
                  @click="exportUsersCSV"
                  class="w-full px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
                >
                  Export Users CSV
                </button>
              </div>
              
              <div>
                <h3 class="font-medium text-gray-700 mb-2">Detailed Progress</h3>
                <p class="text-sm text-gray-500 mb-3">Export complete progress data as JSON</p>
                <button 
                  @click="exportProgressJSON"
                  class="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Export Progress JSON
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Last Updated -->
        <div class="text-center text-sm text-gray-500">
          <p v-if="adminData.lastUpdated">
            Last updated: {{ new Date(adminData.lastUpdated).toLocaleString() }}
          </p>
          <button 
            @click="refreshData"
            class="mt-2 text-blue-600 hover:text-blue-800"
          >
            Refresh Data
          </button>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import Navigation from '../../components/Navigation.vue'
import LoadingSkeletons from '../../components/LoadingSkeletons.vue'
import { useAdmin } from '../../composables/useAdmin'

const { 
  adminData, 
  analytics, 
  isAdmin, 
  isLoading, 
  users,
  checkAdminStatus, 
  loadAllUsers,
  exportUsersCSV,
  exportProgressJSON
} = useAdmin()

async function refreshData() {
  await loadAllUsers()
}

onMounted(async () => {
  await checkAdminStatus()
  if (isAdmin.value) {
    await loadAllUsers()
  }
})
</script>