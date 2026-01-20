<template>
  <div class="filter-panel">
    <div class="filter-group">
      <label for="company-filter" class="filter-label">Company</label>
      <select
        id="company-filter"
        :value="selectedCompany"
        @change="handleCompanyChange"
        class="filter-select"
      >
        <option value="">All Companies</option>
        <option
          v-for="company in companies"
          :key="company"
          :value="company"
        >
          {{ company }}
        </option>
      </select>
    </div>

    <div class="filter-group">
      <label for="location-filter" class="filter-label">Location</label>
      <select
        id="location-filter"
        :value="selectedLocation"
        @change="handleLocationChange"
        class="filter-select"
      >
        <option value="">All Locations</option>
        <option
          v-for="location in locations"
          :key="location"
          :value="location"
        >
          {{ location }}
        </option>
      </select>
    </div>

    <button
      v-if="selectedCompany || selectedLocation"
      @click="clearFilters"
      class="clear-filters-button"
    >
      Clear Filters
    </button>
  </div>
</template>

<script setup>
import { trackFilter } from '../utils/analytics'

defineProps({
  companies: {
    type: Array,
    default: () => []
  },
  locations: {
    type: Array,
    default: () => []
  },
  selectedCompany: {
    type: String,
    default: ''
  },
  selectedLocation: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:selectedCompany', 'update:selectedLocation'])

const handleCompanyChange = (event) => {
  const value = event.target.value
  emit('update:selectedCompany', value)
  if (value) {
    trackFilter('company', value)
  }
}

const handleLocationChange = (event) => {
  const value = event.target.value
  emit('update:selectedLocation', value)
  if (value) {
    trackFilter('location', value)
  }
}

const clearFilters = () => {
  emit('update:selectedCompany', '')
  emit('update:selectedLocation', '')
}
</script>

<style scoped>
.filter-panel {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  padding: 1.5rem;
  background-color: var(--color-background);
  border-radius: var(--border-radius);
  box-shadow: var(--shadow-sm);
  margin-bottom: 1.5rem;
  align-items: flex-end;
}

.filter-group {
  flex: 1;
  min-width: 200px;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-label {
  font-weight: 500;
  color: var(--color-text-primary);
  font-size: 0.95rem;
}

.filter-select {
  padding: 0.75rem;
  font-size: 1rem;
  border: 2px solid var(--color-border);
  border-radius: var(--border-radius);
  background-color: var(--color-background);
  color: var(--color-text-primary);
  cursor: pointer;
  transition: border-color var(--transition-speed);
  min-height: 44px;
}

.filter-select:focus {
  outline: none;
  border-color: var(--color-primary);
}

.clear-filters-button {
  padding: 0.75rem 1.5rem;
  background-color: var(--color-text-secondary);
  color: white;
  border: none;
  border-radius: var(--border-radius);
  font-size: 1rem;
  cursor: pointer;
  transition: background-color var(--transition-speed);
  min-height: 44px;
  white-space: nowrap;
}

.clear-filters-button:hover {
  background-color: var(--color-text-primary);
}

@media (max-width: 768px) {
  .filter-panel {
    flex-direction: column;
  }

  .filter-group {
    min-width: 100%;
  }

  .clear-filters-button {
    width: 100%;
  }
}
</style>
