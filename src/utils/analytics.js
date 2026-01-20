// Google Analytics helper functions

export function trackSearch(query) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'search', {
      search_term: query
    })
  }
}

export function trackFilter(filterType, filterValue) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'filter_used', {
      filter_type: filterType,
      filter_value: filterValue
    })
  }
}

export function trackSocialLinkClick(platform, personName) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'social_link_click', {
      platform: platform,
      person: personName
    })
  }
}

export function trackPageView(pageName) {
  if (typeof gtag !== 'undefined') {
    gtag('event', 'page_view', {
      page_title: pageName
    })
  }
}
