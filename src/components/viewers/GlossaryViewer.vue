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
        @click="exportGlossary"
        class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        Export PDF
      </button>
    </div>

    <!-- Search and Filter -->
    <div class="flex flex-col sm:flex-row gap-4">
      <div class="relative flex-1">
        <input
          v-model="searchTerm"
          type="text"
          placeholder="Search terms, definitions, or examples..."
          class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
        <svg class="absolute right-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
      
      <!-- Category filter -->
      <select
        v-model="selectedCategory"
        class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
      >
        <option value="">All Categories</option>
        <option v-for="category in categories" :key="category" :value="category">
          {{ formatCategoryName(category) }}
        </option>
      </select>
    </div>

    <!-- Alphabet Navigation -->
    <div class="flex flex-wrap gap-2 justify-center border-b border-gray-200 pb-4">
      <button
        v-for="letter in alphabet"
        :key="letter"
        @click="jumpToLetter(letter)"
        :class="{
          'bg-blue-600 text-white': hasTermsForLetter(letter),
          'bg-gray-100 text-gray-400 cursor-not-allowed': !hasTermsForLetter(letter),
          'bg-gray-200 text-gray-700 hover:bg-gray-300': hasTermsForLetter(letter) && selectedLetter !== letter
        }"
        class="w-8 h-8 rounded-full text-sm font-medium transition-colors"
        :disabled="!hasTermsForLetter(letter)"
      >
        {{ letter }}
      </button>
    </div>

    <!-- Terms List -->
    <div class="space-y-4">
      <!-- Group by first letter -->
      <div
        v-for="(termsGroup, letter) in groupedTerms"
        :key="letter"
        :id="`letter-${letter}`"
        class="space-y-4"
      >
        <!-- Letter header -->
        <div class="flex items-center gap-4">
          <h2 class="text-2xl font-bold text-gray-900">{{ letter.toUpperCase() }}</h2>
          <div class="flex-1 h-px bg-gray-200"></div>
          <span class="text-sm text-gray-500">{{ termsGroup.length }} terms</span>
        </div>

        <!-- Terms in this letter group -->
        <div class="grid gap-4">
          <div
            v-for="term in termsGroup"
            :key="term.term"
            class="bg-white border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow"
          >
            <!-- Term header -->
            <div class="flex items-start justify-between mb-3">
              <div class="flex-1">
                <h3 class="text-xl font-bold text-blue-600 mb-1">{{ term.term }}</h3>
                <span
                  v-if="term.category"
                  class="inline-block px-2 py-1 text-xs rounded-full"
                  :class="getCategoryColor(term.category)"
                >
                  {{ formatCategoryName(term.category) }}
                </span>
              </div>
              
              <!-- Copy button -->
              <button
                @click="copyTerm(term)"
                class="p-2 text-gray-400 hover:text-gray-600 transition-colors"
                title="Copy definition"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
              </button>
            </div>

            <!-- Definition -->
            <p class="text-gray-700 leading-relaxed mb-4">{{ term.definition }}</p>

            <!-- Example -->
            <div v-if="term.example" class="bg-gray-50 rounded-lg p-3 mb-4">
              <p class="text-sm text-gray-600 mb-1 font-medium">Example:</p>
              <code class="text-sm text-gray-800 bg-white px-2 py-1 rounded">{{ term.example }}</code>
            </div>

            <!-- Related terms -->
            <div v-if="term.relatedTerms?.length" class="flex flex-wrap gap-2">
              <span class="text-sm text-gray-600 mr-2">Related:</span>
              <button
                v-for="relatedTerm in term.relatedTerms"
                :key="relatedTerm"
                @click="searchForTerm(relatedTerm)"
                class="text-sm text-blue-600 hover:text-blue-800 hover:underline"
              >
                {{ relatedTerm }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-if="Object.keys(groupedTerms).length === 0" class="text-center py-12">
      <div class="inline-flex items-center justify-center w-16 h-16 bg-gray-100 rounded-full mb-4">
        <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </div>
      <h3 class="text-lg font-medium text-gray-900 mb-2">No Terms Found</h3>
      <p class="text-gray-600">No terms match your current search criteria.</p>
    </div>

    <!-- Footer -->
    <div class="mt-8 text-center text-sm text-gray-500">
      <p>{{ content.title }} • v{{ content.version }} • Updated {{ formatDate(content.lastUpdated) }}</p>
      <p>{{ filteredTerms.length }} terms</p>
    </div>

    <!-- Toast for copy feedback -->
    <div
      v-if="showCopyToast"
      class="fixed bottom-4 right-4 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg transition-all duration-300"
    >
      Definition copied to clipboard!
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
const selectedCategory = ref('')
const selectedLetter = ref('')
const showCopyToast = ref(false)

// Alphabet for navigation
const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')

// Get all categories
const categories = computed(() => {
  const categorySet = new Set()
  props.content.terms?.forEach(term => {
    if (term.category) {
      categorySet.add(term.category)
    }
  })
  return Array.from(categorySet).sort()
})

// Filter terms based on search and category
const filteredTerms = computed(() => {
  if (!props.content.terms) return []

  return props.content.terms.filter(term => {
    // Category filter
    if (selectedCategory.value && term.category !== selectedCategory.value) {
      return false
    }

    // Search filter
    if (searchTerm.value) {
      const search = searchTerm.value.toLowerCase()
      return (
        term.term.toLowerCase().includes(search) ||
        term.definition.toLowerCase().includes(search) ||
        term.example?.toLowerCase().includes(search) ||
        term.relatedTerms?.some(related => related.toLowerCase().includes(search))
      )
    }

    return true
  })
})

// Group terms by first letter
const groupedTerms = computed(() => {
  const grouped = {}
  
  filteredTerms.value
    .sort((a, b) => a.term.localeCompare(b.term))
    .forEach(term => {
      const firstLetter = term.term.charAt(0).toUpperCase()
      if (!grouped[firstLetter]) {
        grouped[firstLetter] = []
      }
      grouped[firstLetter].push(term)
    })

  return grouped
})

// Check if letter has terms
const hasTermsForLetter = (letter) => {
  return !!groupedTerms.value[letter]?.length
}

// Jump to letter section
const jumpToLetter = (letter) => {
  if (!hasTermsForLetter(letter)) return
  
  selectedLetter.value = letter
  const element = document.getElementById(`letter-${letter}`)
  if (element) {
    element.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }
}

// Search for a specific term
const searchForTerm = (termName) => {
  searchTerm.value = termName
  // Small delay to let the filter update, then scroll to term
  setTimeout(() => {
    const firstLetter = termName.charAt(0).toUpperCase()
    jumpToLetter(firstLetter)
  }, 100)
}

// Format category name
const formatCategoryName = (category) => {
  return category.split('-').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')
}

// Get category color
const getCategoryColor = (category) => {
  const colors = {
    'core': 'bg-blue-100 text-blue-800',
    'configuration': 'bg-green-100 text-green-800',
    'usage': 'bg-purple-100 text-purple-800',
    'advanced': 'bg-red-100 text-red-800',
    'commands': 'bg-yellow-100 text-yellow-800',
    'technical': 'bg-gray-100 text-gray-800',
    'django': 'bg-emerald-100 text-emerald-800',
    'performance': 'bg-orange-100 text-orange-800',
    'testing': 'bg-pink-100 text-pink-800',
    'setup': 'bg-indigo-100 text-indigo-800'
  }
  return colors[category] || 'bg-gray-100 text-gray-800'
}

// Copy term definition
const copyTerm = async (term) => {
  const text = `**${term.term}**: ${term.definition}${term.example ? `\n\nExample: ${term.example}` : ''}`
  
  try {
    await navigator.clipboard.writeText(text)
    showCopyToast.value = true
    setTimeout(() => {
      showCopyToast.value = false
    }, 2000)
  } catch (err) {
    console.error('Failed to copy term:', err)
  }
}

// Export glossary
const exportGlossary = () => {
  let exportText = `# ${props.content.title}\n\n${props.content.description}\n\n`
  
  Object.entries(groupedTerms.value).forEach(([letter, terms]) => {
    exportText += `## ${letter}\n\n`
    
    terms.forEach(term => {
      exportText += `### ${term.term}\n\n`
      exportText += `${term.definition}\n\n`
      
      if (term.example) {
        exportText += `**Example:** \`${term.example}\`\n\n`
      }
      
      if (term.relatedTerms?.length) {
        exportText += `**Related terms:** ${term.relatedTerms.join(', ')}\n\n`
      }
      
      exportText += '---\n\n'
    })
  })

  // Create and download file
  const blob = new Blob([exportText], { type: 'text/markdown' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${props.content.title.replace(/[^a-z0-9]/gi, '_').toLowerCase()}_glossary.md`
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