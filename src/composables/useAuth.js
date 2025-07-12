import { ref, computed } from 'vue'
import { supabase } from '../lib/supabaseClient'
import { useRouter } from 'vue-router'
import { useAuthDebug } from './useAuthDebug'

const session = ref(null)
const loading = ref(true)
const { log: debugLog } = useAuthDebug()

export function useAuth() {
  const router = useRouter()
  
  const user = computed(() => session.value?.user || null)
  const isAuthenticated = computed(() => !!session.value)
  
  const initAuth = async () => {
    loading.value = true
    debugLog('initAuth started', { 
      hasAccessToken: window.location.hash.includes('access_token='),
      pathname: window.location.pathname 
    })
    
    // Set up auth state listener first
    supabase.auth.onAuthStateChange(async (event, newSession) => {
      debugLog('Auth state changed', { 
        event, 
        hasSession: !!newSession,
        userEmail: newSession?.user?.email,
        currentPath: window.location.hash
      })
      session.value = newSession
      
      if (event === 'SIGNED_IN' && newSession) {
        debugLog('User signed in successfully, preparing redirect')
        // Clean up the URL after successful sign in
        if (window.location.hash.includes('access_token=')) {
          window.history.replaceState(null, '', `${window.location.pathname}#/`)
          debugLog('URL cleaned after sign in')
        }
        // Small delay to ensure state is updated
        setTimeout(() => {
          debugLog('Redirecting to dashboard', { currentRoute: router.currentRoute.value.path })
          router.replace('/dashboard')
        }, 100)
      } else if (event === 'SIGNED_OUT') {
        debugLog('User signed out')
        session.value = null
      }
    })
    
    // Check if we have OAuth params in the URL
    if (window.location.hash.includes('access_token=')) {
      debugLog('OAuth callback detected, processing...')
      // For hash routing, we need to manually extract and process the tokens
      // The hash contains Vue Router path + OAuth params, so we need to extract properly
      const hashFragment = window.location.hash
      debugLog('Full hash fragment', { hashFragment })
      
      // Extract just the OAuth params part (everything after access_token=)
      const tokenMatch = hashFragment.match(/access_token=([^&]+)/)
      const refreshMatch = hashFragment.match(/refresh_token=([^&]+)/)
      
      const accessToken = tokenMatch ? tokenMatch[1] : null
      const refreshToken = refreshMatch ? refreshMatch[1] : null
      
      debugLog('Extracted tokens', { 
        hasAccessToken: !!accessToken,
        hasRefreshToken: !!refreshToken,
        accessTokenLength: accessToken?.length || 0,
        refreshTokenLength: refreshToken?.length || 0
      })
      
      if (accessToken && refreshToken) {
        debugLog('Setting session from OAuth tokens')
        try {
          const { data: sessionData, error: sessionError } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken
          })
          
          if (sessionError) {
            debugLog('Error setting session from OAuth', { 
              error: sessionError.message,
              errorCode: sessionError.status,
              errorDetails: sessionError
            })
          } else {
            debugLog('Session set from OAuth successfully', { 
              hasSession: !!sessionData.session,
              userEmail: sessionData.session?.user?.email,
              sessionId: sessionData.session?.access_token?.slice(0, 10) + '...'
            })
            session.value = sessionData.session
            
            // Clean up the URL immediately after successful session creation
            window.history.replaceState(null, '', `${window.location.pathname}#/`)
            debugLog('URL cleaned after OAuth success')
          }
        } catch (error) {
          debugLog('Exception setting session', { 
            error: error.message,
            stack: error.stack
          })
        }
      } else {
        debugLog('Missing tokens for session creation', {
          hasAccessToken: !!accessToken,
          hasRefreshToken: !!refreshToken
        })
      }
    }
    
    // Get initial session (in case we already have one)
    debugLog('Getting initial session')
    const { data, error } = await supabase.auth.getSession()
    debugLog('Initial session result', { 
      hasSession: !!data.session,
      error: error?.message,
      userEmail: data.session?.user?.email 
    })
    
    // Only update session if we don't already have one from OAuth
    if (!session.value && data.session) {
      session.value = data.session
    }
    
    loading.value = false
    debugLog('initAuth completed', { isAuthenticated: !!session.value })
  }
  
  const signInWithGoogle = async () => {
    debugLog('Starting Google sign in', {
      redirectTo: `${window.location.origin}${import.meta.env.BASE_URL}`
    })
    
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}${import.meta.env.BASE_URL}`
      }
    })
    
    if (error) {
      debugLog('Google sign in error', { error: error.message })
      console.error('Error signing in with Google:', error)
      throw error
    } else {
      debugLog('Google sign in initiated, redirecting to Google')
    }
  }
  
  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) {
      console.error('Error signing out:', error)
      throw error
    }
    router.push('/')
  }
  
  // Debug helper - expose through window for console access
  if (import.meta.env.DEV) {
    window.authDebug = {
      printLogs: () => {
        const { printLogs } = useAuthDebug()
        printLogs()
      },
      clearLogs: () => {
        const { clearLogs } = useAuthDebug()
        clearLogs()
        console.log('Auth debug logs cleared')
      },
      getSession: async () => {
        const { data } = await supabase.auth.getSession()
        console.log('Current session:', data.session)
        return data.session
      },
      getUser: async () => {
        const { data } = await supabase.auth.getUser()
        console.log('Current user:', data.user)
        return data.user
      }
    }
  }
  
  return {
    user,
    session,
    loading,
    isAuthenticated,
    initAuth,
    signInWithGoogle,
    signOut
  }
}