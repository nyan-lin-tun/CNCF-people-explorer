<template>
  <div class="person-card" @click="handleClick" role="button" tabindex="0" @keypress.enter="handleClick">
    <div class="card-header">
      <img
        :src="imageUrl"
        :alt="person.name || 'Person avatar'"
        class="avatar"
        @error="handleImageError"
      />
      <div class="header-info">
        <h3 class="name">{{ person.name || 'Anonymous' }}</h3>
        <p v-if="person.company" class="company">{{ person.company }}</p>
        <p v-if="person.location" class="location">📍 {{ person.location }}</p>
      </div>
    </div>

    <div v-if="person.bio" class="bio" v-html="truncateBio(person.bio)"></div>

    <div v-if="person.category && person.category.length > 0" class="categories">
      <span
        v-for="(cat, index) in person.category"
        :key="index"
        class="category-badge"
      >
        {{ cat }}
      </span>
    </div>

    <div class="social-links">
      <a
        v-if="person.linkedin"
        :href="person.linkedin"
        target="_blank"
        rel="noopener noreferrer"
        class="social-link linkedin"
        title="LinkedIn"
      >
        LinkedIn
      </a>
      <a
        v-if="person.twitter"
        :href="getTwitterUrl(person.twitter)"
        target="_blank"
        rel="noopener noreferrer"
        class="social-link twitter"
        title="Twitter"
      >
        Twitter
      </a>
      <a
        v-if="person.github"
        :href="getGitHubUrl(person.github)"
        target="_blank"
        rel="noopener noreferrer"
        class="social-link github"
        title="GitHub"
      >
        GitHub
      </a>
      <a
        v-if="person.wechat"
        :href="person.wechat"
        target="_blank"
        rel="noopener noreferrer"
        class="social-link wechat"
        title="WeChat"
      >
        WeChat
      </a>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  person: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['click'])

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

const handleImageError = () => {
  imageFailed.value = true
}

const truncateBio = (bio) => {
  if (!bio) return ''

  // Remove HTML tags for length calculation
  const textOnly = bio.replace(/<[^>]*>/g, '')

  if (textOnly.length <= 150) {
    return bio
  }

  // Truncate and add ellipsis
  return bio.substring(0, 150) + '...'
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

const handleClick = () => {
  emit('click', props.person)
}
</script>

<style scoped>
.person-card {
  background-color: var(--color-background);
  border-radius: var(--border-radius);
  padding: 1.5rem;
  box-shadow: var(--shadow-sm);
  transition: transform var(--transition-speed), box-shadow var(--transition-speed);
  display: flex;
  flex-direction: column;
  gap: 1rem;
  height: 100%;
  cursor: pointer;
}

.person-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.card-header {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
  border: 2px solid var(--color-border);
}

.header-info {
  flex: 1;
  min-width: 0;
}

.name {
  margin: 0;
  font-size: 1.25rem;
  color: var(--color-text-primary);
  word-wrap: break-word;
}

.company {
  margin: 0.25rem 0 0 0;
  color: var(--color-text-secondary);
  font-weight: 500;
  font-size: 0.95rem;
}

.location {
  margin: 0.25rem 0 0 0;
  color: var(--color-text-secondary);
  font-size: 0.9rem;
}

.bio {
  color: var(--color-text-secondary);
  font-size: 0.95rem;
  line-height: 1.5;
  flex: 1;
}

.bio :deep(p) {
  margin: 0;
}

.bio :deep(a) {
  color: var(--color-primary);
}

.categories {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.category-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  background-color: var(--color-surface);
  color: var(--color-primary);
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 500;
  border: 1px solid var(--color-border);
}

.social-links {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  padding-top: 0.5rem;
  border-top: 1px solid var(--color-border);
}

.social-link {
  padding: 0.5rem 1rem;
  border-radius: 4px;
  font-size: 0.9rem;
  font-weight: 500;
  color: white;
  transition: opacity var(--transition-speed);
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.social-link:hover {
  opacity: 0.85;
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
</style>
