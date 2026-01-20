import { ref, computed, watch } from 'vue'

export function usePagination(items, itemsPerPage = 24) {
  const currentPage = ref(1)
  const pageSize = ref(itemsPerPage)

  const paginatedItems = computed(() => {
    const endIndex = currentPage.value * pageSize.value
    return items.value.slice(0, endIndex)
  })

  const hasMore = computed(() => {
    return paginatedItems.value.length < items.value.length
  })

  const totalPages = computed(() => {
    return Math.ceil(items.value.length / pageSize.value)
  })

  const loadMore = () => {
    if (hasMore.value) {
      currentPage.value++
    }
  }

  const reset = () => {
    currentPage.value = 1
  }

  watch(items, () => {
    reset()
  })

  return {
    paginatedItems,
    hasMore,
    totalPages,
    currentPage,
    loadMore,
    reset
  }
}
