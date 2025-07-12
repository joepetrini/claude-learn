import { ref, computed, onMounted } from 'vue'

// Store for update detection state
const versionData = ref(null)
const lastSeenVersion = ref(null)
const lastSeenModuleVersions = ref({})
const hasNewUpdates = ref(false)
const newModules = ref([])
const updatedModules = ref([])

// Load version data from JSON
async function loadVersionData() {
  try {
    const response = await fetch(import.meta.env.BASE_URL + 'data/version.json')
    versionData.value = await response.json()
  } catch (error) {
    console.error('Failed to load version data:', error)
    versionData.value = null
  }
}

// Load user's last seen versions from localStorage
function loadLastSeenVersions() {
  const stored = localStorage.getItem('claudeLearnLastSeen')
  if (stored) {
    const data = JSON.parse(stored)
    lastSeenVersion.value = data.contentVersion || null
    lastSeenModuleVersions.value = data.moduleVersions || {}
  }
}

// Save user's last seen versions
function saveLastSeenVersions() {
  localStorage.setItem('claudeLearnLastSeen', JSON.stringify({
    contentVersion: versionData.value?.contentVersion || '0.0.0',
    moduleVersions: lastSeenModuleVersions.value,
    lastChecked: new Date().toISOString()
  }))
}

// Check if content version is newer
function isNewerVersion(current, lastSeen) {
  if (!lastSeen) return true
  
  const currentParts = current.split('.').map(Number)
  const lastSeenParts = lastSeen.split('.').map(Number)
  
  for (let i = 0; i < 3; i++) {
    if (currentParts[i] > lastSeenParts[i]) return true
    if (currentParts[i] < lastSeenParts[i]) return false
  }
  
  return false
}

export function useUpdateDetection() {
  // Initialize on first call
  onMounted(async () => {
    if (!versionData.value) {
      await loadVersionData()
      loadLastSeenVersions()
      
      // Check for new content version
      if (versionData.value && isNewerVersion(versionData.value.contentVersion, lastSeenVersion.value)) {
        hasNewUpdates.value = true
      }
    }
  })

  // Check if a specific module is new (not seen by user)
  function isModuleNew(moduleId) {
    if (!versionData.value) return false
    
    // Check if it's a monthly update module
    const monthlyUpdate = versionData.value.monthlyUpdates?.find(u => u.id === moduleId)
    if (monthlyUpdate) {
      // New if user hasn't seen this content version
      return !lastSeenModuleVersions.value[moduleId]
    }
    
    return false
  }

  // Check if a module has been updated since user last saw it
  function isModuleUpdated(moduleId) {
    if (!versionData.value?.moduleUpdates) return false
    
    const moduleUpdate = versionData.value.moduleUpdates[moduleId]
    if (!moduleUpdate) return false
    
    const lastSeenModuleVersion = lastSeenModuleVersions.value[moduleId]
    if (!lastSeenModuleVersion) return false
    
    return isNewerVersion(moduleUpdate.version, lastSeenModuleVersion)
  }

  // Get update info for a module
  function getModuleUpdateInfo(moduleId) {
    if (!versionData.value?.moduleUpdates) return null
    
    const moduleUpdate = versionData.value.moduleUpdates[moduleId]
    if (!moduleUpdate) return null
    
    return {
      version: moduleUpdate.version,
      lastUpdated: moduleUpdate.lastUpdated,
      changes: moduleUpdate.changes || [],
      isNew: isModuleNew(moduleId),
      isUpdated: isModuleUpdated(moduleId)
    }
  }

  // Mark module as seen
  function markModuleSeen(moduleId) {
    const moduleUpdate = versionData.value?.moduleUpdates?.[moduleId]
    if (moduleUpdate) {
      lastSeenModuleVersions.value[moduleId] = moduleUpdate.version
    } else {
      // For new modules without version tracking yet
      lastSeenModuleVersions.value[moduleId] = '1.0'
    }
    saveLastSeenVersions()
  }

  // Mark all updates as seen
  function markAllUpdatesSeen() {
    lastSeenVersion.value = versionData.value?.contentVersion || '1.0.0'
    
    // Mark all module versions as seen
    if (versionData.value?.moduleUpdates) {
      Object.entries(versionData.value.moduleUpdates).forEach(([moduleId, update]) => {
        lastSeenModuleVersions.value[moduleId] = update.version
      })
    }
    
    // Mark all monthly updates as seen
    if (versionData.value?.monthlyUpdates) {
      versionData.value.monthlyUpdates.forEach(update => {
        lastSeenModuleVersions.value[update.id] = '1.0'
      })
    }
    
    hasNewUpdates.value = false
    saveLastSeenVersions()
  }

  // Get all updates since last visit
  const updatesSinceLastVisit = computed(() => {
    if (!versionData.value) return { modules: [], features: [] }
    
    const updates = {
      modules: [],
      features: []
    }
    
    // Check core module updates
    if (versionData.value.moduleUpdates) {
      Object.entries(versionData.value.moduleUpdates).forEach(([moduleId, update]) => {
        if (isModuleUpdated(moduleId)) {
          updates.modules.push({
            id: moduleId,
            ...update,
            type: 'updated'
          })
        }
      })
    }
    
    // Check new monthly updates
    if (versionData.value.monthlyUpdates) {
      versionData.value.monthlyUpdates.forEach(update => {
        if (!lastSeenModuleVersions.value[update.id]) {
          updates.modules.push({
            ...update,
            type: 'new'
          })
          updates.features.push(...(update.features || []))
        }
      })
    }
    
    return updates
  })

  // Check if user should see "What's New" modal
  const shouldShowWhatsNew = computed(() => {
    return hasNewUpdates.value && updatesSinceLastVisit.value.modules.length > 0
  })

  return {
    // State
    versionData,
    hasNewUpdates,
    updatesSinceLastVisit,
    shouldShowWhatsNew,
    
    // Methods
    isModuleNew,
    isModuleUpdated,
    getModuleUpdateInfo,
    markModuleSeen,
    markAllUpdatesSeen,
    loadVersionData,
    
    // Utilities
    isNewerVersion
  }
}