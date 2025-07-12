<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <main class="max-w-4xl mx-auto px-4 py-8">
      <div class="bg-white rounded-lg shadow-md p-6">
        <h1 class="text-2xl font-bold text-gray-900 mb-4">Welcome to Claude Learn!</h1>
        
        <div v-if="user" class="mb-6">
          <p class="text-gray-600">
            Logged in as: <span class="font-medium">{{ user.email }}</span>
          </p>
        </div>
        
        <div class="prose max-w-none">
          <p class="text-gray-700">
            You're now authenticated and ready to start learning how to effectively use Claude Code for Python/Django development.
          </p>
          
          <h2 class="text-xl font-semibold mt-6 mb-3">Get Started</h2>
          <ul class="space-y-2">
            <li>
              <router-link to="/" class="text-blue-600 hover:text-blue-800">
                Browse all learning modules
              </router-link>
            </li>
            <li>
              <router-link to="/module/1" class="text-blue-600 hover:text-blue-800">
                Start with Module 1: Getting Started with Claude Code
              </router-link>
            </li>
            <li>
              <router-link to="/cheatsheet" class="text-blue-600 hover:text-blue-800">
                View the Claude Code cheat sheet
              </router-link>
            </li>
          </ul>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import Navigation from '../components/Navigation.vue'
import { useAuth } from '../composables/useAuth'
import { useSupabaseProgress } from '../composables/useSupabaseProgress'

const { user } = useAuth()
const { loadProgress } = useSupabaseProgress()

// Load user progress when dashboard loads
onMounted(async () => {
  await loadProgress()
})
</script>