<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <main class="max-w-4xl mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Profile Settings</h1>
        <p class="text-gray-600">Manage your account information and preferences</p>
      </div>

      <!-- Loading State -->
      <LoadingSkeletons v-if="isLoading && !profile.id" type="profile" />

      <!-- Profile Content -->
      <div v-else class="space-y-8">
        <!-- Profile Picture Section -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Profile Picture</h2>
          
          <div class="flex items-center space-x-6">
            <!-- Current Avatar -->
            <div class="relative">
              <img 
                v-if="hasAvatar" 
                :src="profile.avatar_url" 
                :alt="displayName"
                class="w-24 h-24 rounded-full object-cover border-4 border-white shadow-lg"
              >
              <div 
                v-else 
                class="w-24 h-24 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 border-4 border-white shadow-lg flex items-center justify-center"
              >
                <span class="text-white text-2xl font-bold">{{ initials }}</span>
              </div>
              
              <!-- Loading overlay -->
              <div 
                v-if="isLoading" 
                class="absolute inset-0 bg-black bg-opacity-50 rounded-full flex items-center justify-center"
              >
                <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-white"></div>
              </div>
            </div>

            <!-- Avatar Actions -->
            <div class="flex-1">
              <div class="space-y-3">
                <div>
                  <label class="block">
                    <span class="sr-only">Choose profile photo</span>
                    <input 
                      ref="fileInput"
                      type="file" 
                      accept="image/*"
                      @change="handleFileUpload"
                      class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                    >
                  </label>
                  <p class="text-xs text-gray-500 mt-1">
                    JPG, PNG or GIF. Max size 2MB.
                  </p>
                </div>
                
                <button 
                  v-if="hasAvatar"
                  @click="handleDeleteAvatar"
                  :disabled="isLoading"
                  class="text-red-600 hover:text-red-800 text-sm font-medium disabled:opacity-50"
                >
                  Remove photo
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Basic Information -->
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-6">Basic Information</h2>
          
          <form @submit.prevent="handleUpdateProfile" class="space-y-6">
            <!-- Full Name -->
            <div>
              <label for="fullName" class="block text-sm font-medium text-gray-700 mb-2">
                Full Name
              </label>
              <input 
                id="fullName"
                v-model="formData.full_name"
                type="text" 
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Enter your full name"
              >
            </div>

            <!-- Email (Read-only) -->
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                Email Address
              </label>
              <input 
                id="email"
                :value="profile.email"
                type="email" 
                readonly
                class="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-500 cursor-not-allowed"
              >
              <p class="text-xs text-gray-500 mt-1">
                Email cannot be changed. Contact support if you need to update your email.
              </p>
            </div>

            <!-- Account Info -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Account Created
                </label>
                <p class="text-gray-900">
                  {{ profile.created_at ? new Date(profile.created_at).toLocaleDateString() : 'N/A' }}
                </p>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Last Updated
                </label>
                <p class="text-gray-900">
                  {{ profile.updated_at ? new Date(profile.updated_at).toLocaleDateString() : 'N/A' }}
                </p>
              </div>
            </div>

            <!-- Admin Badge -->
            <div v-if="profile.is_admin" class="inline-block">
              <span class="px-3 py-1 bg-purple-100 text-purple-800 text-sm font-medium rounded-full">
                Admin User
              </span>
            </div>

            <!-- Submit Button -->
            <div class="flex justify-end">
              <button 
                type="submit"
                :disabled="isLoading || !hasChanges"
                class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {{ isLoading ? 'Saving...' : 'Save Changes' }}
              </button>
            </div>
          </form>
        </div>

        <!-- Danger Zone -->
        <div class="bg-white rounded-lg shadow-md p-6 border-l-4 border-red-500">
          <h2 class="text-xl font-semibold text-red-600 mb-4">Danger Zone</h2>
          <p class="text-gray-600 mb-4">
            These actions cannot be undone. Please be careful.
          </p>
          
          <div class="space-y-3">
            <button 
              @click="showDeleteConfirmation = true"
              class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
            >
              Delete Account
            </button>
          </div>
        </div>
      </div>


      <!-- Delete Confirmation Modal -->
      <div v-if="showDeleteConfirmation" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white rounded-lg p-6 max-w-md mx-4">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Delete Account</h3>
          <p class="text-gray-600 mb-6">
            This action cannot be undone. All your progress and data will be permanently deleted.
          </p>
          <div class="flex space-x-4">
            <button 
              @click="showDeleteConfirmation = false"
              class="flex-1 px-4 py-2 bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300"
            >
              Cancel
            </button>
            <button 
              @click="handleDeleteAccount"
              class="flex-1 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
            >
              Delete Account
            </button>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import Navigation from '../components/Navigation.vue'
import LoadingSkeletons from '../components/LoadingSkeletons.vue'
import { useProfile } from '../composables/useProfile'
import { globalErrorHandler } from '../composables/useErrorHandler'

const { 
  profile, 
  isLoading, 
  error, 
  displayName, 
  initials, 
  hasAvatar,
  loadProfile, 
  updateProfile, 
  uploadAvatar, 
  deleteAvatar 
} = useProfile()

const fileInput = ref(null)
const showDeleteConfirmation = ref(false)

// Form data for editing
const formData = ref({
  full_name: ''
})

// Check if form has changes
const hasChanges = computed(() => {
  return formData.value.full_name !== (profile.value.full_name || '')
})

// Watch profile changes to update form
watch(() => profile.value, (newProfile) => {
  if (newProfile) {
    formData.value.full_name = newProfile.full_name || ''
  }
}, { immediate: true, deep: true })

// Handle file upload
async function handleFileUpload(event) {
  const file = event.target.files[0]
  if (!file) return

  const avatarUrl = await uploadAvatar(file)
  if (avatarUrl) {
    globalErrorHandler.addSuccess('Profile picture updated successfully!')
    // Clear file input
    if (fileInput.value) {
      fileInput.value.value = ''
    }
  }
}

// Handle avatar deletion
async function handleDeleteAvatar() {
  const success = await deleteAvatar()
  if (success) {
    globalErrorHandler.addSuccess('Profile picture removed successfully!')
  }
}

// Handle profile update
async function handleUpdateProfile() {
  const updates = {
    full_name: formData.value.full_name.trim() || null
  }

  const success = await updateProfile(updates)
  if (success) {
    globalErrorHandler.addSuccess('Profile updated successfully!')
  }
}

// Handle account deletion (placeholder)
function handleDeleteAccount() {
  showDeleteConfirmation.value = false
  // Note: This would require additional backend implementation
  alert('Account deletion is not implemented in this demo. Contact support for account deletion.')
}


onMounted(async () => {
  await loadProfile()
})
</script>