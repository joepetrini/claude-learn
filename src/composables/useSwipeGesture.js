import { ref, onMounted, onUnmounted } from 'vue'

export function useSwipeGesture(element, options = {}) {
  const {
    threshold = 50,
    onSwipeLeft = () => {},
    onSwipeRight = () => {},
    onSwipeUp = () => {},
    onSwipeDown = () => {}
  } = options

  const touchStartX = ref(0)
  const touchStartY = ref(0)
  const touchEndX = ref(0)
  const touchEndY = ref(0)

  const handleTouchStart = (e) => {
    touchStartX.value = e.changedTouches[0].screenX
    touchStartY.value = e.changedTouches[0].screenY
  }

  const handleTouchEnd = (e) => {
    touchEndX.value = e.changedTouches[0].screenX
    touchEndY.value = e.changedTouches[0].screenY
    handleGesture()
  }

  const handleGesture = () => {
    const deltaX = touchEndX.value - touchStartX.value
    const deltaY = touchEndY.value - touchStartY.value
    const absDeltaX = Math.abs(deltaX)
    const absDeltaY = Math.abs(deltaY)

    // Horizontal swipe
    if (absDeltaX > absDeltaY && absDeltaX > threshold) {
      if (deltaX > 0) {
        onSwipeRight()
      } else {
        onSwipeLeft()
      }
    }
    // Vertical swipe
    else if (absDeltaY > threshold) {
      if (deltaY > 0) {
        onSwipeDown()
      } else {
        onSwipeUp()
      }
    }
  }

  const enable = () => {
    const el = element.value || element
    if (el) {
      el.addEventListener('touchstart', handleTouchStart, { passive: true })
      el.addEventListener('touchend', handleTouchEnd, { passive: true })
    }
  }

  const disable = () => {
    const el = element.value || element
    if (el) {
      el.removeEventListener('touchstart', handleTouchStart)
      el.removeEventListener('touchend', handleTouchEnd)
    }
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