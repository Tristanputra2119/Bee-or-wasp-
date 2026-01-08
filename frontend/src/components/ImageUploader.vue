<script setup lang="ts">
import { ref } from 'vue'

defineProps<{
  disabled?: boolean
}>()

const emit = defineEmits<{
  'image-uploaded': [file: File]
}>()

const isDragging = ref(false)
const fileInput = ref<HTMLInputElement | null>(null)

const handleDragEnter = (e: DragEvent) => {
  e.preventDefault()
  isDragging.value = true
}

const handleDragLeave = (e: DragEvent) => {
  e.preventDefault()
  isDragging.value = false
}

const handleDrop = (e: DragEvent) => {
  e.preventDefault()
  isDragging.value = false
  
  const files = e.dataTransfer?.files
  const file = files?.[0]
  if (file) {
    handleFile(file)
  }
}

const handleFileSelect = (e: Event) => {
  const target = e.target as HTMLInputElement
  const files = target.files
  const file = files?.[0]
  if (file) {
    handleFile(file)
  }
}

const handleFile = (file: File) => {
  if (!file.type.startsWith('image/')) {
    alert('Please upload an image file')
    return
  }
  emit('image-uploaded', file)
}

const openFileDialog = () => {
  fileInput.value?.click()
}
</script>

<template>
  <div
    class="drop-zone rounded-2xl p-8 text-center cursor-pointer transition-all duration-300"
    :class="{ 
      'active': isDragging,
      'opacity-50 cursor-not-allowed': disabled 
    }"
    @dragenter="handleDragEnter"
    @dragover.prevent
    @dragleave="handleDragLeave"
    @drop="handleDrop"
    @click="!disabled && openFileDialog()"
  >
    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      class="hidden"
      @change="handleFileSelect"
      :disabled="disabled"
    />
    
    <div class="space-y-4">
      <div class="w-16 h-16 mx-auto bg-primary/20 rounded-full flex items-center justify-center">
        <svg class="w-8 h-8 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
        </svg>
      </div>
      
      <div>
        <p class="text-lg font-medium">
          <span v-if="isDragging" class="text-primary">Drop your image here!</span>
          <span v-else>Drag & drop an image here</span>
        </p>
        <p class="text-text-secondary text-sm mt-1">or click to browse</p>
      </div>
      
      <p class="text-xs text-text-secondary">
        Supports: JPG, PNG, WebP (Max 10MB)
      </p>
    </div>
  </div>
</template>
