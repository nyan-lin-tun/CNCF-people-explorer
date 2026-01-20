<template>
  <div id="app">
    <header class="app-header">
      <div class="container">
        <h1>CNCF People Explorer</h1>
        <p class="subtitle">Explore the Cloud Native Computing Foundation community</p>
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
          Showing {{ filteredPeople.length }} of {{ people.length }} CNCF community members
        </p>

        <PersonList :people="filteredPeople" />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { usePeople } from './composables/usePeople'
import { useSearch } from './composables/useSearch'
import LoadingSpinner from './components/LoadingSpinner.vue'
import ErrorMessage from './components/ErrorMessage.vue'
import PersonList from './components/PersonList.vue'
import SearchBar from './components/SearchBar.vue'
import FilterPanel from './components/FilterPanel.vue'

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

.app-header h1 {
  margin: 0;
  font-size: 2.5rem;
}

.subtitle {
  margin: 0.5rem 0 0 0;
  opacity: 0.95;
  font-size: 1.1rem;
}

.data-count {
  padding: 1rem;
  background-color: var(--color-surface);
  border-left: 4px solid var(--color-primary);
  border-radius: var(--border-radius);
  margin-bottom: 2rem;
}
</style>
