<template>
  <div id="app">
    <header class="app-header">
      <div class="container header-content">
        <div class="header-text">
          <h1>CNCF People Explorer</h1>
          <p class="subtitle">Explore the Cloud Native Computing Foundation community</p>
        </div>
        <ThemeToggle />
      </div>
    </header>

    <main class="container">
      <LoadingSpinner v-if="loading" />
      <ErrorMessage v-else-if="error" :message="error" @retry="fetchPeople" />
      <div v-else-if="people.length > 0">
        <SearchBar v-model="searchQuery" />

        <FilterPanel
          :companies="availableCompanies"
          :locations="availableLocations"
          v-model:selectedCompany="selectedCompany"
          v-model:selectedLocation="selectedLocation"
        />

        <p class="data-count">
          Showing {{ paginatedPeople.length }} of {{ filteredPeople.length }} results
          <span v-if="filteredPeople.length !== people.length">({{ people.length }} total members)</span>
        </p>

        <PersonList :people="paginatedPeople" @personClick="handlePersonClick" />

        <div v-if="hasMore" class="load-more-container">
          <button @click="loadMore" class="load-more-button">
            Load More
          </button>
        </div>
      </div>
    </main>

    <PersonModal
      :isOpen="isModalOpen"
      :person="selectedPerson"
      @close="closeModal"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { usePeople } from './composables/usePeople'
import { useSearch } from './composables/useSearch'
import { usePagination } from './composables/usePagination'
import LoadingSpinner from './components/LoadingSpinner.vue'
import ErrorMessage from './components/ErrorMessage.vue'
import PersonList from './components/PersonList.vue'
import SearchBar from './components/SearchBar.vue'
import FilterPanel from './components/FilterPanel.vue'
import ThemeToggle from './components/ThemeToggle.vue'
import PersonModal from './components/PersonModal.vue'

const { people, loading, error, fetchPeople } = usePeople()

// Search and filter state
const searchQuery = ref('')
const selectedCompany = ref('')
const selectedLocation = ref('')

// Use search composable
const { availableCompanies, availableLocations, filteredPeople } = useSearch(
  people,
  searchQuery,
  selectedCompany,
  selectedLocation
)

// Use pagination composable
const { paginatedItems: paginatedPeople, hasMore, loadMore } = usePagination(filteredPeople, 24)

// Modal state
const isModalOpen = ref(false)
const selectedPerson = ref({})

const handlePersonClick = (person) => {
  selectedPerson.value = person
  isModalOpen.value = true
}

const closeModal = () => {
  isModalOpen.value = false
}

onMounted(() => {
  fetchPeople()
})
</script>

<style scoped>
.app-header {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  color: white;
  padding: 2rem 0;
  margin-bottom: 2rem;
  box-shadow: var(--shadow-md);
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
}

.header-text {
  flex: 1;
}

.app-header h1 {
  margin: 0;
  font-size: 2.5rem;
}

.subtitle {
  margin: 0.5rem 0 0 0;
  opacity: 0.95;
  font-size: 1.1rem;
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: row;
    flex-wrap: wrap;
    align-items: center;
    gap: 1rem;
  }

  .header-text {
    flex: 1 1 auto;
    min-width: 0;
  }

  .app-header h1 {
    font-size: 1.75rem;
    word-wrap: break-word;
  }

  .subtitle {
    font-size: 0.95rem;
  }
}

.data-count {
  padding: 1rem;
  background-color: var(--color-surface);
  border-left: 4px solid var(--color-primary);
  border-radius: var(--border-radius);
  margin-bottom: 2rem;
  word-wrap: break-word;
  font-size: 1rem;
}

.load-more-container {
  display: flex;
  justify-content: center;
  margin: 3rem 0 2rem 0;
}

.load-more-button {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-secondary) 100%);
  color: white;
  border: none;
  padding: 1rem 3rem;
  font-size: 1.1rem;
  font-weight: 600;
  border-radius: var(--border-radius);
  cursor: pointer;
  transition: all var(--transition-speed);
  box-shadow: var(--shadow-sm);
  min-height: 48px;
}

.load-more-button:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.load-more-button:active {
  transform: translateY(0);
  box-shadow: var(--shadow-sm);
}

@media (max-width: 768px) {
  .data-count {
    padding: 0.75rem;
    font-size: 0.9rem;
  }

  .load-more-button {
    width: 100%;
    padding: 1rem 2rem;
  }
}
</style>
