# Vue.js Implementation Examples

## Sample Vue Component Structure

### QuizQuestion.vue
```vue
<template>
  <div class="max-w-2xl mx-auto p-6">
    <div class="bg-white rounded-lg shadow-md p-6">
      <h3 class="text-xl font-semibold mb-4">
        Question {{ currentIndex + 1 }} of {{ totalQuestions }}
      </h3>
      
      <p class="text-lg mb-6">{{ question.question }}</p>
      
      <div class="space-y-3">
        <button
          v-for="(option, index) in question.options"
          :key="index"
          @click="selectAnswer(index)"
          :class="getOptionClass(index)"
          class="w-full text-left p-4 rounded-lg border-2 transition-all"
        >
          {{ option }}
        </button>
      </div>
      
      <div v-if="showExplanation" class="mt-6 p-4 bg-blue-50 rounded-lg">
        <p class="text-sm text-blue-900">{{ question.explanation }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  question: Object,
  currentIndex: Number,
  totalQuestions: Number
})

const emit = defineEmits(['answer-selected'])

const selectedAnswer = ref(null)
const showExplanation = ref(false)

const selectAnswer = (index) => {
  selectedAnswer.value = index
  showExplanation.value = true
  
  setTimeout(() => {
    emit('answer-selected', {
      questionId: props.question.id,
      answer: index,
      isCorrect: index === props.question.correct
    })
  }, 2000)
}

const getOptionClass = (index) => {
  if (selectedAnswer.value === null) return 'hover:border-blue-400'
  
  if (index === props.question.correct) {
    return 'border-green-500 bg-green-50'
  }
  
  if (index === selectedAnswer.value && index !== props.question.correct) {
    return 'border-red-500 bg-red-50'
  }
  
  return 'border-gray-200'
}
</script>
```

### useStorage.js Composable
```javascript
import { ref, watch } from 'vue'

export function useStorage(key, defaultValue) {
  const storedValue = localStorage.getItem(key)
  const data = ref(storedValue ? JSON.parse(storedValue) : defaultValue)
  
  watch(data, (newValue) => {
    localStorage.setItem(key, JSON.stringify(newValue))
  }, { deep: true })
  
  return data
}

// Usage in components
export function useProgress() {
  const progress = useStorage('claudeLearnProgress', {
    completedModules: [],
    quizScores: {},
    currentModule: null,
    totalTimeSpent: 0,
    lastAccessed: null
  })
  
  const markModuleComplete = (moduleId) => {
    if (!progress.value.completedModules.includes(moduleId)) {
      progress.value.completedModules.push(moduleId)
    }
  }
  
  const saveQuizScore = (moduleId, score, total) => {
    progress.value.quizScores[moduleId] = {
      score,
      total,
      timestamp: new Date().toISOString()
    }
  }
  
  const getModuleProgress = (moduleId) => {
    return {
      completed: progress.value.completedModules.includes(moduleId),
      quizScore: progress.value.quizScores[moduleId] || null
    }
  }
  
  return {
    progress,
    markModuleComplete,
    saveQuizScore,
    getModuleProgress
  }
}
```

### Module.vue Page Component
```vue
<template>
  <div class="min-h-screen bg-gray-50">
    <Navigation />
    
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-4xl mx-auto">
        <!-- Module Header -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-6">
          <h1 class="text-3xl font-bold mb-2">{{ module.title }}</h1>
          <p class="text-gray-600">{{ module.description }}</p>
          
          <ProgressBar 
            :current="sectionIndex + 1" 
            :total="module.sections.length" 
            class="mt-4"
          />
        </div>
        
        <!-- Module Content -->
        <div class="bg-white rounded-lg shadow-md p-8">
          <div v-html="currentSection.content" class="prose max-w-none"></div>
          
          <!-- Code Example -->
          <div v-if="currentSection.example" class="mt-6">
            <h3 class="text-lg font-semibold mb-3">Example:</h3>
            <pre class="bg-gray-900 text-white p-4 rounded-lg overflow-x-auto">
              <code>{{ currentSection.example }}</code>
            </pre>
          </div>
          
          <!-- Navigation Buttons -->
          <div class="flex justify-between mt-8">
            <button
              @click="previousSection"
              :disabled="sectionIndex === 0"
              class="px-6 py-2 bg-gray-200 rounded-lg disabled:opacity-50"
            >
              Previous
            </button>
            
            <button
              v-if="sectionIndex < module.sections.length - 1"
              @click="nextSection"
              class="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
            >
              Next
            </button>
            
            <router-link
              v-else
              :to="`/quiz/${moduleId}`"
              class="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
            >
              Take Quiz
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useProgress } from '@/composables/useProgress'
import Navigation from '@/components/Navigation.vue'
import ProgressBar from '@/components/ProgressBar.vue'

const route = useRoute()
const { progress } = useProgress()

const moduleId = computed(() => route.params.id)
const module = ref(null)
const sectionIndex = ref(0)

const currentSection = computed(() => {
  return module.value?.sections[sectionIndex.value] || {}
})

const loadModule = async () => {
  const response = await fetch(`/data/modules.json`)
  const data = await response.json()
  module.value = data[moduleId.value]
}

const nextSection = () => {
  if (sectionIndex.value < module.value.sections.length - 1) {
    sectionIndex.value++
  }
}

const previousSection = () => {
  if (sectionIndex.value > 0) {
    sectionIndex.value--
  }
}

onMounted(() => {
  loadModule()
  progress.value.currentModule = moduleId.value
  progress.value.lastAccessed = new Date().toISOString()
})
</script>
```

## Key Vue + Tailwind Benefits

1. **Reactive Quiz State** - Vue's reactivity makes quiz interactions smooth
2. **Component Reusability** - Build once, use everywhere
3. **Tailwind Utility Classes** - Rapid, consistent styling
4. **Composition API** - Clean, reusable logic with composables
5. **Built-in Transitions** - Vue's transition system for smooth animations

## Vue Router Setup
```javascript
// src/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/views/Home.vue'
import Module from '@/views/Module.vue'
import Quiz from '@/views/Quiz.vue'
import Results from '@/views/Results.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/module/:id',
      name: 'module',
      component: Module
    },
    {
      path: '/quiz/:id',
      name: 'quiz',
      component: Quiz
    },
    {
      path: '/results',
      name: 'results',
      component: Results
    }
  ]
})

export default router
```