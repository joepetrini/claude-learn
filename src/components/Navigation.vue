<template>
  <nav class="bg-white shadow-sm border-b border-gray-200">
    <div class="container mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <!-- Logo/Home link -->
        <router-link to="/" class="flex items-center space-x-2">
          <span class="text-xl font-bold text-gray-900">Claude Learn</span>
        </router-link>
        
        <!-- Navigation items -->
        <div class="flex items-center space-x-4">
          <router-link
            v-if="isAuthenticated"
            to="/dashboard"
            class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
          >
            Dashboard
          </router-link>
          
          <router-link
            v-if="isAuthenticated"
            to="/cheatsheet"
            class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
          >
            Cheat Sheet
          </router-link>
          
          <router-link
            v-if="isAuthenticated && isAdmin"
            to="/admin"
            class="text-purple-700 hover:text-purple-900 px-3 py-2 rounded-md text-sm font-medium"
          >
            Admin
          </router-link>
          
          <!-- User dropdown -->
          <div v-if="isAuthenticated" class="relative">
            <button
              @click="dropdownOpen = !dropdownOpen"
              class="flex items-center text-sm font-medium text-gray-700 hover:text-gray-900 focus:outline-none"
            >
              <span class="mr-2">{{ user?.email }}</span>
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            
            <!-- Dropdown menu -->
            <transition name="dropdown">
              <div
                v-if="dropdownOpen"
                class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50"
              >
                <router-link
                  to="/profile"
                  @click="dropdownOpen = false"
                  class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Profile Settings
                </router-link>
                <hr class="my-1">
                <button
                  @click="handleLogout"
                  class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                >
                  Sign out
                </button>
              </div>
            </transition>
          </div>
          
          <!-- Login button -->
          <router-link
            v-else
            to="/login"
            class="bg-blue-600 text-white hover:bg-blue-700 px-4 py-2 rounded-md text-sm font-medium"
          >
            Sign in
          </router-link>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useAdmin } from '../composables/useAdmin'

const { user, isAuthenticated, signOut } = useAuth()
const { isAdmin, checkAdminStatus } = useAdmin()
const dropdownOpen = ref(false)

const handleLogout = async () => {
  dropdownOpen.value = false
  await signOut()
}

onMounted(async () => {
  if (isAuthenticated.value) {
    await checkAdminStatus()
  }
})
</script>