<script setup lang="ts">
import { ref, computed } from 'vue'
import ImageUploader from './components/ImageUploader.vue'
import ResultCard from './components/ResultCard.vue'

interface PredictionResult {
  class_name: string
  confidence: number
  all_predictions: {
    class_name: string
    confidence: number
  }[]
}

const result = ref<PredictionResult | null>(null)
const isLoading = ref(false)
const error = ref<string | null>(null)
const uploadedImage = ref<string | null>(null)

const handleImageUploaded = async (file: File) => {
  isLoading.value = true
  error.value = null
  result.value = null
  
  // Create preview
  const reader = new FileReader()
  reader.onload = (e) => {
    uploadedImage.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
  
  // Send to API
  const formData = new FormData()
  formData.append('file', file)
  
  try {
    const response = await fetch('/api/predict', {
      method: 'POST',
      body: formData
    })
    
    if (!response.ok) {
      throw new Error('Prediction failed')
    }
    
    result.value = await response.json()
  } catch (err) {
    error.value = 'Failed to classify image. Make sure the Python server is running.'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

const resetUpload = () => {
  result.value = null
  uploadedImage.value = null
  error.value = null
}

const getClassEmoji = computed(() => {
  if (!result.value) return '🔍'
  switch (result.value.class_name) {
    case 'Lebah': return '🐝'
    case 'Tawon': return '🐝'
    case 'Lainnya': return '❓'
    default: return '🔍'
  }
})

const getClassLabel = computed(() => {
  if (!result.value) return ''
  switch (result.value.class_name) {
    case 'Lebah': return 'Bee'
    case 'Tawon': return 'Wasp'
    case 'Lainnya': return 'Other'
    default: return result.value.class_name
  }
})
</script>

<template>
  <div class="min-h-screen relative overflow-hidden">
    <!-- Background decorations -->
    <div class="absolute inset-0 pointer-events-none">
      <div class="absolute top-20 left-10 w-72 h-72 bg-primary/10 rounded-full blur-3xl animate-float"></div>
      <div class="absolute bottom-20 right-10 w-96 h-96 bg-bee-yellow/10 rounded-full blur-3xl animate-float" style="animation-delay: -3s;"></div>
      <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-wasp-red/5 rounded-full blur-3xl"></div>
    </div>

    <!-- Main Content -->
    <div class="relative z-10 container mx-auto px-4 py-8 md:py-16">
      <!-- Header -->
      <header class="text-center mb-12">
        <div class="inline-flex items-center gap-4 mb-4">
          <span class="text-5xl md:text-6xl animate-float">🐝</span>
          <h1 class="text-4xl md:text-6xl font-bold gradient-text">
            Bee vs Wasp
          </h1>
          <span class="text-5xl md:text-6xl animate-float" style="animation-delay: -1.5s;">🐝</span>
        </div>
        <p class="text-text-secondary text-lg md:text-xl max-w-2xl mx-auto">
          Upload an image to identify whether it's a <span class="text-bee-yellow font-semibold">Bee</span>, 
          a <span class="text-wasp-red font-semibold">Wasp</span>, or something else entirely!
        </p>
      </header>

      <!-- Main Card -->
      <div class="max-w-4xl mx-auto">
        <div class="glass-card p-6 md:p-10">
          <div class="grid md:grid-cols-2 gap-8">
            <!-- Upload Section -->
            <div class="space-y-6">
              <h2 class="text-xl font-semibold flex items-center gap-2">
                <svg class="w-6 h-6 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                Upload Image
              </h2>
              
              <ImageUploader 
                @image-uploaded="handleImageUploaded" 
                :disabled="isLoading"
              />
              
              <!-- Preview -->
              <div v-if="uploadedImage" class="relative group">
                <img 
                  :src="uploadedImage" 
                  alt="Uploaded preview" 
                  class="w-full h-48 object-cover rounded-xl border border-white/10"
                />
                <button 
                  @click="resetUpload"
                  class="absolute top-2 right-2 p-2 bg-red-500/80 hover:bg-red-500 rounded-full transition-all opacity-0 group-hover:opacity-100"
                >
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            <!-- Result Section -->
            <div class="space-y-6">
              <h2 class="text-xl font-semibold flex items-center gap-2">
                <svg class="w-6 h-6 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Classification Result
              </h2>

              <!-- Loading State -->
              <div v-if="isLoading" class="flex flex-col items-center justify-center h-64 space-y-4">
                <div class="w-16 h-16 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
                <p class="text-text-secondary animate-pulse">Analyzing image...</p>
              </div>

              <!-- Error State -->
              <div v-else-if="error" class="bg-red-500/10 border border-red-500/30 rounded-xl p-6 text-center">
                <span class="text-4xl mb-4 block">⚠️</span>
                <p class="text-red-400">{{ error }}</p>
                <button 
                  @click="resetUpload"
                  class="mt-4 px-4 py-2 bg-red-500/20 hover:bg-red-500/30 rounded-lg transition-colors"
                >
                  Try Again
                </button>
              </div>

              <!-- Result -->
              <ResultCard 
                v-else-if="result" 
                :result="result" 
                :emoji="getClassEmoji" 
                :label="getClassLabel"
              />

              <!-- Empty State -->
              <div v-else class="flex flex-col items-center justify-center h-64 text-text-secondary">
                <span class="text-6xl mb-4 opacity-50">🔍</span>
                <p>Upload an image to see results</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Info Cards -->
        <div class="grid md:grid-cols-3 gap-6 mt-8">
          <div class="glass-card p-6 text-center hover:scale-105 transition-transform duration-300">
            <span class="text-4xl mb-3 block">🐝</span>
            <h3 class="font-semibold text-bee-yellow mb-2">Lebah (Bee)</h3>
            <p class="text-sm text-text-secondary">Friendly pollinators with fuzzy bodies and rounded features</p>
          </div>
          <div class="glass-card p-6 text-center hover:scale-105 transition-transform duration-300">
            <span class="text-4xl mb-3 block">🐝</span>
            <h3 class="font-semibold text-wasp-red mb-2">Tawon (Wasp)</h3>
            <p class="text-sm text-text-secondary">Sleek predators with narrow waists and smooth bodies</p>
          </div>
          <div class="glass-card p-6 text-center hover:scale-105 transition-transform duration-300">
            <span class="text-4xl mb-3 block">❓</span>
            <h3 class="font-semibold text-forest-green mb-2">Lainnya (Other)</h3>
            <p class="text-sm text-text-secondary">Neither a bee nor a wasp - could be any other insect!</p>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <footer class="text-center mt-16 text-text-secondary text-sm">
        <p>Powered by Deep Learning • Built with Vue.js & TailwindCSS</p>
      </footer>
    </div>
  </div>
</template>
