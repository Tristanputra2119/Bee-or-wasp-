<script setup lang="ts">
import { ref, computed } from 'vue'

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
const isDragover = ref(false)

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
    error.value = 'Gagal mengklasifikasi gambar. Pastikan server Python sudah berjalan.'
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

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    handleImageUploaded(target.files[0])
  }
}

const handleDrop = (event: DragEvent) => {
  event.preventDefault()
  isDragover.value = false
  if (event.dataTransfer?.files && event.dataTransfer.files[0]) {
    handleImageUploaded(event.dataTransfer.files[0])
  }
}

const handleDragOver = (event: DragEvent) => {
  event.preventDefault()
  isDragover.value = true
}

const handleDragLeave = () => {
  isDragover.value = false
}

const triggerFileInput = () => {
  const input = document.getElementById('fileInput') as HTMLInputElement
  input?.click()
}

const getClassEmoji = computed(() => {
  if (!result.value) return '🔍'
  switch (result.value.class_name) {
    case 'Lebah': return '🐝'
    case 'Tawon': return '🐝'
    case 'Lainnya': return '🦗'
    case 'Bukan_Serangga': return '❌'
    default: return '🔍'
  }
})

const getClassLabel = computed(() => {
  if (!result.value) return ''
  switch (result.value.class_name) {
    case 'Lebah': return 'Lebah'
    case 'Tawon': return 'Tawon'
    case 'Lainnya': return 'Serangga Lainnya'
    case 'Bukan_Serangga': return 'Bukan Serangga'
    default: return result.value.class_name
  }
})

const formatPercent = (value: number) => {
  return (value * 100).toFixed(1) + '%'
}
</script>

<template>
  <div class="container">
    <!-- Header -->
    <header class="header">
      <h1>🐝 Klasifikasi Lebah & Tawon</h1>
      <p>Upload gambar untuk mengidentifikasi jenis serangga</p>
    </header>

    <!-- Main Content -->
    <div class="main-grid">
      <!-- Upload Section -->
      <div class="card">
        <h3 class="card-title">📷 Upload Gambar</h3>
        
        <div 
          v-if="!uploadedImage"
          class="upload-area"
          :class="{ dragover: isDragover }"
          @click="triggerFileInput"
          @drop="handleDrop"
          @dragover="handleDragOver"
          @dragleave="handleDragLeave"
        >
          <div class="upload-icon">📁</div>
          <p class="upload-text">
            Drag & drop gambar di sini<br>
            atau <span>klik untuk memilih</span>
          </p>
          <input 
            type="file" 
            id="fileInput"
            class="file-input"
            accept="image/*"
            @change="handleFileSelect"
          >
        </div>

        <!-- Preview -->
        <div v-else class="preview-container">
          <img :src="uploadedImage" alt="Preview" class="preview-image">
          <button @click="resetUpload" class="reset-btn">🔄 Upload Gambar Lain</button>
        </div>
      </div>

      <!-- Result Section -->
      <div class="card">
        <h3 class="card-title">📊 Hasil Klasifikasi</h3>

        <!-- Loading -->
        <div v-if="isLoading" class="loading">
          <div class="spinner"></div>
          <p>Menganalisis gambar...</p>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="error-box">
          <div class="error-icon">⚠️</div>
          <p>{{ error }}</p>
          <button @click="resetUpload" class="retry-btn">Coba Lagi</button>
        </div>

        <!-- Result -->
        <div v-else-if="result" class="result-box">
          <div class="result-emoji">{{ getClassEmoji }}</div>
          <div class="result-class">{{ getClassLabel }}</div>
          <div class="result-confidence">
            Kepercayaan: {{ formatPercent(result.confidence) }}
          </div>
          <div class="confidence-bar">
            <div 
              class="confidence-fill" 
              :style="{ width: formatPercent(result.confidence) }"
            ></div>
          </div>

          <!-- All Predictions -->
          <div class="all-predictions">
            <h4>Semua Prediksi:</h4>
            <div 
              v-for="pred in result.all_predictions" 
              :key="pred.class_name"
              class="prediction-item"
            >
              <span class="prediction-name">{{ pred.class_name.replace('_', ' ') }}</span>
              <span class="prediction-percent">{{ formatPercent(pred.confidence) }}</span>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else class="empty-state">
          <div class="empty-icon">🔍</div>
          <p>Upload gambar untuk melihat hasil</p>
        </div>
      </div>
    </div>

    <!-- Info Cards -->
    <div class="info-grid">
      <div class="info-card">
        <div class="info-emoji">🐝</div>
        <div class="info-title">Lebah</div>
        <div class="info-desc">Penyerbuk dengan tubuh berbulu</div>
      </div>
      <div class="info-card">
        <div class="info-emoji">🐝</div>
        <div class="info-title">Tawon</div>
        <div class="info-desc">Predator dengan pinggang ramping</div>
      </div>
      <div class="info-card">
        <div class="info-emoji">🦗</div>
        <div class="info-title">Serangga Lainnya</div>
        <div class="info-desc">Bukan lebah atau tawon</div>
      </div>
      <div class="info-card">
        <div class="info-emoji">❌</div>
        <div class="info-title">Bukan Serangga</div>
        <div class="info-desc">Objek selain serangga</div>
      </div>
    </div>

    <!-- Footer -->
    <footer class="footer">
      <p>Klasifikasi menggunakan Deep Learning</p>
    </footer>
  </div>
</template>
