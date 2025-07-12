import { ref, computed } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useAuth } from './useAuth'

const profile = ref({
  id: null,
  email: '',
  full_name: '',
  avatar_url: '',
  is_admin: false,
  created_at: null,
  updated_at: null
})

const isLoading = ref(false)
const error = ref(null)

export function useProfile() {
  const { user } = useAuth()

  // Load user profile
  async function loadProfile() {
    if (!user.value) {
      error.value = 'User not authenticated'
      return
    }

    isLoading.value = true
    error.value = null

    try {
      console.log('[Profile] Loading profile for user:', user.value.id)

      const { data, error: profileError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.value.id)
        .single()

      if (profileError) {
        if (profileError.code === 'PGRST116') {
          // Profile doesn't exist, create it
          console.log('[Profile] Profile not found, creating new profile')
          await createProfile()
        } else {
          throw profileError
        }
      } else {
        profile.value = data
        console.log('[Profile] Profile loaded successfully')
      }

    } catch (err) {
      console.error('[Profile] Failed to load profile:', err)
      error.value = err.message || 'Failed to load profile'
    } finally {
      isLoading.value = false
    }
  }

  // Create new profile from auth user data
  async function createProfile() {
    if (!user.value) {
      throw new Error('User not authenticated')
    }

    try {
      const newProfile = {
        id: user.value.id,
        email: user.value.email,
        full_name: user.value.user_metadata?.full_name || user.value.user_metadata?.name || '',
        avatar_url: user.value.user_metadata?.avatar_url || '',
        is_admin: false
      }

      const { data, error: createError } = await supabase
        .from('profiles')
        .insert(newProfile)
        .select()
        .single()

      if (createError) throw createError

      profile.value = data
      console.log('[Profile] Profile created successfully')

    } catch (err) {
      console.error('[Profile] Failed to create profile:', err)
      throw err
    }
  }

  // Update profile
  async function updateProfile(updates) {
    if (!user.value || !profile.value.id) {
      error.value = 'User not authenticated or profile not loaded'
      return false
    }

    isLoading.value = true
    error.value = null

    try {
      console.log('[Profile] Updating profile with:', updates)

      // Validate updates
      const allowedFields = ['full_name', 'avatar_url']
      const sanitizedUpdates = {}
      
      Object.keys(updates).forEach(key => {
        if (allowedFields.includes(key) && updates[key] !== undefined) {
          sanitizedUpdates[key] = updates[key]
        }
      })

      if (Object.keys(sanitizedUpdates).length === 0) {
        throw new Error('No valid fields to update')
      }

      const { data, error: updateError } = await supabase
        .from('profiles')
        .update({
          ...sanitizedUpdates,
          updated_at: new Date().toISOString()
        })
        .eq('id', user.value.id)
        .select()
        .single()

      if (updateError) throw updateError

      profile.value = data
      console.log('[Profile] Profile updated successfully')
      return true

    } catch (err) {
      console.error('[Profile] Failed to update profile:', err)
      error.value = err.message || 'Failed to update profile'
      return false
    } finally {
      isLoading.value = false
    }
  }

  // Upload avatar image
  async function uploadAvatar(file) {
    if (!user.value) {
      error.value = 'User not authenticated'
      return null
    }

    // Enhanced file validation
    const ALLOWED_MIME_TYPES = [
      'image/jpeg',
      'image/png', 
      'image/gif',
      'image/webp'
    ]

    if (!file || !ALLOWED_MIME_TYPES.includes(file.type)) {
      error.value = 'Only JPEG, PNG, GIF, and WebP images are allowed'
      return null
    }

    // Check file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      error.value = 'Image must be less than 2MB'
      return null
    }

    isLoading.value = true
    error.value = null

    try {
      const fileExt = file.name.split('.').pop()
      const secureFileName = `${user.value.id}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}.${fileExt}`
      const filePath = `avatars/${secureFileName}`

      console.log('[Profile] Uploading avatar:', filePath)

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('avatars')
        .upload(filePath, file, {
          upsert: true
        })

      if (uploadError) {
        // If storage bucket doesn't exist, provide helpful error
        if (uploadError.message.includes('not found') || uploadError.message.includes('bucket')) {
          throw new Error('Avatar storage not configured. Please set up the "avatars" storage bucket in Supabase.')
        }
        throw uploadError
      }

      // Get public URL
      const { data: urlData } = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath)

      const avatarUrl = urlData.publicUrl

      // Update profile with new avatar URL
      const updateSuccess = await updateProfile({ avatar_url: avatarUrl })
      
      if (updateSuccess) {
        console.log('[Profile] Avatar uploaded and profile updated')
        return avatarUrl
      } else {
        throw new Error('Failed to update profile with new avatar')
      }

    } catch (err) {
      console.error('[Profile] Failed to upload avatar:', err)
      error.value = err.message || 'Failed to upload avatar'
      return null
    } finally {
      isLoading.value = false
    }
  }

  // Delete current avatar
  async function deleteAvatar() {
    if (!profile.value.avatar_url) {
      return true
    }

    isLoading.value = true
    error.value = null

    try {
      // Extract file path from URL
      const url = new URL(profile.value.avatar_url)
      const filePath = url.pathname.split('/storage/v1/object/public/avatars/')[1]

      if (filePath) {
        console.log('[Profile] Deleting avatar:', filePath)
        
        const { error: deleteError } = await supabase.storage
          .from('avatars')
          .remove([filePath])

        if (deleteError) {
          console.warn('[Profile] Failed to delete avatar file:', deleteError)
          // Continue anyway to clear the URL from profile
        }
      }

      // Update profile to remove avatar URL
      const updateSuccess = await updateProfile({ avatar_url: null })
      
      if (updateSuccess) {
        console.log('[Profile] Avatar deleted and profile updated')
        return true
      } else {
        throw new Error('Failed to update profile after avatar deletion')
      }

    } catch (err) {
      console.error('[Profile] Failed to delete avatar:', err)
      error.value = err.message || 'Failed to delete avatar'
      return false
    } finally {
      isLoading.value = false
    }
  }

  // Computed properties
  const displayName = computed(() => {
    return profile.value.full_name || profile.value.email || 'User'
  })

  const initials = computed(() => {
    const name = displayName.value
    return name.split(' ')
      .map(word => word.charAt(0))
      .join('')
      .toUpperCase()
      .slice(0, 2)
  })

  const hasAvatar = computed(() => {
    return !!profile.value.avatar_url
  })

  return {
    // State
    profile,
    isLoading,
    error,
    
    // Computed
    displayName,
    initials,
    hasAvatar,
    
    // Methods
    loadProfile,
    updateProfile,
    uploadAvatar,
    deleteAvatar
  }
}