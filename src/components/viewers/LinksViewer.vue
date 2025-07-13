<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">{{ content.title }}</h1>
        <p class="text-gray-600 mt-1">{{ content.description }}</p>
      </div>
      
      <!-- Export button -->
      <button
        @click="exportLinks"
        class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center gap-2"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        Export Links
      </button>
    </div>

    <!-- Search and Filter -->
    <div class="flex flex-col sm:flex-row gap-4">
      <div class="relative flex-1">
        <input
          v-model="searchTerm"
          type="text"
          placeholder="Search links, descriptions, or tags..."
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
        <svg class="absolute right-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
      
      <!-- Tag filter -->
      <select
        v-model="selectedTag"
        class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
      >
        <option value="">All Tags</option>
        <option v-for="tag in allTags" :key="tag" :value="tag">
          {{ tag }}
        </option>
      </select>
    </div>

    <!-- Categories -->
    <div class="space-y-8">
      <div
        v-for="category in filteredCategories"
        :key="category.name"
        class="bg-white rounded-lg shadow-md p-6"
      >
        <!-- Category Header -->
        <div class="flex items-center gap-3 mb-6">
          <span class="text-2xl">{{ category.icon }}</span>
          <div>
            <h2 class="text-xl font-bold text-gray-900">{{ category.name }}</h2>
            <p class="text-sm text-gray-500">{{ category.links.length }} links</p>
          </div>
        </div>

        <!-- Links Grid -->
        <div class="grid gap-4">
          <div
            v-for="link in category.links"
            :key="link.url"
            class="group border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:shadow-md transition-all duration-200"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1 min-w-0">
                <!-- Link title and URL -->
                <div class="flex items-start gap-3">
                  <a
                    :href="link.url"
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-lg font-semibold text-blue-600 hover:text-blue-800 group-hover:underline"
                  >
                    {{ link.title }}
                    <svg class="inline w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </a>
                </div>
                
                <!-- URL display -->
                <p class="text-sm text-gray-500 mt-1 truncate">{{ link.url }}</p>
                
                <!-- Description -->
                <p class="text-gray-700 mt-2">{{ link.description }}</p>
                
                <!-- Tags -->
                <div class="flex flex-wrap gap-1 mt-3">
                  <span
                    v-for="tag in link.tags"
                    :key="tag"
                    class="inline-block px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full"
                  >
                    {{ tag }}
                  </span>
                </div>
              </div>
              
              <!-- Quick copy button -->
              <button
                @click="copyLink(link.url)"
                class="opacity-0 group-hover:opacity-100 transition-opacity p-2 text-gray-400 hover:text-gray-600"
                title="Copy link"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="filteredCategories.length === 0" class="text-center py-12">
      <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
        <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">No Links Found</h3>
      <p class="text-gray-600">No links match your current search criteria.</p>
    </div>

    <!-- Footer -->
    <div class="mt-8 text-center text-sm text-gray-500">
      <p>{{ content.title }} • Updated {{ formatDate(content.lastUpdated) }}</p>
      <p>{{ totalLinks }} total links across {{ content.categories?.length || 0 }} categories</p>
    </div>

    <!-- Toast for copy feedback -->
    <div
      v-if="showCopyToast"
      class="fixed bottom-4 right-4 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg transition-all duration-300"
    >
      Link copied to clipboard!
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  content: {
    type: Object,
    required: true
  }
})

const searchTerm = ref('')
const selectedTag = ref('')
const showCopyToast = ref(false)

// Get all unique tags
const allTags = computed(() => {
  const tags = new Set()
  props.content.categories?.forEach(category => {
    category.links?.forEach(link => {
      link.tags?.forEach(tag => tags.add(tag))
    })
  })
  return Array.from(tags).sort()
})

// Filter categories based on search and tag
const filteredCategories = computed(() => {
  if (!props.content.categories) return []

  const search = searchTerm.value.toLowerCase()
  const tag = selectedTag.value

  return props.content.categories.map(category => {
    const filteredLinks = category.links?.filter(link => {
      // Tag filter
      if (tag && !link.tags?.includes(tag)) {
        return false
      }

      // Search filter
      if (search) {
        return (
          link.title.toLowerCase().includes(search) ||
          link.description.toLowerCase().includes(search) ||
          link.url.toLowerCase().includes(search) ||
          link.tags?.some(linkTag => linkTag.toLowerCase().includes(search))
        )
      }

      return true
    }) || []

    return {
      ...category,
      links: filteredLinks
    }
  }).filter(category => category.links.length > 0)
})

// Total links count
const totalLinks = computed(() => {
  return props.content.categories?.reduce((total, category) => {
    return total + (category.links?.length || 0)
  }, 0) || 0
})

// Copy link to clipboard
const copyLink = async (url) => {
  try {
    await navigator.clipboard.writeText(url)
    showCopyToast.value = true
    setTimeout(() => {
      showCopyToast.value = false
    }, 2000)
  } catch (err) {
    console.error('Failed to copy link:', err)
  }
}

// Export all links as text/markdown
const exportLinks = () => {
  let exportText = `# ${props.content.title}\n\n${props.content.description}\n\n`
  
  props.content.categories?.forEach(category => {
    exportText += `## ${category.icon} ${category.name}\n\n`
    
    category.links?.forEach(link => {
      exportText += `### ${link.title}\n`
      exportText += `${link.description}\n\n`
      exportText += `**URL:** ${link.url}\n`
      if (link.tags?.length) {
        exportText += `**Tags:** ${link.tags.join(', ')}\n`
      }
      exportText += '\n---\n\n'
    })
  })

  // Create and download file
  const blob = new Blob([exportText], { type: 'text/markdown' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${props.content.title.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_links.md`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

// Format date
const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric' 
  })
}
</script>