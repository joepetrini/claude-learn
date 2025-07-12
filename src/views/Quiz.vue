<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Navigation Bar -->
    <nav class="bg-white shadow-sm border-b">
      <div class="container mx-auto px-4 py-4">
        <router-link :to="`/module/${moduleId}`" class="text-blue-600 hover:text-blue-800 font-medium">
          ← Back to Module
        </router-link>
      </div>
    </nav>

    <div class="container mx-auto px-4 py-8">
      <div v-if="loading" class="text-center py-12">
        <p class="text-gray-500">Loading quiz...</p>
      </div>
      
      <div v-else-if="quiz && !quizCompleted" class="max-w-3xl mx-auto">
        <!-- Quiz Header -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-6">
          <h1 class="text-2xl font-bold mb-2">{{ quiz.title }}</h1>
          <div class="flex justify-between items-center text-sm text-gray-600">
            <span>Question {{ currentQuestionIndex + 1 }} of {{ quiz.questions.length }}</span>
            <span>Score: {{ score }} / {{ answeredQuestions }}</span>
          </div>
          
          <!-- Progress Bar -->
          <div class="mt-4">
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div 
                class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                :style="`width: ${progressPercentage}%`"
              ></div>
            </div>
          </div>
        </div>
        
        <!-- Question Card -->
        <div class="bg-white rounded-lg shadow-md p-8">
          <h2 class="text-xl font-semibold mb-6">
            {{ currentQuestion.question }}
          </h2>
          
          <div class="space-y-3">
            <button
              v-for="(option, index) in currentQuestion.options"
              :key="index"
              @click="selectAnswer(index)"
              :disabled="selectedAnswer !== null"
              :class="getOptionClass(index)"
              class="w-full text-left p-4 rounded-lg border-2 transition-all duration-200"
            >
              <span class="flex items-center">
                <span class="mr-3 font-semibold">{{ String.fromCharCode(65 + index) }}.</span>
                {{ option }}
              </span>
            </button>
          </div>
          
          <!-- Explanation -->
          <div v-if="showExplanation" class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
            <p class="text-sm text-blue-900">
              <strong>Explanation:</strong> {{ currentQuestion.explanation }}
            </p>
          </div>
          
          <!-- Navigation -->
          <div class="mt-8 flex justify-between">
            <button
              v-if="currentQuestionIndex > 0"
              @click="previousQuestion"
              class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
            >
              ← Previous
            </button>
            <div v-else></div>
            
            <button
              v-if="selectedAnswer !== null && currentQuestionIndex < quiz.questions.length - 1"
              @click="nextQuestion"
              class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Next →
            </button>
            
            <button
              v-else-if="selectedAnswer !== null && currentQuestionIndex === quiz.questions.length - 1"
              @click="completeQuiz"
              class="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
            >
              Complete Quiz →
            </button>
          </div>
        </div>
      </div>
      
      <!-- Quiz Results -->
      <div v-else-if="quizCompleted" class="max-w-3xl mx-auto">
        <div class="bg-white rounded-lg shadow-md p-8 text-center">
          <h1 class="text-3xl font-bold mb-4">Quiz Complete! 🎉</h1>
          
          <div class="mb-8">
            <div class="text-6xl font-bold mb-2" :class="scoreClass">
              {{ Math.round((score / quiz.questions.length) * 100) }}%
            </div>
            <p class="text-xl text-gray-600">
              You got {{ score }} out of {{ quiz.questions.length }} questions correct
            </p>
          </div>
          
          <!-- Results Summary -->
          <div class="mb-8 text-left max-w-md mx-auto">
            <h3 class="font-semibold mb-3">Your Answers:</h3>
            <div class="space-y-2">
              <div 
                v-for="(answer, index) in userAnswers" 
                :key="index"
                class="flex items-center justify-between p-2 rounded"
                :class="answer.correct ? 'bg-green-50' : 'bg-red-50'"
              >
                <span>Question {{ index + 1 }}</span>
                <span v-if="answer.correct" class="text-green-600">✓ Correct</span>
                <span v-else class="text-red-600">✗ Incorrect</span>
              </div>
            </div>
          </div>
          
          <div class="flex gap-4 justify-center">
            <router-link
              :to="`/module/${moduleId}`"
              class="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
            >
              Review Module
            </router-link>
            <router-link
              to="/"
              class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Back to Modules
            </router-link>
          </div>
        </div>
      </div>
      
      <div v-else class="text-center py-12">
        <p class="text-red-600">Quiz not found</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useQuizKeyboard } from '../composables/useKeyboardNavigation.js'
import { useSupabaseProgress } from '../composables/useSupabaseProgress.js'

const route = useRoute()
const moduleId = computed(() => route.params.id)

const quiz = ref(null)
const loading = ref(true)
const currentQuestionIndex = ref(0)
const selectedAnswer = ref(null)
const showExplanation = ref(false)
const userAnswers = ref([])
const quizCompleted = ref(false)

// Initialize Supabase progress composable
const { saveQuizScore } = useSupabaseProgress()

const currentQuestion = computed(() => {
  return quiz.value?.questions[currentQuestionIndex.value] || {}
})

const progressPercentage = computed(() => {
  if (!quiz.value) return 0
  return Math.round(((currentQuestionIndex.value + 1) / quiz.value.questions.length) * 100)
})

const score = computed(() => {
  return userAnswers.value.filter(answer => answer.correct).length
})

const answeredQuestions = computed(() => {
  return userAnswers.value.length
})

const scoreClass = computed(() => {
  const percentage = (score.value / quiz.value?.questions.length) * 100
  if (percentage >= 80) return 'text-green-600'
  if (percentage >= 60) return 'text-yellow-600'
  return 'text-red-600'
})

const getOptionClass = (index) => {
  if (selectedAnswer.value === null) {
    return 'hover:border-blue-400 hover:bg-blue-50 cursor-pointer'
  }
  
  if (index === currentQuestion.value.correct) {
    return 'border-green-500 bg-green-50'
  }
  
  if (index === selectedAnswer.value && index !== currentQuestion.value.correct) {
    return 'border-red-500 bg-red-50'
  }
  
  return 'border-gray-300 opacity-50'
}

const loadQuiz = async () => {
  loading.value = true
  try {
    const response = await fetch(import.meta.env.BASE_URL + 'data/quizzes.json')
    const data = await response.json()
    quiz.value = data.quizzes[moduleId.value]
    
    // Load any saved progress
    const savedProgress = localStorage.getItem(`quiz_${moduleId.value}_progress`)
    if (savedProgress) {
      const progress = JSON.parse(savedProgress)
      currentQuestionIndex.value = progress.currentIndex || 0
      userAnswers.value = progress.answers || []
    }
  } catch (error) {
    console.error('Failed to load quiz:', error)
  } finally {
    loading.value = false
  }
}

const selectAnswer = (index) => {
  if (selectedAnswer.value !== null) return
  
  selectedAnswer.value = index
  showExplanation.value = true
  
  const isCorrect = index === currentQuestion.value.correct
  
  // Update or add answer
  if (userAnswers.value[currentQuestionIndex.value]) {
    userAnswers.value[currentQuestionIndex.value] = { answer: index, correct: isCorrect }
  } else {
    userAnswers.value.push({ answer: index, correct: isCorrect })
  }
  
  // Save progress
  saveProgress()
}

const nextQuestion = () => {
  currentQuestionIndex.value++
  selectedAnswer.value = null
  showExplanation.value = false
  
  // Check if we already answered this question
  const previousAnswer = userAnswers.value[currentQuestionIndex.value]
  if (previousAnswer) {
    selectedAnswer.value = previousAnswer.answer
    showExplanation.value = true
  }
}

const previousQuestion = () => {
  currentQuestionIndex.value--
  
  const previousAnswer = userAnswers.value[currentQuestionIndex.value]
  if (previousAnswer) {
    selectedAnswer.value = previousAnswer.answer
    showExplanation.value = true
  } else {
    selectedAnswer.value = null
    showExplanation.value = false
  }
}

const completeQuiz = async () => {
  quizCompleted.value = true
  
  // Save quiz completion using Supabase progress composable
  const answers = userAnswers.value.map((answer, index) => ({
    selected: answer.answer,
    correct: answer.correct
  }))
  
  await saveQuizScore(moduleId.value, score.value, quiz.value.questions.length, answers)
  
  // Clear quiz progress
  localStorage.removeItem(`quiz_${moduleId.value}_progress`)
}

const saveProgress = () => {
  const progress = {
    currentIndex: currentQuestionIndex.value,
    answers: userAnswers.value
  }
  localStorage.setItem(`quiz_${moduleId.value}_progress`, JSON.stringify(progress))
}

// Initialize quiz keyboard navigation
useQuizKeyboard()

// Handle keyboard events for quiz
const handleQuizSelect = (event) => {
  const index = event.detail
  if (selectedAnswer.value === null && index < currentQuestion.value.options.length) {
    selectAnswer(index)
  }
}

const handleQuizContinue = async () => {
  if (selectedAnswer.value !== null) {
    if (currentQuestionIndex.value === quiz.value.questions.length - 1) {
      await completeQuiz()
    } else {
      nextQuestion()
    }
  }
}

onMounted(() => {
  loadQuiz()
  
  // Listen for quiz keyboard events
  window.addEventListener('quiz-select-answer', handleQuizSelect)
  window.addEventListener('quiz-continue', handleQuizContinue)
})

// Clean up event listeners
onUnmounted(() => {
  window.removeEventListener('quiz-select-answer', handleQuizSelect)
  window.removeEventListener('quiz-continue', handleQuizContinue)
})
</script>

<style scoped>
button:disabled {
  cursor: not-allowed;
}
</style>