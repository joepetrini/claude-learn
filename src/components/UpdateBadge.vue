<template>
  <span 
    v-if="show"
    :class="badgeClasses"
    class="inline-flex items-center px-2 py-1 text-xs font-semibold rounded-full"
  >
    {{ label }}
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: 'new',
    validator: (value) => ['new', 'updated'].includes(value)
  },
  size: {
    type: String,
    default: 'sm',
    validator: (value) => ['xs', 'sm', 'md'].includes(value)
  },
  show: {
    type: Boolean,
    default: true
  }
})

const label = computed(() => {
  return props.type === 'new' ? 'NEW' : 'UPDATED'
})

const badgeClasses = computed(() => {
  const baseClasses = []
  
  // Color classes based on type
  if (props.type === 'new') {
    baseClasses.push('bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200')
  } else {
    baseClasses.push('bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200')
  }
  
  // Size classes
  switch (props.size) {
    case 'xs':
      baseClasses.push('text-xs px-1.5 py-0.5')
      break
    case 'md':
      baseClasses.push('text-sm px-3 py-1.5')
      break
    default: // sm
      baseClasses.push('text-xs px-2 py-1')
  }
  
  return baseClasses.join(' ')
})
</script>