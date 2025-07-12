<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <main class="max-w-7xl mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <router-link to="/admin/users" class="text-blue-600 hover:text-blue-800 text-sm mb-2 inline-block">
          ← Back to Users List
        </router-link>
        <div v-if="userDetails" class="flex items-center">
          <img 
            v-if="userDetails.avatar_url" 
            :src="userDetails.avatar_url" 
            :alt="userDetails.full_name"
            class="w-16 h-16 rounded-full mr-4"
          >
          <div v-else class="w-16 h-16 bg-gray-300 rounded-full mr-4 flex items-center justify-center">
            <span class="text-gray-600 text-xl font-medium">
              {{ (userDetails.full_name || userDetails.email).charAt(0).toUpperCase() }}
            </span>
          </div>
          <div>
            <h1 class="text-3xl font-bold text-gray-900">{{ userDetails.full_name || 'User' }}</h1>
            <p class="text-gray-600">{{ userDetails.email }}</p>
            <p class="text-sm text-gray-500">
              Joined {{ new Date(userDetails.created_at).toLocaleDateString() }}
            </p>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-500">Loading user progress...</p>
      </div>

      <!-- Access Denied -->
      <div v-else-if="!isAdmin" class="text-center py-12">
        <div class="bg-red-50 border border-red-200 rounded-lg p-6 max-w-md mx-auto">
          <h2 class="text-lg font-semibold text-red-800 mb-2">Access Denied</h2>
          <p class="text-red-600">You don't have admin privileges to view this page.</p>
        </div>
      </div>

      <!-- User Progress Content -->
      <div v-else-if="userDetails">
        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-center">
              <div class="text-3xl font-bold text-blue-600">{{ moduleStats.started }}</div>
              <div class="text-sm text-gray-500">Modules Started</div>
            </div>
          </div>
          
          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-center">
              <div class="text-3xl font-bold text-green-600">{{ moduleStats.completed }}</div>
              <div class="text-sm text-gray-500">Modules Completed</div>
            </div>
          </div>
          
          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-center">
              <div class="text-3xl font-bold text-purple-600">{{ quizStats.taken }}</div>
              <div class="text-sm text-gray-500">Quizzes Taken</div>
            </div>
          </div>
          
          <div class="bg-white rounded-lg shadow-md p-6">
            <div class="text-center">
              <div class="text-3xl font-bold text-yellow-600">{{ quizStats.passRate }}%</div>
              <div class="text-sm text-gray-500">Quiz Pass Rate</div>
            </div>
          </div>
        </div>

        <!-- Module Progress -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Module Progress</h2>
          
          <div v-if="userDetails.module_progress && userDetails.module_progress.length > 0" class="space-y-4">
            <div 
              v-for="module in userDetails.module_progress" 
              :key="module.module_id"
              class="border border-gray-200 rounded-lg p-4"
            >
              <div class="flex items-center justify-between mb-2">
                <h3 class="font-medium text-gray-900">{{ formatModuleId(module.module_id) }}</h3>
                <span 
                  :class="module.status === 'completed' ? 'bg-green-100 text-green-800' : 'bg-blue-100 text-blue-800'"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ module.status }}
                </span>
              </div>
              
              <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm text-gray-600">
                <div>
                  <span class="font-medium">Started:</span>
                  {{ new Date(module.started_at).toLocaleDateString() }}
                </div>
                <div v-if="module.completed_at">
                  <span class="font-medium">Completed:</span>
                  {{ new Date(module.completed_at).toLocaleDateString() }}
                </div>
                <div>
                  <span class="font-medium">Sections:</span>
                  {{ getSectionCount(module.module_id) }} completed
                </div>
              </div>
              
              <!-- Section Progress for this module -->
              <div v-if="getModuleSections(module.module_id).length > 0" class="mt-4">
                <h4 class="text-sm font-medium text-gray-700 mb-2">Section Progress:</h4>
                <div class="flex flex-wrap gap-2">
                  <span 
                    v-for="section in getModuleSections(module.module_id)" 
                    :key="section.section_index"
                    class="px-2 py-1 bg-green-100 text-green-800 text-xs rounded-full"
                  >
                    Section {{ section.section_index + 1 }}
                  </span>
                </div>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-8">
            <p class="text-gray-500">No modules started yet</p>
          </div>
        </div>

        <!-- Quiz History -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Quiz History</h2>
          
          <div v-if="userDetails.quiz_attempts && userDetails.quiz_attempts.length > 0" class="space-y-4">
            <div 
              v-for="quiz in sortedQuizzes" 
              :key="quiz.id"
              class="border border-gray-200 rounded-lg p-4"
            >
              <div class="flex items-center justify-between mb-4">
                <h3 class="font-medium text-gray-900">{{ formatModuleId(quiz.module_id) }} Quiz</h3>
                <span 
                  :class="quiz.passed ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
                  class="px-2 py-1 text-xs font-medium rounded-full"
                >
                  {{ quiz.passed ? 'Passed' : 'Failed' }}
                </span>
              </div>
              
              <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-4">
                <div class="text-center">
                  <div class="text-2xl font-bold text-gray-900">{{ quiz.score }}</div>
                  <div class="text-xs text-gray-500">Score</div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-gray-900">{{ quiz.total_questions }}</div>
                  <div class="text-xs text-gray-500">Total Questions</div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-gray-900">{{ Math.round((quiz.score / quiz.total_questions) * 100) }}%</div>
                  <div class="text-xs text-gray-500">Percentage</div>
                </div>
                <div class="text-center">
                  <div class="text-sm text-gray-900">{{ new Date(quiz.completed_at).toLocaleDateString() }}</div>
                  <div class="text-xs text-gray-500">Completed</div>
                </div>
              </div>
              
              <!-- Quiz Answers Detail -->
              <div v-if="quiz.quiz_answers && quiz.quiz_answers.length > 0" class="mt-4">
                <h4 class="text-sm font-medium text-gray-700 mb-2">Question Details:</h4>
                <div class="grid grid-cols-5 sm:grid-cols-10 gap-1">
                  <div 
                    v-for="answer in quiz.quiz_answers" 
                    :key="answer.question_index"
                    :class="answer.is_correct ? 'bg-green-500' : 'bg-red-500'"
                    class="w-6 h-6 rounded flex items-center justify-center text-white text-xs font-medium"
                    :title="`Question ${answer.question_index + 1}: ${answer.is_correct ? 'Correct' : 'Incorrect'}`"
                  >
                    {{ answer.question_index + 1 }}
                  </div>
                </div>
                <div class="text-xs text-gray-500 mt-2">
                  Green = Correct, Red = Incorrect
                </div>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-8">
            <p class="text-gray-500">No quizzes taken yet</p>
          </div>
        </div>
      </div>

      <!-- User Not Found -->
      <div v-else class="text-center py-12">
        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6 max-w-md mx-auto">
          <h2 class="text-lg font-semibold text-yellow-800 mb-2">User Not Found</h2>
          <p class="text-yellow-600">The requested user could not be found.</p>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import Navigation from '../../components/Navigation.vue'
import { useAdmin } from '../../composables/useAdmin'

const route = useRoute()
const userId = computed(() => route.params.id)

const { isAdmin, checkAdminStatus, getUserProgress } = useAdmin()

const loading = ref(true)
const userDetails = ref(null)

// Computed statistics
const moduleStats = computed(() => {
  if (!userDetails.value?.module_progress) {
    return { started: 0, completed: 0 }
  }
  
  const progress = userDetails.value.module_progress
  return {
    started: progress.length,
    completed: progress.filter(m => m.status === 'completed').length
  }
})

const quizStats = computed(() => {
  if (!userDetails.value?.quiz_attempts) {
    return { taken: 0, passed: 0, passRate: 0 }
  }
  
  const attempts = userDetails.value.quiz_attempts
  const taken = attempts.length
  const passed = attempts.filter(q => q.passed).length
  const passRate = taken > 0 ? Math.round((passed / taken) * 100) : 0
  
  return { taken, passed, passRate }
})

const sortedQuizzes = computed(() => {
  if (!userDetails.value?.quiz_attempts) return []
  
  return [...userDetails.value.quiz_attempts].sort((a, b) => 
    new Date(b.completed_at) - new Date(a.completed_at)
  )
})

// Helper functions
function formatModuleId(moduleId) {
  return moduleId
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ')
}

function getSectionCount(moduleId) {
  if (!userDetails.value?.section_progress) return 0
  
  return userDetails.value.section_progress.filter(s => s.module_id === moduleId).length
}

function getModuleSections(moduleId) {
  if (!userDetails.value?.section_progress) return []
  
  return userDetails.value.section_progress
    .filter(s => s.module_id === moduleId)
    .sort((a, b) => a.section_index - b.section_index)
}

onMounted(async () => {
  await checkAdminStatus()
  
  if (isAdmin.value) {
    try {
      userDetails.value = await getUserProgress(userId.value)
    } catch (error) {
      console.error('Failed to load user progress:', error)
    }
  }
  
  loading.value = false
})
</script>