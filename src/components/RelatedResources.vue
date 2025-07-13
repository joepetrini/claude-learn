<template>
  <div v-if="relatedResources.length > 0" class="space-y-4">
    <!-- Header -->
    <div class="flex items-center justify-between">
      <h3 class="text-lg font-semibold text-gray-900">Related Resources</h3>
      <button
        v-if="relatedResources.length > displayLimit"
        @click="showAll = !showAll"
        class="text-sm text-blue-600 hover:text-blue-800"
      >
        {{ showAll ? 'Show Less' : `Show All (${relatedResources.length})` }}
      </button>
    </div>

    <!-- Resource Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="resource in displayedResources"
        :key="`related-${resource.id}`"
        class="bg-white border border-gray-200 rounded-lg p-4 hover:shadow-md transition-all duration-200 cursor-pointer group"
        @click="$emit('open-resource', resource)"
      >
        <!-- Resource header -->
        <div class="flex items-start justify-between mb-3">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center">
              <span class="text-lg">{{ resource.icon }}</span>
            </div>
            <div class="flex-1 min-w-0">
              <h4 class="text-sm font-semibold text-gray-900 group-hover:text-blue-600 transition-colors line-clamp-1">
                {{ resource.title }}
              </h4>
              <p class="text-xs text-gray-500 capitalize">{{ resource.type?.replace('-', ' ') }}</p>
            </div>
          </div>
          
          <!-- Relevance score badge -->
          <div class="flex items-center space-x-1">
            <span
              v-if="resource.relevanceScore >= 0.8"
              class="inline-flex items-center px-2 py-1 text-xs font-semibold bg-green-100 text-green-800 rounded-full"
            >
              <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
              </svg>
              Highly Relevant
            </span>
            <span
              v-else-if="resource.relevanceScore >= 0.6"
              class="inline-flex items-center px-2 py-1 text-xs font-semibold bg-blue-100 text-blue-800 rounded-full"
            >
              Relevant
            </span>
          </div>
        </div>

        <!-- Description -->
        <p class="text-sm text-gray-600 mb-3 line-clamp-2">
          {{ resource.description }}
        </p>

        <!-- Tags and metadata -->
        <div class="space-y-2">
          <!-- Common tags -->
          <div v-if="resource.commonTags?.length > 0" class="flex flex-wrap gap-1">
            <span
              v-for="tag in resource.commonTags.slice(0, 3)"
              :key="tag"
              class="inline-block px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded-full"
            >
              {{ tag }}
            </span>
            <span
              v-if="resource.commonTags.length > 3"
              class="inline-block px-2 py-1 text-xs bg-gray-100 text-gray-600 rounded-full"
            >
              +{{ resource.commonTags.length - 3 }}
            </span>
          </div>

          <!-- Relationship type -->
          <div class="flex items-center justify-between text-xs text-gray-500">
            <span class="flex items-center space-x-1">
              <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />
              </svg>
              <span>{{ getRelationshipLabel(resource.relationshipType) }}</span>
            </span>
            
            <div class="flex items-center space-x-2">
              <span v-if="resource.viewCount" class="flex items-center space-x-1">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
                <span>{{ formatNumber(resource.viewCount) }}</span>
              </span>
              
              <button
                @click.stop="toggleFavorite(resource)"
                class="text-gray-400 hover:text-yellow-500 transition-colors"
                :class="{ 'text-yellow-500': resource.isFavorited }"
              >
                <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Learning Path Suggestion -->
    <div v-if="suggestedPath.length > 0" class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
      <div class="flex items-center space-x-2 mb-3">
        <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-1.447-.894L15 4m0 13V4m-6 3l6-3" />
        </svg>
        <h4 class="text-sm font-semibold text-blue-900">Suggested Learning Path</h4>
      </div>
      
      <div class="flex items-center space-x-2 overflow-x-auto pb-2">
        <div
          v-for="(step, index) in suggestedPath"
          :key="`path-${step.id}`"
          class="flex items-center space-x-2 flex-shrink-0"
        >
          <button
            @click="$emit('open-resource', step)"
            class="flex items-center space-x-2 px-3 py-2 bg-white rounded-lg border border-blue-200 hover:bg-blue-50 transition-colors"
          >
            <span class="text-lg">{{ step.icon }}</span>
            <span class="text-sm font-medium text-blue-900">{{ step.title }}</span>
          </button>
          
          <svg
            v-if="index < suggestedPath.length - 1"
            class="w-4 h-4 text-blue-400 flex-shrink-0"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </div>
      </div>
    </div>

    <!-- Feedback Section -->
    <div class="mt-4 p-3 bg-gray-50 rounded-lg">
      <div class="flex items-center justify-between">
        <p class="text-sm text-gray-600">Were these recommendations helpful?</p>
        <div class="flex items-center space-x-2">
          <button
            @click="submitFeedback(true)"
            class="p-1 text-gray-400 hover:text-green-600 transition-colors"
            :class="{ 'text-green-600': feedback === true }"
            title="Yes, helpful"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
            </svg>
          </button>
          <button
            @click="submitFeedback(false)"
            class="p-1 text-gray-400 hover:text-red-600 transition-colors"
            :class="{ 'text-red-600': feedback === false }"
            title="No, not helpful"
          >
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path d="M18 9.5a1.5 1.5 0 11-3 0v-6a1.5 1.5 0 013 0v6zM14 9.667v-5.43a2 2 0 00-1.106-1.79l-.05-.025A4 4 0 0011.157 2H5.741a2 2 0 00-1.962 1.608l-1.2 6A2 2 0 004.439 12H8v4a2 2 0 002 2 1 1 0 001-1v-.667a4 4 0 01.8-2.4l1.4-1.866a4 4 0 00.8-2.4z" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const props = defineProps({
  currentResource: {
    type: Object,
    required: true
  },
  courseId: {
    type: String,
    required: true
  }
})

const emit = defineEmits(['open-resource', 'toggle-favorite'])

const showAll = ref(false)
const feedback = ref(null)
const displayLimit = 3

const relatedResources = ref([])
const suggestedPath = ref([])

const displayedResources = computed(() => {
  return showAll.value ? relatedResources.value : relatedResources.value.slice(0, displayLimit)
})

// Methods
const formatNumber = (num) => {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + 'M'
  } else if (num >= 1000) {
    return (num / 1000).toFixed(1) + 'K'
  }
  return num?.toString() || '0'
}

const getRelationshipLabel = (type) => {
  const labels = {
    'prerequisite': 'Prerequisite',
    'follow-up': 'Follow-up',
    'complementary': 'Complementary',
    'similar': 'Similar Topic',
    'related-topic': 'Related Topic',
    'same-category': 'Same Category'
  }
  return labels[type] || 'Related'
}

const toggleFavorite = (resource) => {
  emit('toggle-favorite', resource)
}

const submitFeedback = (isHelpful) => {
  feedback.value = isHelpful
  // In real app, send feedback to analytics service
  console.log('Feedback submitted:', isHelpful, 'for resource:', props.currentResource.id)
}

const findRelatedResources = async () => {
  // Mock implementation - in real app, this would call the recommendation service
  const mockRelated = [
    {
      id: 'official-docs',
      title: 'Documentation & Resources',
      description: 'Official documentation and community resources for Claude Code',
      type: 'links',
      icon: '🔗',
      courseId: props.courseId,
      relevanceScore: 0.85,
      relationshipType: 'complementary',
      commonTags: ['documentation', 'external', 'resources'],
      viewCount: 2876,
      isFavorited: false
    },
    {
      id: 'terminology',
      title: 'Claude Code Glossary',
      description: 'Key terms and concepts explained',
      type: 'glossary',
      icon: '📚',
      courseId: props.courseId,
      relevanceScore: 0.75,
      relationshipType: 'follow-up',
      commonTags: ['glossary', 'terms', 'definitions'],
      viewCount: 2543,
      isFavorited: true
    },
    {
      id: 'python-basics',
      title: 'Python Fundamentals',
      description: 'Essential Python concepts for Django development',
      type: 'cheat-sheet',
      icon: '🐍',
      courseId: 'python-fundamentals',
      relevanceScore: 0.65,
      relationshipType: 'prerequisite',
      commonTags: ['python', 'basics', 'fundamentals'],
      viewCount: 1892,
      isFavorited: false
    },
    {
      id: 'django-commands',
      title: 'Django Management Commands',
      description: 'Common Django management commands and utilities',
      type: 'cheat-sheet',
      icon: '🔧',
      courseId: 'django-mastery',
      relevanceScore: 0.72,
      relationshipType: 'similar',
      commonTags: ['django', 'commands', 'management'],
      viewCount: 1654,
      isFavorited: false
    }
  ]

  // Filter out current resource and sort by relevance
  relatedResources.value = mockRelated
    .filter(r => r.id !== props.currentResource.id)
    .sort((a, b) => b.relevanceScore - a.relevanceScore)

  // Generate suggested learning path
  const pathResources = mockRelated
    .filter(r => r.relationshipType === 'prerequisite' || r.relationshipType === 'follow-up')
    .sort((a, b) => {
      if (a.relationshipType === 'prerequisite' && b.relationshipType === 'follow-up') return -1
      if (a.relationshipType === 'follow-up' && b.relationshipType === 'prerequisite') return 1
      return b.relevanceScore - a.relevanceScore
    })

  suggestedPath.value = pathResources.slice(0, 3)
}

// Lifecycle
onMounted(() => {
  findRelatedResources()
})
</script>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>