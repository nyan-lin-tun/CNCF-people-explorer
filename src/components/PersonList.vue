<template>
  <div class="person-list-container">
    <div v-if="people.length === 0" class="empty-state">
      <div class="empty-icon">🔍</div>
      <h2>No results found</h2>
      <p>Try adjusting your search or filters</p>
    </div>

    <div v-else class="person-grid">
      <PersonCard
        v-for="(person, index) in people"
        :key="`${person.name}-${person.company || 'none'}-${person.location || 'none'}-${person.linkedin || index}`"
        :person="person"
      />
    </div>
  </div>
</template>

<script setup>
import PersonCard from './PersonCard.vue'

defineProps({
  people: {
    type: Array,
    required: true,
    default: () => []
  }
})
</script>

<style scoped>
.person-list-container {
  margin-bottom: 2rem;
}

.person-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
  padding: 1rem 0;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.empty-state h2 {
  color: var(--color-text-primary);
  margin-bottom: 0.5rem;
}

.empty-state p {
  color: var(--color-text-secondary);
  margin: 0;
}

/* Responsive grid adjustments */
@media (max-width: 768px) {
  .person-grid {
    grid-template-columns: 1fr;
  }
}

@media (min-width: 769px) and (max-width: 1024px) {
  .person-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1025px) {
  .person-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
