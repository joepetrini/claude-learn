# Supabase Google OAuth Implementation Guide

This document describes the working implementation of Google OAuth authentication using Supabase in a Vue 3 application with Vue Router hash mode.

## Architecture Overview

Our implementation handles the specific challenges of integrating OAuth redirects with Vue Router's hash mode routing. The key components work together to provide seamless authentication:

1. **Supabase Client**: Configured with environment variables
2. **Auth Composable**: Centralized authentication state management with debugging
3. **Protected Routes**: Navigation guards for authentication-required pages
4. **Manual Token Processing**: Handles OAuth callbacks in hash routing mode

## Implementation Details

### 1. Environment Configuration

```bash
# .env.local
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 2. Supabase Client Setup

```javascript
// src/lib/supabaseClient.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### 3. Authentication Composable

The core authentication logic is handled in `src/composables/useAuth.js`:

**Key Features:**
- Reactive session state management
- OAuth callback processing with manual token extraction
- Comprehensive debug logging for troubleshooting
- Automatic URL cleanup after authentication
- Router integration for redirects

**Critical Implementation Details:**

```javascript
// Handle OAuth callbacks in hash routing mode
if (window.location.hash.includes('access_token=')) {
  const hashFragment = window.location.hash
  
  // Extract tokens using regex (URLSearchParams doesn't work with hash routing)
  const tokenMatch = hashFragment.match(/access_token=([^&]+)/)
  const refreshMatch = hashFragment.match(/refresh_token=([^&]+)/)
  
  const accessToken = tokenMatch ? tokenMatch[1] : null
  const refreshToken = refreshMatch ? refreshMatch[1] : null
  
  if (accessToken && refreshToken) {
    // Manually set session since Supabase doesn't auto-process with hash routing
    const { data: sessionData, error } = await supabase.auth.setSession({
      access_token: accessToken,
      refresh_token: refreshToken
    })
    
    if (!error) {
      session.value = sessionData.session
      // Clean URL immediately
      window.history.replaceState(null, '', `${window.location.pathname}#/`)
    }
  }
}
```

### 4. Router Configuration

```javascript
// src/router/index.js
import { createRouter, createWebHashHistory } from 'vue-router'
import { supabase } from '../lib/supabaseClient'

const router = createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL), // Hash mode required
  routes: [
    { path: '/', component: Home },
    { path: '/login', component: Login },
    { path: '/dashboard', component: Dashboard, meta: { requiresAuth: true } },
    { path: '/:pathMatch(.*)*', component: Home } // Catch-all for OAuth callbacks
  ]
})

// Navigation guard for protected routes
router.beforeEach(async (to, from, next) => {
  if (to.meta.requiresAuth) {
    const { data } = await supabase.auth.getSession()
    if (!data.session) {
      next({ name: 'login', query: { redirect: to.fullPath } })
    } else {
      next()
    }
  } else {
    next()
  }
})
```

### 5. Application Integration

```javascript
// src/App.vue
import { onMounted } from 'vue'
import { useAuth } from './composables/useAuth'

const { initAuth } = useAuth()

onMounted(() => {
  initAuth() // Initialize auth state and handle OAuth callbacks
})
```

### 6. Login Component

```vue
<!-- src/views/Login.vue -->
<script setup>
import { useAuth } from '../composables/useAuth'

const { signInWithGoogle } = useAuth()

const handleGoogleLogin = async () => {
  try {
    await signInWithGoogle()
  } catch (error) {
    console.error('Login failed:', error)
  }
}
</script>

<template>
  <button @click="handleGoogleLogin" class="google-login-btn">
    Sign in with Google
  </button>
</template>
```

## Key Challenges Solved

### 1. Hash Routing vs OAuth Redirects

**Problem**: Vue Router's hash mode conflicts with OAuth callback URLs that contain tokens in hash fragments.

**Solution**: Manual token extraction using regex patterns instead of URLSearchParams, which cannot parse the complex hash format.

### 2. Session Establishment

**Problem**: Supabase doesn't automatically process OAuth tokens when using hash routing.

**Solution**: Detect OAuth callbacks, manually extract tokens, and call `supabase.auth.setSession()` to establish the user session.

### 3. URL Cleanup

**Problem**: OAuth tokens remain visible in the browser URL after authentication.

**Solution**: Use `window.history.replaceState()` to clean the URL immediately after successful authentication.

### 4. Debug Visibility

**Problem**: OAuth flow involves multiple redirects, making debugging difficult.

**Solution**: Implemented persistent localStorage-based logging that survives redirects, accessible via browser dev tools.

## OAuth Flow Sequence

1. User clicks "Sign in with Google"
2. `signInWithOAuth()` redirects to Google
3. User authenticates with Google
4. Google redirects to Supabase callback URL
5. Supabase redirects back to app with tokens in hash: `/#/access_token=...&refresh_token=...`
6. Vue app loads, `initAuth()` detects OAuth callback
7. Tokens extracted via regex and session established with `setSession()`
8. URL cleaned and user redirected to dashboard
9. `onAuthStateChange` event fires with SIGNED_IN status

## Debug Tools

Development builds include debug utilities accessible via browser console:

```javascript
// Print all auth debug logs
window.authDebug.printLogs()

// Clear debug logs
window.authDebug.clearLogs()

// Check current session
window.authDebug.getSession()

// Check current user
window.authDebug.getUser()
```

## Production Considerations

1. **Environment Variables**: Ensure production Supabase credentials are properly configured
2. **Site URL Configuration**: Set correct Site URL in Supabase dashboard for production domain
3. **Google OAuth Setup**: Configure production redirect URIs in Google Cloud Console
4. **Debug Logging**: Automatically disabled in production builds
5. **HTTPS Required**: OAuth requires HTTPS in production environments

This implementation provides a robust, debuggable OAuth flow that works seamlessly with Vue Router's hash mode while handling all the edge cases and challenges specific to single-page applications.