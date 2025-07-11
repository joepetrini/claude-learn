<template>
  <transition
    appear
    @enter="onEnter"
    @leave="onLeave"
  >
    <div v-if="show" class="fixed inset-0 z-50 flex items-center justify-center pointer-events-none">
      <!-- Confetti particles -->
      <div class="absolute inset-0">
        <div
          v-for="i in 50"
          :key="i"
          class="confetti"
          :style="getConfettiStyle(i)"
        ></div>
      </div>
      
      <!-- Success icon -->
      <div class="success-icon">
        <svg class="w-32 h-32 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path 
            stroke-linecap="round" 
            stroke-linejoin="round" 
            stroke-width="2" 
            d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            class="check-path"
          />
        </svg>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  show: Boolean
})

const colors = ['#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#8b5cf6']

const getConfettiStyle = (index) => {
  const delay = Math.random() * 0.5
  const duration = 1 + Math.random() * 1
  const color = colors[Math.floor(Math.random() * colors.length)]
  const size = 8 + Math.random() * 8
  const startX = Math.random() * 100
  const endX = startX + (Math.random() - 0.5) * 50
  
  return {
    '--delay': `${delay}s`,
    '--duration': `${duration}s`,
    '--color': color,
    '--size': `${size}px`,
    '--start-x': `${startX}%`,
    '--end-x': `${endX}%`,
  }
}

const onEnter = (el) => {
  el.style.opacity = '0'
  el.offsetHeight // force reflow
  el.style.transition = 'opacity 0.3s'
  el.style.opacity = '1'
}

const onLeave = (el) => {
  el.style.transition = 'opacity 0.5s'
  el.style.opacity = '0'
}
</script>

<style scoped>
.success-icon {
  animation: scaleIn 0.5s ease-out;
}

@keyframes scaleIn {
  0% {
    transform: scale(0);
    opacity: 0;
  }
  50% {
    transform: scale(1.2);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.check-path {
  stroke-dasharray: 100;
  stroke-dashoffset: 100;
  animation: drawCheck 0.5s ease-out 0.3s forwards;
}

@keyframes drawCheck {
  to {
    stroke-dashoffset: 0;
  }
}

.confetti {
  position: absolute;
  width: var(--size);
  height: var(--size);
  background: var(--color);
  left: var(--start-x);
  top: -20px;
  opacity: 0;
  animation: confettiFall var(--duration) ease-out var(--delay) forwards;
}

@keyframes confettiFall {
  0% {
    transform: translateY(0) rotate(0deg);
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) rotate(720deg);
    opacity: 0;
    left: var(--end-x);
  }
}
</style>