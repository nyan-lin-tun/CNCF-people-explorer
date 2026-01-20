import { ref } from 'vue'
import { CNCF_PEOPLE_API_URL } from '../utils/api'

export function usePeople() {
  const people = ref([])
  const loading = ref(false)
  const error = ref(null)

  const fetchPeople = async () => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(CNCF_PEOPLE_API_URL)

      if (!response.ok) {
        throw new Error(`Failed to fetch data: ${response.status} ${response.statusText}`)
      }

      const data = await response.json()

      // Deduplicate data based on unique combination of name, company, and location
      const uniquePeople = []
      const seen = new Set()

      data.forEach(person => {
        const key = `${person.name || ''}-${person.company || ''}-${person.location || ''}`
        if (!seen.has(key)) {
          seen.add(key)
          uniquePeople.push(person)
        }
      })

      people.value = uniquePeople
    } catch (err) {
      error.value = err.message || 'An error occurred while fetching data'
      console.error('Error fetching CNCF people:', err)
    } finally {
      loading.value = false
    }
  }

  return {
    people,
    loading,
    error,
    fetchPeople
  }
}
