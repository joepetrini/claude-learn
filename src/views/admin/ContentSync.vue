<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <div class="container mx-auto px-4 py-8">
      <!-- Header -->
      <div class="mb-8">
        <router-link to="/admin" class="text-blue-600 hover:text-blue-800 mb-4 inline-flex items-center gap-2">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Back to Admin Dashboard
        </router-link>
        
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Content Sync Dashboard</h1>
        <p class="text-gray-600">Synchronize JSON content with the database</p>
      </div>

      <!-- Sync Status Card -->
      <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-semibold">Sync Status</h2>
          <button
            @click="scanForChanges"
            :disabled="isScanning"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2"
          >
            <svg v-if="isScanning" class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span>{{ isScanning ? 'Scanning...' : 'Scan for Changes' }}</span>
          </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="bg-gray-50 rounded-lg p-4">
            <div class="text-2xl font-bold text-green-600">{{ syncStatus.upToDate }}</div>
            <div class="text-sm text-gray-600">Up to Date</div>
          </div>
          <div class="bg-gray-50 rounded-lg p-4">
            <div class="text-2xl font-bold text-yellow-600">{{ syncStatus.needsUpdate }}</div>
            <div class="text-sm text-gray-600">Needs Update</div>
          </div>
          <div class="bg-gray-50 rounded-lg p-4">
            <div class="text-2xl font-bold text-red-600">{{ syncStatus.missing }}</div>
            <div class="text-sm text-gray-600">Missing in DB</div>
          </div>
        </div>

        <div v-if="lastSyncTime" class="mt-4 text-sm text-gray-500">
          Last sync: {{ formatDate(lastSyncTime) }}
        </div>
      </div>

      <!-- Changes Detection -->
      <div v-if="changes.length > 0" class="bg-white rounded-lg shadow-sm p-6 mb-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-semibold">Detected Changes</h2>
          <button
            @click="syncAllChanges"
            :disabled="isSyncing"
            class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isSyncing ? 'Syncing...' : 'Sync All Changes' }}
          </button>
        </div>

        <div class="space-y-3">
          <div
            v-for="change in changes"
            :key="change.id"
            class="border rounded-lg p-4 hover:bg-gray-50"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-1">
                  <span
                    class="px-2 py-1 text-xs rounded-full font-medium"
                    :class="{
                      'bg-green-100 text-green-800': change.type === 'new',
                      'bg-yellow-100 text-yellow-800': change.type === 'modified',
                      'bg-red-100 text-red-800': change.type === 'deleted'
                    }"
                  >
                    {{ change.type }}
                  </span>
                  <span class="text-sm text-gray-500">{{ change.contentType }}</span>
                </div>
                <h3 class="font-semibold text-gray-900">{{ change.title }}</h3>
                <p class="text-sm text-gray-600">{{ change.path }}</p>
                <div v-if="change.details" class="mt-2 text-sm text-gray-500">
                  {{ change.details }}
                </div>
              </div>
              <button
                @click="syncSingleChange(change)"
                :disabled="isSyncing || change.syncing"
                class="ml-4 px-3 py-1.5 text-sm bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {{ change.syncing ? 'Syncing...' : 'Sync' }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- No Changes -->
      <div v-else-if="!isScanning && hasScanned" class="bg-white rounded-lg shadow-sm p-12 text-center">
        <svg class="w-16 h-16 text-green-500 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <h3 class="text-lg font-medium text-gray-900 mb-2">All Content is Synchronized</h3>
        <p class="text-gray-600">Your JSON files and database are in sync.</p>
      </div>

      <!-- Sync Log -->
      <div v-if="syncLog.length > 0" class="bg-white rounded-lg shadow-sm p-6">
        <h2 class="text-xl font-semibold mb-4">Sync Log</h2>
        <div class="space-y-2">
          <div
            v-for="(log, index) in syncLog"
            :key="index"
            class="flex items-start gap-3 text-sm"
          >
            <span class="text-gray-400">{{ formatTime(log.timestamp) }}</span>
            <span
              class="font-medium"
              :class="{
                'text-green-600': log.status === 'success',
                'text-red-600': log.status === 'error',
                'text-blue-600': log.status === 'info'
              }"
            >
              {{ log.message }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../../lib/supabaseClient'
import Navigation from '../../components/Navigation.vue'

// State
const isScanning = ref(false)
const isSyncing = ref(false)
const hasScanned = ref(false)
const changes = ref([])
const syncStatus = ref({
  upToDate: 0,
  needsUpdate: 0,
  missing: 0
})
const lastSyncTime = ref(null)
const syncLog = ref([])

// Scan for changes between JSON files and database
async function scanForChanges() {
  isScanning.value = true
  hasScanned.value = true
  changes.value = []
  
  try {
    // Load categories from JSON
    const categoriesResponse = await fetch(import.meta.env.BASE_URL + 'data/categories.json')
    const categoriesData = await categoriesResponse.json()
    
    // Load categories from database
    const { data: dbCategories, error } = await supabase
      .from('categories')
      .select('*')
    
    if (error) throw error
    
    // Compare categories
    const dbCategoryMap = new Map(dbCategories.map(cat => [cat.slug, cat]))
    
    for (const category of categoriesData.categories) {
      const dbCategory = dbCategoryMap.get(category.slug)
      
      if (!dbCategory) {
        changes.value.push({
          id: `cat-${category.slug}`,
          type: 'new',
          contentType: 'category',
          title: category.name,
          path: `categories/${category.slug}`,
          details: 'Category not found in database',
          data: category
        })
        syncStatus.value.missing++
      } else if (hasContentChanged(category, dbCategory)) {
        changes.value.push({
          id: `cat-${category.slug}`,
          type: 'modified',
          contentType: 'category',
          title: category.name,
          path: `categories/${category.slug}`,
          details: 'Category content has changed',
          data: category
        })
        syncStatus.value.needsUpdate++
      } else {
        syncStatus.value.upToDate++
      }
      
      // Check courses for this category
      await scanCoursesForCategory(category.slug)
    }
    
    // Check for deleted categories
    for (const [slug, dbCategory] of dbCategoryMap) {
      if (!categoriesData.categories.find(c => c.slug === slug)) {
        changes.value.push({
          id: `cat-${slug}`,
          type: 'deleted',
          contentType: 'category',
          title: dbCategory.name,
          path: `categories/${slug}`,
          details: 'Category exists in database but not in JSON files'
        })
      }
    }
    
    addToLog('info', `Scan complete: ${changes.value.length} changes detected`)
  } catch (error) {
    console.error('Error scanning for changes:', error)
    addToLog('error', 'Failed to scan for changes: ' + error.message)
  } finally {
    isScanning.value = false
  }
}

// Scan courses within a category
async function scanCoursesForCategory(categorySlug) {
  try {
    const coursesResponse = await fetch(
      import.meta.env.BASE_URL + `data/${categorySlug}/courses.json`
    )
    
    if (!coursesResponse.ok) return
    
    const coursesData = await coursesResponse.json()
    
    // Load courses from database
    const { data: dbCourses } = await supabase
      .from('courses')
      .select('*')
      .eq('category_id', categorySlug) // Using slug as ID for now
    
    const dbCourseMap = new Map(dbCourses?.map(course => [course.slug, course]) || [])
    
    for (const course of coursesData.courses || []) {
      const dbCourse = dbCourseMap.get(course.slug)
      
      if (!dbCourse) {
        changes.value.push({
          id: `course-${categorySlug}-${course.slug}`,
          type: 'new',
          contentType: 'course',
          title: course.title,
          path: `${categorySlug}/${course.slug}`,
          details: `Course not found in database (Category: ${categorySlug})`,
          data: { ...course, category_id: categorySlug }
        })
        syncStatus.value.missing++
      } else if (hasContentChanged(course, dbCourse)) {
        changes.value.push({
          id: `course-${categorySlug}-${course.slug}`,
          type: 'modified',
          contentType: 'course',
          title: course.title,
          path: `${categorySlug}/${course.slug}`,
          details: 'Course content has changed',
          data: { ...course, category_id: categorySlug }
        })
        syncStatus.value.needsUpdate++
      } else {
        syncStatus.value.upToDate++
      }
    }
  } catch (error) {
    console.error(`Error scanning courses for ${categorySlug}:`, error)
  }
}

// Check if content has changed
function hasContentChanged(jsonData, dbData) {
  const relevantFields = ['name', 'title', 'description', 'icon', 'color', 'sortOrder', 'isActive']
  
  for (const field of relevantFields) {
    const jsonField = jsonData[field] ?? jsonData[toCamelCase(field)]
    const dbField = dbData[toSnakeCase(field)]
    
    if (jsonField !== dbField) {
      return true
    }
  }
  
  return false
}

// Sync all detected changes
async function syncAllChanges() {
  isSyncing.value = true
  
  for (const change of changes.value) {
    await syncSingleChange(change)
  }
  
  // Rescan after syncing
  await scanForChanges()
  isSyncing.value = false
}

// Sync a single change
async function syncSingleChange(change) {
  change.syncing = true
  
  try {
    if (change.type === 'new') {
      await createContent(change)
    } else if (change.type === 'modified') {
      await updateContent(change)
    } else if (change.type === 'deleted') {
      await deleteContent(change)
    }
    
    // Remove from changes list
    changes.value = changes.value.filter(c => c.id !== change.id)
    addToLog('success', `Synced ${change.contentType}: ${change.title}`)
  } catch (error) {
    console.error('Error syncing change:', error)
    addToLog('error', `Failed to sync ${change.contentType}: ${change.title}`)
  } finally {
    change.syncing = false
  }
}

// Create new content in database
async function createContent(change) {
  if (change.contentType === 'category') {
    const { error } = await supabase
      .from('categories')
      .insert({
        slug: change.data.slug,
        name: change.data.name,
        description: change.data.description,
        icon: change.data.icon,
        color: change.data.color,
        sort_order: change.data.sortOrder || 0,
        is_active: change.data.isActive ?? true
      })
    
    if (error) throw error
  } else if (change.contentType === 'course') {
    const { error } = await supabase
      .from('courses')
      .insert({
        category_id: change.data.category_id,
        slug: change.data.slug,
        title: change.data.title,
        description: change.data.description,
        icon: change.data.icon,
        estimated_duration: change.data.estimatedDuration,
        module_count: change.data.moduleCount,
        difficulty_level: change.data.difficultyLevel,
        sort_order: change.data.sortOrder || 0,
        is_active: change.data.isActive ?? true,
        is_featured: change.data.isFeatured || false,
        tags: change.data.tags || []
      })
    
    if (error) throw error
  }
}

// Update existing content
async function updateContent(change) {
  if (change.contentType === 'category') {
    const { error } = await supabase
      .from('categories')
      .update({
        name: change.data.name,
        description: change.data.description,
        icon: change.data.icon,
        color: change.data.color,
        sort_order: change.data.sortOrder || 0,
        is_active: change.data.isActive ?? true
      })
      .eq('slug', change.data.slug)
    
    if (error) throw error
  } else if (change.contentType === 'course') {
    const { error } = await supabase
      .from('courses')
      .update({
        title: change.data.title,
        description: change.data.description,
        icon: change.data.icon,
        estimated_duration: change.data.estimatedDuration,
        module_count: change.data.moduleCount,
        difficulty_level: change.data.difficultyLevel,
        sort_order: change.data.sortOrder || 0,
        is_active: change.data.isActive ?? true,
        is_featured: change.data.isFeatured || false,
        tags: change.data.tags || []
      })
      .eq('slug', change.data.slug)
      .eq('category_id', change.data.category_id)
    
    if (error) throw error
  }
  
  // Update last sync time
  lastSyncTime.value = new Date()
}

// Delete content from database
async function deleteContent(change) {
  if (change.contentType === 'category') {
    const { error } = await supabase
      .from('categories')
      .delete()
      .eq('slug', change.path.split('/')[1])
    
    if (error) throw error
  }
}

// Add entry to sync log
function addToLog(status, message) {
  syncLog.value.unshift({
    timestamp: new Date(),
    status,
    message
  })
  
  // Keep only last 50 entries
  if (syncLog.value.length > 50) {
    syncLog.value = syncLog.value.slice(0, 50)
  }
}

// Utility functions
function formatDate(date) {
  return new Date(date).toLocaleString()
}

function formatTime(date) {
  return new Date(date).toLocaleTimeString()
}

function toCamelCase(str) {
  return str.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
}

function toSnakeCase(str) {
  return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`).replace(/^_/, '')
}

// Load last sync time on mount
onMounted(async () => {
  try {
    const { data } = await supabase
      .from('sync_log')
      .select('created_at')
      .order('created_at', { ascending: false })
      .limit(1)
      .single()
    
    if (data) {
      lastSyncTime.value = data.created_at
    }
  } catch (error) {
    // Table might not exist yet
    console.log('No sync log found')
  }
})
</script>