<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="isOpen" class="modal-overlay" @click="handleOverlayClick">
        <div class="modal-content" @click.stop role="dialog" aria-modal="true">
          <button
            class="modal-close"
            @click="closeModal"
            aria-label="Close modal"
          >
            ✕
          </button>

          <div class="modal-body">
            <div class="modal-header">
              <img
                :src="imageUrl"
                :alt="person.name || 'Person avatar'"
                class="modal-avatar"
                @error="handleImageError"
              />
              <div class="modal-header-info">
                <h2 class="modal-name">{{ person.name || 'Anonymous' }}</h2>
                <p v-if="person.company" class="modal-company">{{ person.company }}</p>
                <p v-if="person.location" class="modal-location">📍 {{ person.location }}</p>
              </div>
            </div>

            <div v-if="person.bio" class="modal-bio" v-html="person.bio"></div>

            <div v-if="person.category && person.category.length > 0" class="modal-categories">
              <h3 class="section-title">Categories</h3>
              <div class="categories-list">
                <span
                  v-for="(cat, index) in person.category"
                  :key="index"
                  class="category-badge"
                >
                  {{ cat }}
                </span>
              </div>
            </div>

            <div v-if="hasSocialLinks" class="modal-social">
              <h3 class="section-title">Connect</h3>
              <div class="social-links">
                <a
                  v-if="person.linkedin"
                  :href="person.linkedin"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="social-link linkedin"
                >
                  <span class="social-icon">in</span>
                  LinkedIn
                </a>
                <a
                  v-if="person.twitter"
                  :href="getTwitterUrl(person.twitter)"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="social-link twitter"
                >
                  <span class="social-icon">𝕏</span>
                  Twitter
                </a>
                <a
                  v-if="person.github"
                  :href="getGitHubUrl(person.github)"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="social-link github"
                >
                  <span class="social-icon">⌘</span>
                  GitHub
                </a>
                <a
                  v-if="person.wechat"
                  :href="person.wechat"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="social-link wechat"
                >
                  <span class="social-icon">💬</span>
                  WeChat
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  isOpen: {
    type: Boolean,
    required: true
  },
  person: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close'])

const imageFailed = ref(false)

const imageUrl = computed(() => {
  if (imageFailed.value) {
    return 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="100" height="100"%3E%3Crect width="100" height="100" fill="%23e0e0e0"/%3E%3Ctext x="50%25" y="50%25" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="40" fill="%23999"%3E?%3C/text%3E%3C/svg%3E'
  }

  if (props.person.image) {
    return `https://raw.githubusercontent.com/cncf/people/main/images/${props.person.image}`
  }

  return 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="100" height="100"%3E%3Crect width="100" height="100" fill="%23e0e0e0"/%3E%3Ctext x="50%25" y="50%25" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="40" fill="%23999"%3E?%3C/text%3E%3C/svg%3E'
})

const hasSocialLinks = computed(() => {
  return props.person.linkedin || props.person.twitter || props.person.github || props.person.wechat
})

const handleImageError = () => {
  imageFailed.value = true
}

const closeModal = () => {
  emit('close')
}

const handleOverlayClick = () => {
  closeModal()
}

const getTwitterUrl = (twitter) => {
  if (!twitter) return ''
  if (twitter.startsWith('http')) return twitter
  const handle = twitter.replace('@', '')
  return `https://twitter.com/${handle}`
}

const getGitHubUrl = (github) => {
  if (!github) return ''
  if (github.startsWith('http')) return github
  return `https://github.com/${github}`
}

watch(() => props.isOpen, (newValue) => {
  if (newValue) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
    imageFailed.value = false
  }
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.75);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
  overflow-y: auto;
}

.modal-content {
  background-color: var(--color-background);
  border-radius: var(--border-radius);
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow: var(--shadow-lg);
}

.modal-close {
  position: sticky;
  top: 1rem;
  right: 1rem;
  float: right;
  background-color: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: var(--color-text-primary);
  cursor: pointer;
  transition: all var(--transition-speed);
  z-index: 10;
}

.modal-close:hover {
  background-color: var(--color-hover);
  transform: scale(1.1);
}

.modal-body {
  padding: 2rem;
  clear: both;
}

.modal-header {
  display: flex;
  gap: 1.5rem;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.modal-avatar {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid var(--color-border);
  flex-shrink: 0;
}

.modal-header-info {
  flex: 1;
  padding-top: 0.5rem;
}

.modal-name {
  margin: 0 0 0.5rem 0;
  font-size: 2rem;
  color: var(--color-text-primary);
}

.modal-company {
  margin: 0.5rem 0;
  color: var(--color-text-secondary);
  font-weight: 500;
  font-size: 1.1rem;
}

.modal-location {
  margin: 0.5rem 0 0 0;
  color: var(--color-text-secondary);
  font-size: 1rem;
}

.modal-bio {
  color: var(--color-text-secondary);
  font-size: 1rem;
  line-height: 1.7;
  margin-bottom: 2rem;
}

.modal-bio :deep(p) {
  margin-bottom: 1rem;
}

.modal-bio :deep(a) {
  color: var(--color-primary);
  text-decoration: underline;
}

.section-title {
  font-size: 1.25rem;
  margin-bottom: 1rem;
  color: var(--color-text-primary);
}

.modal-categories {
  margin-bottom: 2rem;
}

.categories-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.category-badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  background-color: var(--color-surface);
  color: var(--color-primary);
  border-radius: 20px;
  font-size: 0.95rem;
  font-weight: 500;
  border: 2px solid var(--color-border);
}

.modal-social {
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 2px solid var(--color-border);
}

.social-links {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.social-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  color: white;
  transition: opacity var(--transition-speed), transform var(--transition-speed);
  text-decoration: none;
}

.social-link:hover {
  opacity: 0.85;
  transform: translateY(-2px);
}

.social-icon {
  font-size: 1.2rem;
}

.social-link.linkedin {
  background-color: #0077b5;
}

.social-link.twitter {
  background-color: #1da1f2;
}

.social-link.github {
  background-color: #333;
}

.social-link.wechat {
  background-color: #09b83e;
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity var(--transition-speed);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .modal-content,
.modal-leave-active .modal-content {
  transition: transform var(--transition-speed);
}

.modal-enter-from .modal-content,
.modal-leave-to .modal-content {
  transform: scale(0.9);
}

@media (max-width: 768px) {
  .modal-overlay {
    padding: 0;
    align-items: flex-start;
  }

  .modal-content {
    max-height: 100vh;
    border-radius: 0;
  }

  .modal-body {
    padding: 1.5rem;
  }

  .modal-header {
    flex-direction: column;
    align-items: center;
    text-align: center;
  }

  .modal-avatar {
    width: 100px;
    height: 100px;
  }

  .modal-name {
    font-size: 1.5rem;
  }

  .social-links {
    justify-content: center;
  }

  .social-link {
    flex: 1;
    min-width: calc(50% - 0.5rem);
    justify-content: center;
  }
}
</style>
