<script setup lang="ts">
import { computed } from 'vue'

interface PredictionResult {
  class_name: string
  confidence: number
  all_predictions: {
    class_name: string
    confidence: number
  }[]
}

const props = defineProps<{
  result: PredictionResult
  emoji: string
  label: string
}>()

const confidencePercent = computed(() => {
  return (props.result.confidence * 100).toFixed(1)
})

const getClassColor = (className: string) => {
  switch (className) {
    case 'Lebah': return 'bg-bee-yellow'
    case 'Tawon': return 'bg-wasp-red'
    case 'Lainnya': return 'bg-forest-green'
    default: return 'bg-primary'
  }
}

const getClassColorText = (className: string) => {
  switch (className) {
    case 'Lebah': return 'text-bee-yellow'
    case 'Tawon': return 'text-wasp-red'
    case 'Lainnya': return 'text-forest-green'
    default: return 'text-primary'
  }
}

const translateClass = (className: string) => {
  switch (className) {
    case 'Lebah': return 'Bee'
    case 'Tawon': return 'Wasp'
    case 'Lainnya': return 'Other'
    default: return className
  }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Main Result -->
    <div class="bg-bg-card rounded-2xl p-6 text-center animate-pulse-glow">
      <span class="text-6xl mb-4 block">{{ emoji }}</span>
      <h3 class="text-2xl font-bold" :class="getClassColorText(result.class_name)">
        {{ label }}
      </h3>
      <p class="text-text-secondary mt-1">{{ result.class_name }}</p>
      
      <!-- Confidence Bar -->
      <div class="mt-4">
        <div class="flex justify-between text-sm mb-2">
          <span class="text-text-secondary">Confidence</span>
          <span class="font-semibold">{{ confidencePercent }}%</span>
        </div>
        <div class="h-3 bg-white/10 rounded-full overflow-hidden">
          <div 
            class="h-full rounded-full transition-all duration-1000 ease-out"
            :class="getClassColor(result.class_name)"
            :style="{ width: `${confidencePercent}%` }"
          ></div>
        </div>
      </div>
    </div>

    <!-- All Predictions -->
    <div class="space-y-3">
      <h4 class="text-sm font-medium text-text-secondary">All Predictions</h4>
      <div 
        v-for="pred in result.all_predictions" 
        :key="pred.class_name"
        class="flex items-center gap-3 p-3 bg-white/5 rounded-xl"
      >
        <div 
          class="w-2 h-8 rounded-full"
          :class="getClassColor(pred.class_name)"
        ></div>
        <div class="flex-1">
          <div class="flex justify-between items-center">
            <span class="font-medium">{{ translateClass(pred.class_name) }}</span>
            <span class="text-sm text-text-secondary">
              {{ (pred.confidence * 100).toFixed(1) }}%
            </span>
          </div>
          <div class="h-1.5 bg-white/10 rounded-full mt-1 overflow-hidden">
            <div 
              class="h-full rounded-full transition-all duration-700"
              :class="getClassColor(pred.class_name)"
              :style="{ width: `${pred.confidence * 100}%` }"
            ></div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
