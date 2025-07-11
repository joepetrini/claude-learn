# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an e-learning application designed to teach team members how to effectively use Claude Code. The app focuses on Python/Django developers and includes interactive modules, quizzes, and practical examples.

## Tech Stack

- **Build Tool**: Vite for fast development and optimized builds
- **Framework**: Vue 3 with Composition API
- **Styling**: Tailwind CSS via PostCSS
- **Routing**: Vue Router for navigation
- **Data Storage**: Browser localStorage for progress tracking
- **Content**: Static JSON files for modules and quizzes
- **Hosting**: Static site hosting (GitHub Pages, Netlify, etc.)

## Project Structure

```
claude-learn/
├── index.html              # Main entry point
├── package.json            # Dependencies
├── vite.config.js          # Vite configuration
├── tailwind.config.js      # Tailwind configuration
├── src/
│   ├── main.js            # Vue app initialization
│   ├── App.vue            # Root component
│   ├── router/            # Vue Router setup
│   ├── components/        # Reusable Vue components
│   │   ├── ModuleCard.vue
│   │   ├── QuizQuestion.vue
│   │   ├── ProgressBar.vue
│   │   └── Navigation.vue
│   ├── views/             # Page components
│   │   ├── Home.vue
│   │   ├── Module.vue
│   │   ├── Quiz.vue
│   │   └── Results.vue
│   ├── composables/       # Reusable composition functions
│   │   ├── useStorage.js
│   │   ├── useQuiz.js
│   │   └── useProgress.js
│   └── assets/
│       └── styles/        # Global styles
├── public/
│   ├── data/
│   │   ├── modules.json   # Module content
│   │   └── quizzes.json   # Quiz questions
│   └── images/            # Static images
├── docs/                  # Project documentation
│   ├── overview.md        # Detailed project specification
│   └── github-pages-deployment.md
└── CLAUDE.md             # This file
```

## Development Commands

```bash
npm install                # Install dependencies
npm run dev               # Start development server
npm run build             # Build for production
npm run preview           # Preview production build
npm run deploy            # Deploy to GitHub Pages
```

## Deployment

This app is designed to be hosted on GitHub Pages. See `docs/github-pages-deployment.md` for detailed deployment instructions. The site will be available at:
- `https://YOUR_USERNAME.github.io/claude-learn/`

## Key Features to Implement

1. **Learning Modules** - 8 interactive modules covering Claude Code features
2. **Quiz System** - Multiple choice quizzes with score tracking
3. **Progress Tracking** - User progress persistence
4. **Interactive Examples** - Python/Django specific code examples
5. **Cheat Sheet** - Quick reference for commands and features

## Development Guidelines

- Follow React best practices with functional components and hooks
- Use TypeScript for type safety
- Implement responsive design with Tailwind CSS
- Keep modules self-contained and easy to update
- Include comprehensive error handling
- Write tests for critical functionality

## Module Content

When working on module content:
- Focus on practical, Python/Django-specific examples
- Keep explanations concise and actionable
- Include real-world scenarios team members will encounter
- Ensure quiz questions test understanding, not memorization