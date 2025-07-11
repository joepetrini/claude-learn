<template>
  <div 
    class="transition-all duration-500 ease-out"
    :style="{ width: `${percentage}%` }"
  >
    <div class="h-full relative overflow-hidden">
      <!-- Animated stripe pattern -->
      <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-shimmer"></div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  value: {
    type: Number,
    required: true
  },
  max: {
    type: Number,
    required: true
  }
})

const percentage = computed(() => {
  if (props.max === 0) return 0
  return Math.min(100, Math.max(0, (props.value / props.max) * 100))
})
</script>

<style scoped>
@keyframes shimmer {
  0% {
    transform: translateX(-100%);
  }
  100% {
    transform: translateX(200%);
  }
}

.animate-shimmer {
  animation: shimmer 2s infinite;
}
</style>