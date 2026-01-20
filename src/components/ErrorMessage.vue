<template>
  <div class="error-container">
    <div class="error-icon">⚠️</div>
    <h2>Error Loading Data</h2>
    <p>{{ message }}</p>
    <button @click="$emit('retry')" class="retry-button">
      Try Again
    </button>
  </div>
</template>

<script setup>
defineProps({
  message: {
    type: String,
    required: true
  }
})

defineEmits(['retry'])
</script>

<style scoped>
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  gap: 1rem;
  text-align: center;
}

.error-icon {
  font-size: 3rem;
}

.error-container h2 {
  color: var(--color-error);
  margin: 0;
  font-size: 1.5rem;
}

.error-container p {
  color: var(--color-text-secondary);
  margin: 0;
  max-width: 500px;
}

.retry-button {
  margin-top: 1rem;
  padding: 0.75rem 1.5rem;
  background-color: var(--color-primary);
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.retry-button:hover {
  background-color: var(--color-primary-dark);
}
</style>
