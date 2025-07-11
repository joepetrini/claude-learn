import { onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'

export function useKeyboardNavigation() {
  const router = useRouter()
  const route = useRoute()

  const shortcuts = {
    // Global navigation
    'h': () => router.push('/'),
    'H': () => router.push('/'),
    '/': () => {
      // Trigger search - emit a global event
      window.dispatchEvent(new CustomEvent('toggle-search'))
    },
    '?': () => {
      // Show help modal
      window.dispatchEvent(new CustomEvent('show-help'))
    },
    
    // Module navigation (1-8 for quick access)
    '1': () => navigateToModule('module_1'),
    '2': () => navigateToModule('module_2'),
    '3': () => navigateToModule('module_3'),
    '4': () => navigateToModule('module_4'),
    '5': () => navigateToModule('module_5'),
    '6': () => navigateToModule('module_6'),
    '7': () => navigateToModule('module_7'),
    '8': () => navigateToModule('module_8'),
    
    // Navigation within pages
    'n': () => navigateNext(),
    'p': () => navigatePrevious(),
    'j': () => navigateNext(), // Vim style
    'k': () => navigatePrevious(), // Vim style
  }

  const navigateToModule = (moduleId) => {
    router.push(`/module/${moduleId}`)
  }

  const navigateNext = () => {
    window.dispatchEvent(new CustomEvent('keyboard-next'))
  }

  const navigatePrevious = () => {
    window.dispatchEvent(new CustomEvent('keyboard-previous'))
  }

  const handleKeyPress = (event) => {
    // Don't trigger shortcuts when typing in inputs
    if (event.target.matches('input, textarea, select')) {
      return
    }

    // Don't trigger if meta keys are pressed
    if (event.metaKey || event.ctrlKey || event.altKey) {
      return
    }

    const key = event.key
    const handler = shortcuts[key]

    if (handler) {
      event.preventDefault()
      handler()
    }
  }

  const enable = () => {
    window.addEventListener('keydown', handleKeyPress)
  }

  const disable = () => {
    window.removeEventListener('keydown', handleKeyPress)
  }

  onMounted(() => {
    enable()
  })

  onUnmounted(() => {
    disable()
  })

  return {
    enable,
    disable
  }
}

// Module-specific keyboard navigation
export function useModuleKeyboard() {
  const handleModuleKeyboard = (event) => {
    // Handle arrow keys for module navigation
    if (event.key === 'ArrowLeft') {
      event.preventDefault()
      window.dispatchEvent(new CustomEvent('keyboard-previous'))
    } else if (event.key === 'ArrowRight') {
      event.preventDefault()
      window.dispatchEvent(new CustomEvent('keyboard-next'))
    }
  }

  onMounted(() => {
    window.addEventListener('keydown', handleModuleKeyboard)
  })

  onUnmounted(() => {
    window.removeEventListener('keydown', handleModuleKeyboard)
  })
}

// Quiz-specific keyboard navigation
export function useQuizKeyboard() {
  const selectAnswer = (index) => {
    window.dispatchEvent(new CustomEvent('quiz-select-answer', { detail: index }))
  }

  const handleQuizKeyboard = (event) => {
    // Don't trigger when typing in inputs
    if (event.target.matches('input, textarea, select')) {
      return
    }

    // Number keys 1-4 for answer selection
    if (event.key >= '1' && event.key <= '4') {
      event.preventDefault()
      const answerIndex = parseInt(event.key) - 1
      selectAnswer(answerIndex)
    }
    
    // Enter to continue after answering
    if (event.key === 'Enter') {
      event.preventDefault()
      window.dispatchEvent(new CustomEvent('quiz-continue'))
    }
  }

  onMounted(() => {
    window.addEventListener('keydown', handleQuizKeyboard)
  })

  onUnmounted(() => {
    window.removeEventListener('keydown', handleQuizKeyboard)
  })
}