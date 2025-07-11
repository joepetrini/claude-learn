<template>
  <transition
    name="page"
    mode="out-in"
    @enter="onEnter"
    @leave="onLeave"
  >
    <slot />
  </transition>
</template>

<script setup>
const onEnter = (el) => {
  el.style.opacity = '0'
  el.style.transform = 'translateY(10px)'
}

const onLeave = (el) => {
  el.style.opacity = '0'
  el.style.transform = 'translateY(-10px)'
}
</script>

<style scoped>
.page-enter-active,
.page-leave-active {
  transition: all 0.3s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.page-enter-to,
.page-leave-from {
  opacity: 1;
  transform: translateY(0);
}
</style>