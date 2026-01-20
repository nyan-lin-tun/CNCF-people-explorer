

# CNCF People Explorer – Project Planning

## 1. Project Overview
CNCF People Explorer is a frontend-only Vue.js web application that consumes the official CNCF `people.json` dataset and displays a searchable directory of CNCF community members.

Data Source:
https://raw.githubusercontent.com/cncf/people/refs/heads/main/people.json

The app is designed to be lightweight, fast, and easy to deploy as a static site (e.g., on GitHub Pages).

---

## 2. Goals
- Build a simple and clean people directory UI
- Support fast client-side search (name, company, location, etc.)
- No backend or database required
- Easy deployment to GitHub Pages
- Suitable as a portfolio / demo project

---

## 3. Tech Stack
- Vue 3
- Vite
- JavaScript
- GitHub Pages (hosting)
- CNCF People API

---

## 4. Core Features
- Fetch CNCF `people.json` from GitHub
- Display people in a list or card layout
- Show basic info:
  - Name
  - Company
  - Location
  - Bio (optional / truncated)
  - Social links (LinkedIn, Twitter, GitHub, etc.)
- Search / filter by:
  - Name
  - Company
  - Location
- Responsive design (desktop + mobile)

---

## 5. Architecture
- Frontend-only SPA (Single Page Application)
- No backend API
- Data fetched directly from GitHub raw URL
- All filtering and searching done in the browser

Flow:
User Browser → GitHub Raw JSON → Vue App → UI

---

## 6. Deployment Plan
- Use Vite build output (`dist/`)
- Configure base path:
  ```js
  base: "/CNCF-people-explorer/",
  ```
- Deploy using GitHub Actions
- Enable GitHub Pages (Source: GitHub Actions)

---

## 7. Routing Strategy
- Prefer simple single-page layout
- If Vue Router is used, use hash mode to avoid GitHub Pages 404 issues

---

## 8. Optional Enhancements (Future)
- Category filters (Kubestronaut, Ambassador, etc.)
- Country / region filter
- Project / expertise tags
- Profile detail modal
- Dark mode
- Sorting (A–Z)
- Lazy loading / pagination

---

## 9. Non-Goals
- No backend service
- No database
- No authentication
- No write/edit features

---

## 10. Success Criteria
- App loads CNCF people data successfully
- Search works smoothly
- Deployed on GitHub Pages
- Clean UI suitable for portfolio

---

## 11. Notes
- This project is meant to stay simple and focused
- Main value: frontend, API consumption, clean UI, and deployment
- Can later be extended for DevOps demos (Docker, CI/CD, etc.)