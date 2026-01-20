// API URL configuration based on build mode
// VITE_API_URL can be set at build time for different variants
const DEFAULT_CNCF_URL = 'https://raw.githubusercontent.com/cncf/people/refs/heads/main/people.json'

export const CNCF_PEOPLE_API_URL = import.meta.env.VITE_API_URL || DEFAULT_CNCF_URL
