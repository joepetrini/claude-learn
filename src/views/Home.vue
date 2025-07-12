<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-8">
      <header class="text-center mb-12">
        <h1 class="text-4xl font-bold text-gray-900 mb-4">
          Learn Claude Code
        </h1>
        <p class="text-xl text-gray-600 max-w-2xl mx-auto">
          Master the powerful AI coding assistant with interactive modules designed for Python/Django developers
        </p>
        
        <!-- Overall Progress -->
        <div class="mt-6 max-w-md mx-auto">
          <div class="bg-white rounded-lg p-4 shadow-sm">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Overall Progress</span>
              <span class="text-sm text-gray-600">{{ overallProgress.completed }} / {{ overallProgress.total }} modules</span>
            </div>
            <div class="w-full bg-gray-200 rounded-full h-3">
              <div 
                class="bg-gradient-to-r from-blue-500 to-blue-600 h-3 rounded-full transition-all duration-500"
                :style="`width: ${overallProgress.percentage}%`"
              ></div>
            </div>
            <p class="text-xs text-gray-500 mt-2 text-center">{{ overallProgress.percentage }}% Complete</p>
          </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="mt-6 flex gap-4 justify-center">
          <router-link
            to="/cheatsheet"
            class="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Quick Reference
          </router-link>
        </div>
      </header>

      <div class="max-w-6xl mx-auto">
        <h2 class="text-2xl font-semibold mb-6">Core Learning Path</h2>
        <div v-if="loading" class="text-center py-12">
          <p class="text-gray-500">Loading modules...</p>
        </div>
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <router-link
            v-for="module in coreModules"
            :key="module.id"
            :to="`/module/${module.id}`"
            class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow relative"
          >
            <!-- Progress and Update indicators -->
            <div class="absolute top-4 right-4 flex items-center gap-2">
              <!-- Update badges -->
              <UpdateBadge 
                v-if="isModuleNew(module.id)" 
                type="new" 
                size="sm"
              />
              <UpdateBadge 
                v-else-if="isModuleUpdated(module.id)" 
                type="updated" 
                size="sm"
              />
              
              <!-- Progress indicator -->
              <div v-if="isModuleStarted(module.id)">
                <div v-if="isModuleCompleted(module.id)" class="text-green-500">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                  </svg>
                </div>
                <div v-else class="text-blue-500">
                  <svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V7z" clip-rule="evenodd" />
                  </svg>
                </div>
              </div>
            </div>
            
            <div class="text-4xl mb-4">{{ module.icon }}</div>
            <h3 class="text-lg font-semibold mb-2">{{ module.title }}</h3>
            <p class="text-sm text-gray-600 mb-4">{{ module.description }}</p>
            <div class="flex items-center justify-between text-sm">
              <span class="text-gray-500">{{ module.estimatedTime }}</span>
              <span v-if="isModuleCompleted(module.id)" class="text-green-600 font-medium">
                Review →
              </span>
              <span v-else-if="isModuleStarted(module.id)" class="text-blue-600 font-medium">
                Continue →
              </span>
              <span v-else class="text-blue-600 font-medium">
                Start →
              </span>
            </div>
          </router-link>
        </div>
        
        <!-- Update Modules -->
        <div v-if="updateModules.length > 0" class="mt-10">
          <h2 class="text-2xl font-semibold mb-2">Feature Updates</h2>
          <p class="text-gray-600 mb-6">Stay current with the latest Claude Code features</p>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <router-link
              v-for="module in updateModules"
              :key="module.id"
              :to="`/module/${module.id}`"
              class="bg-gradient-to-br from-blue-50 to-green-50 rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow relative border border-blue-200"
            >
              <!-- Update badge -->
              <div class="absolute top-4 right-4">
                <UpdateBadge type="new" size="sm" />
              </div>
              
              <div class="text-4xl mb-4">{{ module.icon || '🆕' }}</div>
              <h3 class="text-lg font-semibold mb-2">{{ module.title }}</h3>
              <p class="text-sm text-gray-600 mb-4">{{ module.description }}</p>
              
              <!-- Features list -->
              <div v-if="module.features" class="mb-4">
                <p class="text-xs font-medium text-gray-700 mb-1">New features:</p>
                <ul class="text-xs text-gray-600 space-y-0.5">
                  <li v-for="(feature, idx) in module.features.slice(0, 3)" :key="idx">
                    • {{ feature }}
                  </li>
                  <li v-if="module.features.length > 3" class="text-gray-500">
                    • And {{ module.features.length - 3 }} more...
                  </li>
                </ul>
              </div>
              
              <div class="flex items-center justify-between text-sm">
                <span class="text-gray-500">{{ module.estimatedTime }}</span>
                <span class="text-blue-600 font-medium">
                  Learn More →
                </span>
              </div>
            </router-link>
          </div>
        </div>
      </div>
    </div>
    
    <!-- What's New Modal -->
    <WhatsNewModal
      :is-open="showWhatsNew"
      :version-data="versionData"
      :updates="updatesSinceLastVisit"
      :modules="modules"
      @close="handleWhatsNewClose"
      @mark-seen="handleMarkSeen"
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useProgress } from '../composables/useProgress.js'
import { useUpdateDetection } from '../composables/useUpdateDetection.js'
import UpdateBadge from '../components/UpdateBadge.vue'
import WhatsNewModal from '../components/WhatsNewModal.vue'

const modules = ref([])
const loading = ref(true)
const showWhatsNew = ref(false)

// Computed properties for module filtering
const coreModules = computed(() => 
  modules.value.filter(m => !m.type || m.type !== 'update')
)

const updateModules = computed(() => 
  modules.value.filter(m => m.type === 'update')
)

// Use progress composable
const { isModuleStarted, isModuleCompleted, overallProgress } = useProgress()

// Use update detection
const { 
  versionData,
  shouldShowWhatsNew,
  updatesSinceLastVisit,
  isModuleNew,
  isModuleUpdated,
  markAllUpdatesSeen,
  loadVersionData
} = useUpdateDetection()

onMounted(async () => {
  try {
    // Load modules
    const response = await fetch(import.meta.env.BASE_URL + 'data/modules.json')
    const data = await response.json()
    modules.value = data.modules
    
    // Load version data for update detection
    await loadVersionData()
    
    // Show What's New modal if there are updates
    if (shouldShowWhatsNew.value) {
      showWhatsNew.value = true
    }
  } catch (error) {
    console.error('Failed to load modules:', error)
  } finally {
    loading.value = false
  }
})

function handleWhatsNewClose() {
  showWhatsNew.value = false
}

function handleMarkSeen() {
  markAllUpdatesSeen()
}
</script>