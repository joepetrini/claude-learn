<template>
  <teleport to="body">
    <!-- Notifications Container -->
    <div class="fixed top-4 right-4 z-50 space-y-3 max-w-sm">
      <!-- Success Notifications -->
      <transition-group name="notification" tag="div">
        <div
          v-for="notification in successNotifications"
          :key="notification.id"
          class="bg-green-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-start"
        >
          <svg class="w-5 h-5 mr-3 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
          </svg>
          <div class="flex-1">
            <p class="font-medium">{{ notification.message }}</p>
          </div>
          <button
            @click="removeNotification(notification.id)"
            class="ml-3 text-green-200 hover:text-white"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </transition-group>

      <!-- Info Notifications -->
      <transition-group name="notification" tag="div">
        <div
          v-for="notification in infoNotifications"
          :key="notification.id"
          class="bg-blue-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-start"
        >
          <svg class="w-5 h-5 mr-3 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
          </svg>
          <div class="flex-1">
            <p class="font-medium">{{ notification.message }}</p>
          </div>
          <button
            @click="removeNotification(notification.id)"
            class="ml-3 text-blue-200 hover:text-white"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </transition-group>

      <!-- Error Notifications -->
      <transition-group name="notification" tag="div">
        <div
          v-for="error in errors"
          :key="error.id"
          class="bg-red-500 text-white px-6 py-4 rounded-lg shadow-lg flex items-start"
        >
          <svg class="w-5 h-5 mr-3 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
          </svg>
          <div class="flex-1">
            <p class="font-medium">{{ error.message }}</p>
            <p v-if="error.context" class="text-red-200 text-sm mt-1">{{ error.context }}</p>
          </div>
          <button
            @click="removeError(error.id)"
            class="ml-3 text-red-200 hover:text-white"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </transition-group>
    </div>
  </teleport>
</template>

<script setup>
import { computed } from 'vue'
import { globalErrorHandler } from '../composables/useErrorHandler'

const { errors, notifications, removeError, removeNotification } = globalErrorHandler

// Filter notifications by type
const successNotifications = computed(() => 
  notifications.value.filter(n => n.type === 'success')
)

const infoNotifications = computed(() => 
  notifications.value.filter(n => n.type === 'info')
)
</script>

<style scoped>
.notification-enter-active,
.notification-leave-active {
  transition: all 0.3s ease;
}

.notification-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.notification-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

.notification-move {
  transition: transform 0.3s ease;
}
</style>