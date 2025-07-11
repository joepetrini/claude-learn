<template>
  <div v-if="isOpen" class="fixed inset-0 z-50 overflow-y-auto" @click.self="close">
    <div class="flex items-center justify-center min-h-screen p-4">
      <div class="fixed inset-0 bg-gray-900 bg-opacity-50 transition-opacity"></div>
      
      <div class="relative bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[80vh] overflow-hidden">
        <!-- Header -->
        <div class="sticky top-0 bg-white border-b border-gray-200 px-6 py-4">
          <div class="flex items-center justify-between">
            <h2 class="text-2xl font-bold text-gray-900">Keyboard Shortcuts</h2>
            <button @click="close" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>
        
        <!-- Content -->
        <div class="px-6 py-4 overflow-y-auto max-h-[60vh]">
          <!-- Global Shortcuts -->
          <div class="mb-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">Global Navigation</h3>
            <div class="space-y-2">
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Go to Home</span>
                <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">h</kbd>
              </div>
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Open Search</span>
                <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">/</kbd>
              </div>
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Show Help</span>
                <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">?</kbd>
              </div>
            </div>
          </div>
          
          <!-- Module Quick Access -->
          <div class="mb-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">Quick Module Access</h3>
            <div class="grid grid-cols-2 gap-2">
              <div v-for="n in 9" :key="n" class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Module {{ n }}</span>
                <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">{{ n }}</kbd>
              </div>
            </div>
          </div>
          
          <!-- Module Navigation -->
          <div class="mb-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">Within Modules</h3>
            <div class="space-y-2">
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Next Section</span>
                <div class="flex gap-2">
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">n</kbd>
                  <span class="text-gray-400">or</span>
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">→</kbd>
                </div>
              </div>
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Previous Section</span>
                <div class="flex gap-2">
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">p</kbd>
                  <span class="text-gray-400">or</span>
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">←</kbd>
                </div>
              </div>
            </div>
          </div>
          
          <!-- Quiz Shortcuts -->
          <div class="mb-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-3">During Quizzes</h3>
            <div class="space-y-2">
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Select Answer A-D</span>
                <div class="flex gap-2">
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">1</kbd>
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">2</kbd>
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">3</kbd>
                  <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">4</kbd>
                </div>
              </div>
              <div class="flex items-center justify-between py-2 px-3 rounded hover:bg-gray-50">
                <span class="text-gray-700">Continue/Next</span>
                <kbd class="px-2 py-1 text-sm bg-gray-100 rounded">Enter</kbd>
              </div>
            </div>
          </div>
          
          <!-- Vim Mode -->
          <div class="p-4 bg-gray-50 rounded-lg">
            <p class="text-sm text-gray-600">
              <strong>Vim users:</strong> You can also use <kbd class="px-2 py-1 text-xs bg-gray-200 rounded">j</kbd> and <kbd class="px-2 py-1 text-xs bg-gray-200 rounded">k</kbd> for navigation within modules.
            </p>
          </div>
        </div>
        
        <!-- Footer -->
        <div class="sticky bottom-0 bg-gray-50 px-6 py-3 border-t border-gray-200">
          <p class="text-sm text-gray-600 text-center">
            Press <kbd class="px-2 py-1 text-xs bg-gray-200 rounded">Esc</kbd> to close
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

const props = defineProps({
  isOpen: Boolean
})

const emit = defineEmits(['close'])

const close = () => {
  emit('close')
}

const handleEscape = (event) => {
  if (event.key === 'Escape' && props.isOpen) {
    close()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleEscape)
})
</script>

<style scoped>
kbd {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Consolas, "Liberation Mono", Menlo, monospace;
}
</style>