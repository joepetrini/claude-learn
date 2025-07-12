<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <main class="max-w-7xl mx-auto px-4 py-8">
      <!-- Header -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <router-link to="/admin" class="text-blue-600 hover:text-blue-800 text-sm mb-2 inline-block">
            ← Back to Admin Dashboard
          </router-link>
          <h1 class="text-3xl font-bold text-gray-900">All Users</h1>
          <p class="text-gray-600">Manage and view user progress</p>
        </div>
        
        <div class="flex gap-3">
          <button 
            @click="exportUsersCSV"
            class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            Export CSV
          </button>
          <button 
            @click="refreshData"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Refresh
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <LoadingSkeletons v-if="isLoading" type="user-list" :count="8" />

      <!-- Access Denied -->
      <div v-else-if="!isAdmin" class="text-center py-12">
        <div class="bg-red-50 border border-red-200 rounded-lg p-6 max-w-md mx-auto">
          <h2 class="text-lg font-semibold text-red-800 mb-2">Access Denied</h2>
          <p class="text-red-600">You don't have admin privileges to view this page.</p>
        </div>
      </div>

      <!-- Users List -->
      <div v-else>
        <!-- Search and Filters -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-6">
          <div class="flex flex-col sm:flex-row gap-4">
            <div class="flex-1">
              <input 
                v-model="searchQuery"
                type="text" 
                placeholder="Search users by email or name..."
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
            </div>
            <select 
              v-model="filterStatus"
              class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="all">All Users</option>
              <option value="active">Active Users</option>
              <option value="inactive">Inactive Users</option>
              <option value="completed">Completed Modules</option>
            </select>
          </div>
        </div>

        <!-- Users Table -->
        <div class="bg-white rounded-lg shadow-md overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    User
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Progress
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Quizzes
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Joined
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="user in filteredUsers" :key="user.id" class="hover:bg-gray-50">
                  <!-- User Info -->
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <img 
                        v-if="user.avatar_url" 
                        :src="user.avatar_url" 
                        :alt="user.full_name"
                        class="w-10 h-10 rounded-full mr-4"
                      >
                      <div v-else class="w-10 h-10 bg-gray-300 rounded-full mr-4 flex items-center justify-center">
                        <span class="text-gray-600 font-medium">
                          {{ (user.full_name || user.email).charAt(0).toUpperCase() }}
                        </span>
                      </div>
                      <div>
                        <div class="text-sm font-medium text-gray-900">
                          {{ user.full_name || 'No name' }}
                        </div>
                        <div class="text-sm text-gray-500">{{ user.email }}</div>
                        <div v-if="user.is_admin" class="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded-full inline-block mt-1">
                          Admin
                        </div>
                      </div>
                    </div>
                  </td>

                  <!-- Progress -->
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-900">
                      {{ getUserProgress(user).started }} started, {{ getUserProgress(user).completed }} completed
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-2 mt-2">
                      <div 
                        class="bg-blue-600 h-2 rounded-full"
                        :style="`width: ${getUserProgress(user).percentage}%`"
                      ></div>
                    </div>
                    <div class="text-xs text-gray-500 mt-1">
                      {{ getUserProgress(user).percentage }}% complete
                    </div>
                  </td>

                  <!-- Quizzes -->
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm text-gray-900">
                      {{ getQuizStats(user).taken }} taken
                    </div>
                    <div class="text-sm text-gray-500">
                      {{ getQuizStats(user).passRate }}% pass rate
                    </div>
                  </td>

                  <!-- Joined Date -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{ new Date(user.created_at).toLocaleDateString() }}
                  </td>

                  <!-- Actions -->
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <router-link 
                      :to="`/admin/users/${user.id}`"
                      class="text-blue-600 hover:text-blue-900 mr-4"
                    >
                      View Details
                    </router-link>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Empty State -->
          <div v-if="filteredUsers.length === 0" class="text-center py-12">
            <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-3a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 01-3 0m3 0h1.5m-1.5 0v-3" />
            </svg>
            <h3 class="mt-2 text-sm font-medium text-gray-900">No users found</h3>
            <p class="mt-1 text-sm text-gray-500">
              {{ searchQuery ? 'Try adjusting your search criteria.' : 'No users have registered yet.' }}
            </p>
          </div>
        </div>

        <!-- Summary Stats -->
        <div class="mt-6 bg-white rounded-lg shadow-md p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Summary</h3>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-center">
            <div>
              <div class="text-2xl font-bold text-blue-600">{{ filteredUsers.length }}</div>
              <div class="text-sm text-gray-500">Total Users</div>
            </div>
            <div>
              <div class="text-2xl font-bold text-green-600">{{ activeUsersCount }}</div>
              <div class="text-sm text-gray-500">Active Users</div>
            </div>
            <div>
              <div class="text-2xl font-bold text-purple-600">{{ totalModulesCompleted }}</div>
              <div class="text-sm text-gray-500">Modules Completed</div>
            </div>
            <div>
              <div class="text-2xl font-bold text-yellow-600">{{ totalQuizzesTaken }}</div>
              <div class="text-sm text-gray-500">Quizzes Taken</div>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Navigation from '../../components/Navigation.vue'
import LoadingSkeletons from '../../components/LoadingSkeletons.vue'
import { useAdmin } from '../../composables/useAdmin'

const { 
  isAdmin, 
  isLoading, 
  users,
  checkAdminStatus, 
  loadAllUsers,
  exportUsersCSV
} = useAdmin()

const searchQuery = ref('')
const filterStatus = ref('all')

// Filter users based on search and status
const filteredUsers = computed(() => {
  let filtered = users.value

  // Apply search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(user => 
      user.email.toLowerCase().includes(query) ||
      (user.full_name && user.full_name.toLowerCase().includes(query))
    )
  }

  // Apply status filter
  if (filterStatus.value !== 'all') {
    switch (filterStatus.value) {
      case 'active':
        filtered = filtered.filter(user => user.module_progress && user.module_progress.length > 0)
        break
      case 'inactive':
        filtered = filtered.filter(user => !user.module_progress || user.module_progress.length === 0)
        break
      case 'completed':
        filtered = filtered.filter(user => 
          user.module_progress && user.module_progress.some(m => m.status === 'completed')
        )
        break
    }
  }

  return filtered
})

// Helper functions
function getUserProgress(user) {
  const progress = user.module_progress || []
  const started = progress.length
  const completed = progress.filter(m => m.status === 'completed').length
  const percentage = started > 0 ? Math.round((completed / started) * 100) : 0
  
  return { started, completed, percentage }
}

function getQuizStats(user) {
  const quizzes = user.quiz_attempts || []
  const taken = quizzes.length
  const passed = quizzes.filter(q => q.passed).length
  const passRate = taken > 0 ? Math.round((passed / taken) * 100) : 0
  
  return { taken, passed, passRate }
}

// Summary statistics
const activeUsersCount = computed(() => 
  filteredUsers.value.filter(user => user.module_progress && user.module_progress.length > 0).length
)

const totalModulesCompleted = computed(() => 
  filteredUsers.value.reduce((total, user) => 
    total + (user.module_progress ? user.module_progress.filter(m => m.status === 'completed').length : 0), 0
  )
)

const totalQuizzesTaken = computed(() => 
  filteredUsers.value.reduce((total, user) => 
    total + (user.quiz_attempts ? user.quiz_attempts.length : 0), 0
  )
)

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