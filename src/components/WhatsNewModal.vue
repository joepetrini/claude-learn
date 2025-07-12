<template>
  <Transition name="modal">
    <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto">
      <!-- Backdrop -->
      <div 
        class="fixed inset-0 bg-black bg-opacity-50 transition-opacity"
        @click="close"
      ></div>
      
      <!-- Modal Content -->
      <div class="flex min-h-screen items-center justify-center p-4">
        <div 
          class="relative bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-hidden"
          @click.stop
        >
          <!-- Header -->
          <div class="sticky top-0 bg-white dark:bg-gray-800 border-b dark:border-gray-700 px-6 py-4">
            <div class="flex items-center justify-between">
              <h2 class="text-2xl font-bold text-gray-900 dark:text-white">
                🎉 What's New in Claude Learn
              </h2>
              <button
                @click="close"
                class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
              Content updated to {{ versionData?.lastUpdated }}
            </p>
          </div>
          
          <!-- Content -->
          <div class="overflow-y-auto max-h-[60vh] px-6 py-4">
            <!-- New Features -->
            <div v-if="newFeatures.length > 0" class="mb-6">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                ✨ New Features
              </h3>
              <ul class="space-y-2">
                <li 
                  v-for="feature in newFeatures" 
                  :key="feature"
                  class="flex items-start"
                >
                  <span class="text-green-500 mr-2">•</span>
                  <span class="text-gray-700 dark:text-gray-300">{{ feature }}</span>
                </li>
              </ul>
            </div>
            
            <!-- Updated Modules -->
            <div v-if="updatedModules.length > 0" class="mb-6">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                📝 Updated Modules
              </h3>
              <div class="space-y-3">
                <div 
                  v-for="module in updatedModules" 
                  :key="module.id"
                  class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4"
                >
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="font-medium text-gray-900 dark:text-white">
                      {{ getModuleTitle(module.id) }}
                    </h4>
                    <UpdateBadge type="updated" size="xs" />
                  </div>
                  <ul class="text-sm text-gray-600 dark:text-gray-400 space-y-1">
                    <li v-for="change in module.changes" :key="change">
                      • {{ change }}
                    </li>
                  </ul>
                </div>
              </div>
            </div>
            
            <!-- New Modules -->
            <div v-if="newModules.length > 0" class="mb-6">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                🆕 New Update Modules
              </h3>
              <div class="space-y-3">
                <div 
                  v-for="module in newModules" 
                  :key="module.id"
                  class="bg-green-50 dark:bg-green-900/20 rounded-lg p-4"
                >
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="font-medium text-gray-900 dark:text-white">
                      {{ module.month }}
                    </h4>
                    <UpdateBadge type="new" size="xs" />
                  </div>
                  <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">
                    Learn about {{ module.features.length }} new features
                  </p>
                  <router-link
                    :to="`/module/${module.id}`"
                    class="text-sm text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
                    @click="close"
                  >
                    Start Learning →
                  </router-link>
                </div>
              </div>
            </div>
            
            <!-- Version Info -->
            <div class="mt-6 pt-4 border-t dark:border-gray-700">
              <p class="text-sm text-gray-500 dark:text-gray-400">
                Claude Learn v{{ versionData?.contentVersion }} • 
                Compatible with Claude Code v{{ versionData?.claudeCodeVersion }}
              </p>
            </div>
          </div>
          
          <!-- Footer -->
          <div class="sticky bottom-0 bg-gray-50 dark:bg-gray-900 border-t dark:border-gray-700 px-6 py-4">
            <div class="flex justify-end gap-3">
              <button
                @click="close"
                class="px-4 py-2 text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white"
              >
                Maybe Later
              </button>
              <button
                @click="markSeenAndClose"
                class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
              >
                Got it!
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script setup>
import { computed } from 'vue'
import UpdateBadge from './UpdateBadge.vue'

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true
  },
  versionData: {
    type: Object,
    default: null
  },
  updates: {
    type: Object,
    default: () => ({ modules: [], features: [] })
  },
  modules: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'mark-seen'])

// Separate updates by type
const newModules = computed(() => 
  props.updates.modules.filter(m => m.type === 'new')
)

const updatedModules = computed(() => 
  props.updates.modules.filter(m => m.type === 'updated')
)

const newFeatures = computed(() => props.updates.features || [])

// Get module title from modules list
function getModuleTitle(moduleId) {
  const module = props.modules.find(m => m.id === moduleId)
  return module?.title || moduleId
}

function close() {
  emit('close')
}

function markSeenAndClose() {
  emit('mark-seen')
  emit('close')
}
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .relative,
.modal-leave-active .relative {
  transition: transform 0.3s ease;
}

.modal-enter-from .relative {
  transform: scale(0.9);
}

.modal-leave-to .relative {
  transform: scale(0.9);
}
</style>