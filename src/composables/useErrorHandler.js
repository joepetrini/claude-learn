import { ref, computed } from 'vue'

// Global error state
const errors = ref([])
const notifications = ref([])

export function useErrorHandler() {
  
  // Add error with automatic cleanup
  function addError(error, context = '', duration = 5000) {
    const errorItem = {
      id: Date.now() + Math.random(),
      message: formatErrorMessage(error),
      context,
      timestamp: new Date(),
      type: 'error'
    }
    
    errors.value.push(errorItem)
    console.error(`[Error Handler] ${context}:`, error)
    
    // Auto-remove after duration
    if (duration > 0) {
      setTimeout(() => {
        removeError(errorItem.id)
      }, duration)
    }
    
    return errorItem.id
  }
  
  // Add success notification
  function addSuccess(message, duration = 3000) {
    const notification = {
      id: Date.now() + Math.random(),
      message,
      type: 'success',
      timestamp: new Date()
    }
    
    notifications.value.push(notification)
    
    if (duration > 0) {
      setTimeout(() => {
        removeNotification(notification.id)
      }, duration)
    }
    
    return notification.id
  }
  
  // Add info notification
  function addInfo(message, duration = 4000) {
    const notification = {
      id: Date.now() + Math.random(),
      message,
      type: 'info',
      timestamp: new Date()
    }
    
    notifications.value.push(notification)
    
    if (duration > 0) {
      setTimeout(() => {
        removeNotification(notification.id)
      }, duration)
    }
    
    return notification.id
  }
  
  // Remove specific error
  function removeError(id) {
    const index = errors.value.findIndex(e => e.id === id)
    if (index > -1) {
      errors.value.splice(index, 1)
    }
  }
  
  // Remove specific notification
  function removeNotification(id) {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  }
  
  // Clear all errors
  function clearErrors() {
    errors.value = []
  }
  
  // Clear all notifications
  function clearNotifications() {
    notifications.value = []
  }
  
  // Clear everything
  function clearAll() {
    clearErrors()
    clearNotifications()
  }
  
  // Format error message for display
  function formatErrorMessage(error) {
    if (typeof error === 'string') {
      return error
    }
    
    if (error?.message) {
      return error.message
    }
    
    if (error?.error?.message) {
      return error.error.message
    }
    
    // Handle Supabase errors
    if (error?.code) {
      switch (error.code) {
        case '23505':
          return 'This item already exists'
        case '23503':
          return 'Required data is missing'
        case 'PGRST116':
          return 'Item not found'
        case 'PGRST204':
          return 'Database configuration error'
        case '42P17':
          return 'Database permission error'
        default:
          return error.message || 'An unexpected error occurred'
      }
    }
    
    // Handle network errors
    if (error?.name === 'TypeError' && error?.message?.includes('fetch')) {
      return 'Network connection error. Please check your internet connection.'
    }
    
    return 'An unexpected error occurred'
  }
  
  // Handle async operations with error catching
  async function handleAsync(operation, context = '', successMessage = null) {
    try {
      const result = await operation()
      
      if (successMessage) {
        addSuccess(successMessage)
      }
      
      return { success: true, data: result, error: null }
    } catch (error) {
      const errorId = addError(error, context)
      return { success: false, data: null, error, errorId }
    }
  }
  
  // Retry operation with exponential backoff
  async function retry(operation, maxAttempts = 3, delay = 1000, context = '') {
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation()
      } catch (error) {
        if (attempt === maxAttempts) {
          addError(error, `${context} (after ${maxAttempts} attempts)`)
          throw error
        }
        
        console.warn(`[Error Handler] ${context} attempt ${attempt} failed, retrying...`, error)
        await new Promise(resolve => setTimeout(resolve, delay * attempt))
      }
    }
  }
  
  // Computed properties
  const hasErrors = computed(() => errors.value.length > 0)
  const hasNotifications = computed(() => notifications.value.length > 0)
  const latestError = computed(() => errors.value[errors.value.length - 1])
  const latestNotification = computed(() => notifications.value[notifications.value.length - 1])
  
  return {
    // State
    errors,
    notifications,
    
    // Computed
    hasErrors,
    hasNotifications,
    latestError,
    latestNotification,
    
    // Methods
    addError,
    addSuccess,
    addInfo,
    removeError,
    removeNotification,
    clearErrors,
    clearNotifications,
    clearAll,
    handleAsync,
    retry,
    formatErrorMessage
  }
}

// Global error handler instance
export const globalErrorHandler = useErrorHandler()