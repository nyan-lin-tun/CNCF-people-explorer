import { computed } from 'vue'

export function useSearch(people, searchQuery, selectedCompany, selectedLocation) {
  // Get unique companies from the people data
  const availableCompanies = computed(() => {
    const companies = people.value
      .map(person => person.company)
      .filter(company => company && company.trim() !== '')

    return [...new Set(companies)].sort()
  })

  // Get unique locations from the people data
  const availableLocations = computed(() => {
    const locations = people.value
      .map(person => person.location)
      .filter(location => location && location.trim() !== '')

    return [...new Set(locations)].sort()
  })

  // Filter people based on search query and filters
  const filteredPeople = computed(() => {
    let results = people.value

    // Apply company filter
    if (selectedCompany.value) {
      results = results.filter(person => person.company === selectedCompany.value)
    }

    // Apply location filter
    if (selectedLocation.value) {
      results = results.filter(person => person.location === selectedLocation.value)
    }

    // Apply search query
    if (searchQuery.value && searchQuery.value.trim() !== '') {
      const query = searchQuery.value.toLowerCase().trim()

      results = results.filter(person => {
        // Search in name
        if (person.name && person.name.toLowerCase().includes(query)) {
          return true
        }

        // Search in company
        if (person.company && person.company.toLowerCase().includes(query)) {
          return true
        }

        // Search in location
        if (person.location && person.location.toLowerCase().includes(query)) {
          return true
        }

        // Search in bio (remove HTML tags first)
        if (person.bio) {
          const bioText = person.bio.replace(/<[^>]*>/g, '').toLowerCase()
          if (bioText.includes(query)) {
            return true
          }
        }

        // Search in categories
        if (person.category && Array.isArray(person.category)) {
          if (person.category.some(cat => cat.toLowerCase().includes(query))) {
            return true
          }
        }

        return false
      })
    }

    return results
  })

  return {
    availableCompanies,
    availableLocations,
    filteredPeople
  }
}
