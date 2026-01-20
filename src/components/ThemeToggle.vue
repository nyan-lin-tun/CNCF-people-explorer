<template>
  <button
    @click="toggleTheme"
    class="theme-toggle"
    :aria-label="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
    :title="isDark ? 'Switch to light mode' : 'Switch to dark mode'"
  >
    <span v-if="isDark" class="icon">☀️</span>
    <span v-else class="icon">🌙</span>
  </button>
</template>

<script setup>
import { useTheme } from '../composables/useTheme'

const { isDark, toggleTheme } = useTheme()
</script>

<style scoped>
.theme-toggle {
  background-color: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--transition-speed);
  cursor: pointer;
  padding: 0;
}

.theme-toggle:hover {
  background-color: rgba(255, 255, 255, 0.3);
  transform: scale(1.05);
}

.theme-toggle:active {
  transform: scale(0.95);
}

.icon {
  font-size: 1.5rem;
  display: block;
  line-height: 1;
}

@media (max-width: 768px) {
  .theme-toggle {
    width: 44px;
    height: 44px;
  }

  .icon {
    font-size: 1.3rem;
  }
}
</style>
