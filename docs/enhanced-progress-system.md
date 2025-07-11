# Enhanced Progress & Update Detection System

## Challenge: Update Detection & Progress Recovery

### Current Limitations
- localStorage doesn't know about new modules until user visits
- Lost data means starting over
- No way to quickly mark modules as complete
- Different browsers = different progress

## Solution 1: Smart Update Detection

### Version Checking System
```javascript
// composables/useVersionCheck.js
export function useVersionCheck() {
  const CURRENT_VERSION = '2024.1' // Bumped when new modules added
  const lastKnownVersion = useStorage('lastKnownVersion', null)
  const lastCheckDate = useStorage('lastCheckDate', null)
  
  const checkForUpdates = async () => {
    // Always check on first visit or daily
    const shouldCheck = !lastCheckDate.value || 
      new Date() - new Date(lastCheckDate.value) > 86400000 // 24 hours
    
    if (shouldCheck) {
      const response = await fetch('/data/version.json')
      const { version, modules } = await response.json()
      
      if (version !== lastKnownVersion.value) {
        // New content available!
        return {
          hasUpdates: true,
          newModules: modules.filter(m => 
            m.releaseDate > lastKnownVersion.value
          )
        }
      }
      
      lastCheckDate.value = new Date().toISOString()
      lastKnownVersion.value = version
    }
    
    return { hasUpdates: false, newModules: [] }
  }
  
  return { checkForUpdates }
}
```

### Version Manifest File
```json
// public/data/version.json
{
  "version": "2024.1",
  "lastUpdated": "2024-03-15",
  "totalModules": 11,
  "coreModules": 8,
  "updateModules": 3,
  "latestModules": [
    {
      "id": "update_2024_q1",
      "title": "Q1 2024 Updates",
      "releaseDate": "2024-03-15"
    }
  ]
}
```

## Solution 2: Quick Progress Recovery

### Bulk Complete Feature
```vue
<template>
  <div class="max-w-4xl mx-auto p-6">
    <h2 class="text-2xl font-bold mb-6">Quick Progress Setup</h2>
    
    <!-- Scenario Selection -->
    <div class="bg-blue-50 p-4 rounded-lg mb-6">
      <p class="text-blue-900 mb-3">
        Lost your progress or using a new browser? Quickly mark your completed modules:
      </p>
    </div>
    
    <!-- Quick Actions -->
    <div class="space-y-4 mb-6">
      <button 
        @click="markAllCoreComplete"
        class="w-full p-4 bg-white rounded-lg shadow hover:shadow-md text-left"
      >
        <h3 class="font-semibold">I've completed all core modules</h3>
        <p class="text-sm text-gray-600">Mark modules 1-8 as complete</p>
      </button>
      
      <button 
        @click="showCustomSelection = true"
        class="w-full p-4 bg-white rounded-lg shadow hover:shadow-md text-left"
      >
        <h3 class="font-semibold">Select specific modules</h3>
        <p class="text-sm text-gray-600">Choose which modules you've completed</p>
      </button>
      
      <button 
        @click="importProgress"
        class="w-full p-4 bg-white rounded-lg shadow hover:shadow-md text-left"
      >
        <h3 class="font-semibold">Import progress backup</h3>
        <p class="text-sm text-gray-600">Restore from a progress code</p>
      </button>
    </div>
    
    <!-- Custom Selection -->
    <div v-if="showCustomSelection" class="bg-white p-6 rounded-lg shadow">
      <h3 class="font-semibold mb-4">Select Completed Modules</h3>
      
      <div class="space-y-2 max-h-96 overflow-y-auto">
        <label 
          v-for="module in allModules" 
          :key="module.id"
          class="flex items-center p-3 hover:bg-gray-50 rounded"
        >
          <input 
            type="checkbox" 
            v-model="selectedModules"
            :value="module.id"
            class="mr-3"
          >
          <div>
            <span class="font-medium">{{ module.title }}</span>
            <span class="text-sm text-gray-500 ml-2">
              ({{ module.estimatedTime }})
            </span>
          </div>
        </label>
      </div>
      
      <div class="mt-4 flex gap-3">
        <button 
          @click="applySelection"
          class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Apply Selection
        </button>
        <button 
          @click="showCustomSelection = false"
          class="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
        >
          Cancel
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useProgress } from '@/composables/useProgress'
import { useRouter } from 'vue-router'

const { progress, markModuleComplete } = useProgress()
const router = useRouter()

const showCustomSelection = ref(false)
const selectedModules = ref([])
const allModules = ref([]) // Loaded from modules.json

const markAllCoreComplete = () => {
  const coreModuleIds = ['module_1', 'module_2', 'module_3', 'module_4', 
                        'module_5', 'module_6', 'module_7', 'module_8']
  
  coreModuleIds.forEach(id => markModuleComplete(id))
  
  // Show success message
  showNotification('All core modules marked as complete!')
  router.push('/')
}

const applySelection = () => {
  selectedModules.value.forEach(id => markModuleComplete(id))
  showCustomSelection.value = false
  showNotification(`${selectedModules.value.length} modules marked as complete!`)
  router.push('/')
}
</script>
```

## Solution 3: Progress Export/Import

### Export Progress Feature
```javascript
// composables/useProgressBackup.js
export function useProgressBackup() {
  const { progress } = useProgress()
  
  const exportProgress = () => {
    const data = {
      version: 1,
      exportDate: new Date().toISOString(),
      progress: progress.value
    }
    
    // Create compact code
    const json = JSON.stringify(data)
    const compressed = btoa(json) // Base64 encode
    
    // Create shareable code (split for readability)
    const code = compressed.match(/.{1,8}/g).join('-')
    
    return {
      code,
      downloadUrl: `data:application/json;charset=utf-8,${encodeURIComponent(json)}`
    }
  }
  
  const importProgress = (code) => {
    try {
      // Remove dashes and decode
      const compressed = code.replace(/-/g, '')
      const json = atob(compressed)
      const data = JSON.parse(json)
      
      // Validate and merge
      if (data.version === 1) {
        // Merge with existing progress (don't overwrite newer data)
        Object.assign(progress.value, data.progress)
        return { success: true }
      }
    } catch (e) {
      return { success: false, error: 'Invalid progress code' }
    }
  }
  
  return { exportProgress, importProgress }
}
```

### Progress Backup UI
```vue
<template>
  <div class="bg-white p-6 rounded-lg shadow">
    <h3 class="text-lg font-semibold mb-4">Backup Your Progress</h3>
    
    <div class="space-y-4">
      <!-- Export Section -->
      <div>
        <p class="text-sm text-gray-600 mb-2">
          Save your progress to transfer between browsers or devices:
        </p>
        <button 
          @click="generateBackup"
          class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
        >
          Generate Backup Code
        </button>
      </div>
      
      <!-- Generated Code Display -->
      <div v-if="backupCode" class="p-4 bg-gray-50 rounded">
        <p class="text-sm font-medium mb-2">Your Progress Code:</p>
        <code class="block p-3 bg-white border rounded text-xs break-all">
          {{ backupCode }}
        </code>
        <button 
          @click="copyCode"
          class="mt-2 text-sm text-blue-600 hover:text-blue-800"
        >
          Copy to Clipboard
        </button>
      </div>
      
      <!-- Import Section -->
      <div class="border-t pt-4">
        <p class="text-sm text-gray-600 mb-2">
          Have a backup code? Restore your progress:
        </p>
        <input 
          v-model="importCode"
          placeholder="Paste your progress code here"
          class="w-full p-2 border rounded mb-2"
        >
        <button 
          @click="restoreProgress"
          :disabled="!importCode"
          class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
        >
          Restore Progress
        </button>
      </div>
    </div>
  </div>
</template>
```

## Solution 4: Smart Sync Indicators

### Visual Progress Indicators
```vue
<template>
  <div class="fixed bottom-4 right-4">
    <!-- Sync Status -->
    <div v-if="syncStatus" class="bg-white rounded-lg shadow-lg p-3 flex items-center">
      <div :class="syncStatusClass" class="w-2 h-2 rounded-full mr-2"></div>
      <span class="text-sm">{{ syncStatus }}</span>
    </div>
    
    <!-- New Updates Available -->
    <div v-if="hasNewUpdates" class="mt-2 bg-blue-500 text-white rounded-lg p-3">
      <p class="text-sm font-medium">New modules available!</p>
      <button @click="viewUpdates" class="text-xs underline">
        View updates
      </button>
    </div>
  </div>
</template>

<script setup>
const syncStatus = computed(() => {
  if (checking.value) return 'Checking for updates...'
  if (hasNewUpdates.value) return 'New content available'
  return 'All content up to date'
})

const syncStatusClass = computed(() => {
  if (checking.value) return 'bg-yellow-500 animate-pulse'
  if (hasNewUpdates.value) return 'bg-blue-500'
  return 'bg-green-500'
})
</script>
```

## Implementation Benefits

1. **Update Awareness** - Users always know when new content is available
2. **Progress Recovery** - Multiple ways to restore lost progress
3. **Cross-Device Sync** - Manual sync via progress codes
4. **User Control** - Choose what to mark complete
5. **Offline Friendly** - Works without constant server checks

## Future Enhancement: URL-Based State

For even simpler sharing:
```javascript
// Share progress via URL
const shareUrl = `${window.location.origin}/#/import?progress=${encodeURIComponent(progressCode)}`

// Auto-import on page load
if (route.query.progress) {
  importProgress(route.query.progress)
}
```