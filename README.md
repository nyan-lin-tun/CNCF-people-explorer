# CNCF People Explorer

A Vue.js frontend that fetches the official CNCF `people.json` dataset and provides a fast, searchable directory of community members.

## 🌟 Live Demo

Visit the live application at: **https://nyan-lin-tun.github.io/CNCF-people-explorer/**

## ✨ Features
- Browse the complete CNCF community directory
- Real-time search across name, company, location, bio, and categories
- Filter by company and location
- Responsive card-based grid layout
- Mobile-first design (optimized for all devices)
- Social media links (LinkedIn, Twitter, GitHub, WeChat)
- Category badges for expertise areas
- Loading and error states
- Frontend-only (no backend required)

## 📦 Data Source
This project uses the public CNCF People API:

```
https://raw.githubusercontent.com/cncf/people/refs/heads/main/people.json
```

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- npm or yarn

### Install & Run

```bash
npm install
npm run dev
```

Open your browser at:
```
http://localhost:5173
```

## 🏗️ Build for Production

```bash
npm run build
```

The production files will be generated in the `dist/` folder.

## 🌐 Deploy to GitHub Pages
This project can be hosted on **GitHub Pages** using a static build and GitHub Actions.

Make sure your Vite config includes the correct base path:

```js
base: "/CNCF-people-explorer/",
```

Then enable **GitHub Pages → Source: GitHub Actions** in your repository settings.

## 🛠️ Tech Stack
- Vue 3
- Vite
- JavaScript
- CNCF People API

## 📄 License
This project is open-source and available under the MIT License.