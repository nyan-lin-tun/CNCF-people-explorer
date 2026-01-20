import { ref, watch, onMounted } from 'vue'

const isDark = ref(false)

export function useTheme() {
  const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches

    isDark.value = savedTheme === 'dark' || (!savedTheme && prefersDark)
    applyTheme()
  }

  const applyTheme = () => {
    if (isDark.value) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  const toggleTheme = () => {
    isDark.value = !isDark.value
    localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
    applyTheme()
  }

  watch(isDark, () => {
    applyTheme()
  })

  onMounted(() => {
    initTheme()
  })

  return {
    isDark,
    toggleTheme
  }
}
