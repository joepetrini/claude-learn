import { ref, onMounted, onUnmounted } from 'vue'

/**
 * Composable for managing global keyboard shortcuts
 */
export function useKeyboardShortcuts() {
  const isCommandPaletteOpen = ref(false)
  const activeModal = ref(null)

  // Keyboard shortcut handlers
  const shortcuts = {
    // Command Palette - Cmd+K or Ctrl+K
    'cmd+k': () => {
      isCommandPaletteOpen.value = true
    },
    'ctrl+k': () => {
      isCommandPaletteOpen.value = true
    },
    
    // Navigation shortcuts
    'ctrl+h': () => {
      if (!activeModal.value) {
        window.location.href = '/'
      }
    },
    'cmd+h': () => {
      if (!activeModal.value) {
        window.location.href = '/'
      }
    },
    
    // Quick access to favorites
    'ctrl+f': () => {
      if (!activeModal.value) {
        openFavorites()
      }
    },
    'cmd+f': () => {
      if (!activeModal.value) {
        openFavorites()
      }
    },
    
    // Recent resources
    'ctrl+r': () => {
      if (!activeModal.value) {
        openRecent()
      }
    },
    'cmd+r': () => {
      if (!activeModal.value) {
        openRecent()
      }
    },
    
    // All courses
    'ctrl+shift+c': () => {
      if (!activeModal.value) {
        window.location.href = '/'
      }
    },
    'cmd+shift+c': () => {
      if (!activeModal.value) {
        window.location.href = '/'
      }
    },
    
    // Close any modal with Escape
    'escape': () => {
      if (isCommandPaletteOpen.value) {
        isCommandPaletteOpen.value = false
      } else if (activeModal.value) {
        closeActiveModal()
      }
    },
    
    // Help
    'ctrl+/': () => {
      if (!activeModal.value) {
        showKeyboardShortcuts()
      }
    },
    'cmd+/': () => {
      if (!activeModal.value) {
        showKeyboardShortcuts()
      }
    }
  }

  // Key event handler
  const handleKeyDown = (event) => {
    // Don't trigger shortcuts when typing in inputs/textareas
    if (
      event.target.tagName === 'INPUT' ||
      event.target.tagName === 'TEXTAREA' ||
      event.target.contentEditable === 'true'
    ) {
      // Allow Escape and Cmd/Ctrl+K even in inputs
      if (event.key === 'Escape' || 
          ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k')) {
        // Continue to process these shortcuts
      } else {
        return
      }
    }

    const key = event.key.toLowerCase()
    const modifiers = []
    
    if (event.ctrlKey) modifiers.push('ctrl')
    if (event.metaKey) modifiers.push('cmd')
    if (event.shiftKey) modifiers.push('shift')
    if (event.altKey) modifiers.push('alt')
    
    const shortcut = modifiers.length > 0 ? `${modifiers.join('+')}+${key}` : key
    
    if (shortcuts[shortcut]) {
      event.preventDefault()
      shortcuts[shortcut]()
    }
  }

  // Command palette controls
  const openCommandPalette = () => {
    isCommandPaletteOpen.value = true
  }

  const closeCommandPalette = () => {
    isCommandPaletteOpen.value = false
  }

  // Modal management
  const registerModal = (modalName) => {
    activeModal.value = modalName
  }

  const unregisterModal = (modalName) => {
    if (activeModal.value === modalName) {
      activeModal.value = null
    }
  }

  const closeActiveModal = () => {
    // Emit a global event that modals can listen to
    window.dispatchEvent(new CustomEvent('close-active-modal'))
    activeModal.value = null
  }

  // Quick action handlers
  const openFavorites = () => {
    // This would open a favorites modal or navigate to favorites page
    isCommandPaletteOpen.value = true
    // The command palette will show favorites by default
  }

  const openRecent = () => {
    // This would open a recent resources modal
    isCommandPaletteOpen.value = true
    // The command palette will show recent resources
  }

  const showKeyboardShortcuts = () => {
    // This would show a help modal with all shortcuts
    console.log('Show keyboard shortcuts help')
    // For now, just open command palette
    isCommandPaletteOpen.value = true
  }

  // Get all available shortcuts for help display
  const getAllShortcuts = () => {
    return [
      {
        category: 'Navigation',
        shortcuts: [
          { keys: ['Cmd+K', 'Ctrl+K'], description: 'Open command palette' },
          { keys: ['Cmd+H', 'Ctrl+H'], description: 'Go to home' },
          { keys: ['Cmd+Shift+C', 'Ctrl+Shift+C'], description: 'View all courses' },
          { keys: ['Escape'], description: 'Close modal or palette' }
        ]
      },
      {
        category: 'Resources',
        shortcuts: [
          { keys: ['Cmd+F', 'Ctrl+F'], description: 'Open favorites' },
          { keys: ['Cmd+R', 'Ctrl+R'], description: 'Open recent resources' }
        ]
      },
      {
        category: 'Help',
        shortcuts: [
          { keys: ['Cmd+/', 'Ctrl+/'], description: 'Show keyboard shortcuts' }
        ]
      }
    ]
  }

  // Check if user is on Mac for display purposes
  const isMac = typeof navigator !== 'undefined' && 
    /Mac|iPod|iPhone|iPad/.test(navigator.platform)

  // Format shortcut for display
  const formatShortcut = (shortcut) => {
    if (isMac) {
      return shortcut.replace('ctrl', '⌃').replace('cmd', '⌘').replace('shift', '⇧').replace('alt', '⌥')
    }
    return shortcut.replace('cmd', 'Ctrl').replace('ctrl', 'Ctrl')
  }

  // Listen for custom events
  const handleCustomEvents = (event) => {
    if (event.type === 'open-command-palette') {
      isCommandPaletteOpen.value = true
    }
  }

  // Lifecycle
  onMounted(() => {
    document.addEventListener('keydown', handleKeyDown)
    window.addEventListener('open-command-palette', handleCustomEvents)
  })

  onUnmounted(() => {
    document.removeEventListener('keydown', handleKeyDown)
    window.removeEventListener('open-command-palette', handleCustomEvents)
  })

  return {
    // Command palette
    isCommandPaletteOpen,
    openCommandPalette,
    closeCommandPalette,
    
    // Modal management
    activeModal,
    registerModal,
    unregisterModal,
    closeActiveModal,
    
    // Quick actions
    openFavorites,
    openRecent,
    showKeyboardShortcuts,
    
    // Utilities
    getAllShortcuts,
    formatShortcut,
    isMac
  }
}