<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">{{ content.title }}</h1>
        <p class="text-gray-600 mt-1">{{ content.description }}</p>
      </div>
      
      <!-- Print button -->
      <button
        @click="printCheatSheet"
        class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2z" />
        </svg>
        Print / Save as PDF
      </button>
    </div>

    <!-- Search -->
    <div class="relative">
      <input
        v-model="searchTerm"
        type="text"
        placeholder="Search commands, shortcuts, or descriptions..."
        class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
      >
      <svg class="absolute right-3 top-2.5 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
      </svg>
    </div>

    <!-- Content Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 print:grid-cols-2 print:gap-4">
      <!-- Render each section -->
      <div
        v-for="section in filteredSections"
        :key="section.title"
        class="bg-white rounded-lg shadow-md p-6 print:shadow-none print:border print:p-4"
        :class="{ 'lg:col-span-2': section.columns === 2 || section.subsections }"
      >
        <h2 class="text-xl font-bold mb-4 text-gray-900 print:text-lg">
          {{ section.title }}
        </h2>

        <!-- Regular items -->
        <div v-if="section.items" class="space-y-3 print:space-y-2">
          <!-- Grid layout for columns -->
          <div
            v-if="section.columns === 2"
            class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm"
          >
            <div
              v-for="item in section.items"
              :key="item.command || item.pattern || item.workflow"
              class="flex justify-between items-start"
            >
              <div class="flex-1">
                <code class="bg-gray-100 px-2 py-1 rounded print:bg-gray-50 text-xs">
                  {{ item.command || item.pattern || item.workflow }}
                </code>
                <span class="text-gray-600 ml-2 text-xs">{{ item.description }}</span>
              </div>
            </div>
          </div>

          <!-- Regular layout -->
          <div v-else>
            <!-- Commands -->
            <div
              v-for="item in section.items"
              :key="item.command || item.pattern || item.workflow"
              :class="{
                'border-l-4 pl-3': item.color,
                'border-blue-500': item.color === 'blue',
                'border-green-500': item.color === 'green',
                'border-purple-500': item.color === 'purple'
              }"
            >
              <div v-if="item.command">
                <code class="text-sm bg-gray-100 px-2 py-1 rounded print:bg-gray-50">
                  {{ item.command }}
                </code>
                <p class="text-sm text-gray-600 mt-1">{{ item.description }}</p>
                <p v-if="item.example" class="text-xs text-gray-500 mt-1 italic">
                  Example: {{ item.example }}
                </p>
              </div>

              <div v-else-if="item.workflow">
                <p class="font-semibold text-sm">{{ item.workflow }}</p>
                <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-1 print:bg-gray-50">
                  {{ item.command }}
                </code>
                <p class="text-sm text-gray-600 mt-1">{{ item.description }}</p>
              </div>

              <div v-else-if="item.pattern">
                <p class="font-semibold text-sm">{{ item.pattern }}</p>
                <code class="text-xs bg-gray-100 px-2 py-1 rounded block mt-1 print:bg-gray-50">
                  {{ item.command }}
                </code>
              </div>
            </div>
          </div>
        </div>

        <!-- Subsections (for keyboard shortcuts and pro tips) -->
        <div v-if="section.subsections" class="space-y-4">
          <div
            v-for="subsection in section.subsections"
            :key="subsection.title"
            class="space-y-2"
          >
            <h3 class="font-semibold text-gray-800 mb-2">{{ subsection.title }}</h3>
            
            <!-- Keyboard shortcuts -->
            <div v-if="subsection.items" class="space-y-2 text-sm">
              <div class="grid grid-cols-1 gap-2">
                <div
                  v-for="item in subsection.items"
                  :key="item.action"
                  class="flex justify-between items-center"
                >
                  <span>{{ item.action }}</span>
                  <kbd class="px-2 py-1 bg-gray-100 rounded text-xs print:bg-gray-50">
                    {{ item.shortcut }}
                  </kbd>
                </div>
              </div>
            </div>

            <!-- Pro tips -->
            <div v-if="subsection.tips" class="space-y-1 text-sm text-gray-600">
              <div
                v-for="tip in subsection.tips"
                :key="tip"
                class="flex items-start space-x-2"
              >
                <span class="text-blue-600 font-bold">•</span>
                <span v-html="formatTip(tip)"></span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="mt-8 text-center text-sm text-gray-500 print:mt-4">
      <p>{{ content.title }} • v{{ content.version }} • Updated {{ formatDate(content.lastUpdated) }}</p>
      <p class="print:hidden">Press Ctrl+P (Cmd+P on Mac) to print or save as PDF</p>
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

// Filter sections based on search term
const filteredSections = computed(() => {
  if (!searchTerm.value.trim()) {
    return props.content.sections || []
  }

  const search = searchTerm.value.toLowerCase()
  
  return props.content.sections?.filter(section => {
    // Check section title
    if (section.title.toLowerCase().includes(search)) {
      return true
    }

    // Check items
    if (section.items?.some(item => 
      (item.command?.toLowerCase().includes(search)) ||
      (item.description?.toLowerCase().includes(search)) ||
      (item.workflow?.toLowerCase().includes(search)) ||
      (item.pattern?.toLowerCase().includes(search)) ||
      (item.example?.toLowerCase().includes(search))
    )) {
      return true
    }

    // Check subsections
    if (section.subsections?.some(subsection =>
      subsection.title.toLowerCase().includes(search) ||
      subsection.items?.some(item =>
        item.action?.toLowerCase().includes(search) ||
        item.shortcut?.toLowerCase().includes(search)
      ) ||
      subsection.tips?.some(tip =>
        tip.toLowerCase().includes(search)
      )
    )) {
      return true
    }

    return false
  }) || []
})

// Format tips with inline code highlighting
const formatTip = (tip) => {
  return tip.replace(/`([^`]+)`/g, '<code class="bg-gray-100 px-1 rounded print:bg-gray-50">$1</code>')
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

// Print functionality
const printCheatSheet = () => {
  window.print()
}
</script>

<style>
@media print {
  @page {
    size: A4;
    margin: 1cm;
  }
  
  body {
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
  }
  
  .print\:break-inside-avoid {
    break-inside: avoid;
  }
}
</style>