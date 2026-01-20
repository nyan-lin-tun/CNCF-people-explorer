<template>
  <div class="search-bar">
    <div class="search-input-wrapper">
      <span class="search-icon">🔍</span>
      <input
        type="text"
        :value="modelValue"
        @input="$emit('update:modelValue', $event.target.value)"
        placeholder="Search by name, company, location, or bio..."
        class="search-input"
      />
      <button
        v-if="modelValue"
        @click="$emit('update:modelValue', '')"
        class="clear-button"
        aria-label="Clear search"
      >
        ✕
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { trackSearch } from '../utils/analytics'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue'])

// Debounced search tracking
let searchTimeout = null
watch(() => props.modelValue, (newValue) => {
  if (searchTimeout) clearTimeout(searchTimeout)

  if (newValue && newValue.trim()) {
    searchTimeout = setTimeout(() => {
      trackSearch(newValue)
    }, 1000) // Track after user stops typing for 1 second
  }
})
</script>

<style scoped>
.search-bar {
  margin-bottom: 1.5rem;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  max-width: 600px;
  margin: 0 auto;
}

.search-icon {
  position: absolute;
  left: 1rem;
  font-size: 1.2rem;
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 0.875rem 3rem;
  font-size: 1rem;
  border: 2px solid var(--color-border);
  border-radius: var(--border-radius);
  background-color: var(--color-background);
  color: var(--color-text-primary);
  transition: border-color var(--transition-speed), box-shadow var(--transition-speed);
}

.search-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(67, 108, 244, 0.1);
}

.clear-button {
  position: absolute;
  right: 0.5rem;
  padding: 0.5rem;
  background: none;
  border: none;
  color: var(--color-text-secondary);
  font-size: 1.25rem;
  cursor: pointer;
  border-radius: 4px;
  transition: background-color var(--transition-speed);
  min-width: 44px;
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.clear-button:hover {
  background-color: var(--color-hover);
}

@media (max-width: 768px) {
  .search-input-wrapper {
    max-width: 100%;
  }

  .search-input {
    padding: 0.875rem 2.5rem;
    font-size: 0.95rem;
  }
}
</style>
