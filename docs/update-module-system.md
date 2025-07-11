# Update Module System Design

## Overview
A flexible system to add "What's New" modules as Claude Code evolves, allowing users to quickly learn about new features without redoing the entire course.

## Module Structure

### Core Modules (1-8)
- Permanent foundational content
- Version: `core-1.0`
- Never removed, only updated if fundamentally changed

### Update Modules (9+)
- Released periodically for new features
- Version: `update-2024-Q1`, `update-2024-Q2`, etc.
- Shorter, focused content (5-10 min each)
- Optional but highlighted for returning users

## Data Structure

### modules.json Enhancement
```json
{
  "modules": {
    "core": {
      "module_1": {
        "id": "module_1",
        "title": "Introduction to Claude Code",
        "type": "core",
        "version": "1.0",
        "releaseDate": "2024-01-01",
        "estimatedTime": "20 minutes",
        "tags": ["fundamentals", "getting-started"],
        "prerequisities": [],
        "content": {...}
      }
    },
    "updates": {
      "update_2024_q1": {
        "id": "update_2024_q1",
        "title": "What's New in Q1 2024",
        "type": "update",
        "version": "2024.1",
        "releaseDate": "2024-03-15",
        "estimatedTime": "10 minutes",
        "tags": ["updates", "new-features"],
        "features": [
          "New /analyze command",
          "Enhanced MCP integrations",
          "Performance improvements"
        ],
        "content": {...}
      }
    }
  }
}
```

## User Experience Design

### Home Page Enhancements
```vue
<template>
  <div class="container mx-auto px-4 py-8">
    <!-- New Updates Banner -->
    <div v-if="hasNewUpdates" class="bg-blue-50 border-l-4 border-blue-500 p-4 mb-6">
      <div class="flex items-center">
        <span class="text-blue-700 font-semibold">🎉 New Claude Code features available!</span>
        <button @click="viewUpdates" class="ml-auto text-blue-600 hover:text-blue-800">
          View What's New →
        </button>
      </div>
    </div>
    
    <!-- Module Categories -->
    <div class="mb-8">
      <h2 class="text-2xl font-bold mb-4">Core Learning Path</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <ModuleCard v-for="module in coreModules" :key="module.id" :module="module" />
      </div>
    </div>
    
    <div v-if="updateModules.length > 0" class="mb-8">
      <h2 class="text-2xl font-bold mb-4">
        Feature Updates
        <span class="text-sm font-normal text-gray-600 ml-2">
          Stay current with the latest features
        </span>
      </h2>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <UpdateModuleCard 
          v-for="module in updateModules" 
          :key="module.id" 
          :module="module"
          :is-new="isNewModule(module)"
        />
      </div>
    </div>
  </div>
</template>
```

### Update Module Card Component
```vue
<template>
  <div class="relative">
    <!-- New Badge -->
    <div v-if="isNew" class="absolute -top-2 -right-2 z-10">
      <span class="bg-green-500 text-white text-xs px-2 py-1 rounded-full">NEW</span>
    </div>
    
    <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
      <h3 class="text-lg font-semibold mb-2">{{ module.title }}</h3>
      <p class="text-sm text-gray-600 mb-3">{{ module.releaseDate | formatDate }}</p>
      
      <div class="mb-4">
        <h4 class="text-sm font-medium text-gray-700 mb-1">New Features:</h4>
        <ul class="text-sm text-gray-600 space-y-1">
          <li v-for="feature in module.features" :key="feature" class="flex items-start">
            <span class="text-green-500 mr-1">•</span>
            {{ feature }}
          </li>
        </ul>
      </div>
      
      <div class="flex items-center justify-between">
        <span class="text-sm text-gray-500">{{ module.estimatedTime }}</span>
        <router-link 
          :to="`/module/${module.id}`"
          class="text-blue-600 hover:text-blue-800 font-medium"
        >
          Learn More →
        </router-link>
      </div>
    </div>
  </div>
</template>
```

## Smart Notifications System

### localStorage Tracking
```javascript
// composables/useUpdates.js
export function useUpdates() {
  const lastViewedUpdates = useStorage('lastViewedUpdates', {})
  const dismissedBanners = useStorage('dismissedBanners', [])
  
  const checkForNewUpdates = async () => {
    const modules = await fetchModules()
    const updateModules = modules.filter(m => m.type === 'update')
    const lastCheck = lastViewedUpdates.value.lastCheck || '2024-01-01'
    
    return updateModules.filter(m => 
      new Date(m.releaseDate) > new Date(lastCheck)
    )
  }
  
  const markUpdateAsViewed = (moduleId) => {
    lastViewedUpdates.value[moduleId] = new Date().toISOString()
  }
  
  const isNewForUser = (module) => {
    // New if released in last 30 days AND user hasn't viewed it
    const thirtyDaysAgo = new Date()
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
    
    return new Date(module.releaseDate) > thirtyDaysAgo && 
           !lastViewedUpdates.value[module.id]
  }
  
  return {
    checkForNewUpdates,
    markUpdateAsViewed,
    isNewForUser
  }
}
```

## Version Management

### Semantic Versioning for Content
```javascript
// Core modules: major.minor
"version": "1.0"  // Initial release
"version": "1.1"  // Minor updates to content
"version": "2.0"  // Major rewrite

// Update modules: year.quarter
"version": "2024.1"  // Q1 2024
"version": "2024.2"  // Q2 2024
```

### Changelog Integration
```json
{
  "changelog": [
    {
      "version": "2024.1",
      "date": "2024-03-15",
      "changes": [
        "Added /analyze command for codebase analysis",
        "New MCP server for Slack integration",
        "Improved performance for large codebases"
      ]
    }
  ]
}
```

## Content Management Workflow

### 1. Adding New Update Module
```bash
# Create new update module file
/public/data/updates/2024-q2.json

# Update main modules.json to reference it
# Deploy to GitHub Pages
```

### 2. Update Module Template
```json
{
  "id": "update_2024_q2",
  "title": "Q2 2024 Updates: Enhanced Collaboration",
  "type": "update",
  "releaseDate": "2024-06-15",
  "estimatedTime": "8 minutes",
  "features": [
    "Team memory sharing",
    "New /collaborate command",
    "Git worktree improvements"
  ],
  "sections": [
    {
      "title": "Team Memory Sharing",
      "content": "Share CLAUDE.md files across your team...",
      "example": "claude share-memory --team engineering"
    }
  ],
  "quiz": {
    "questions": [
      {
        "question": "How do you share memory files with your team?",
        "options": [...],
        "correct": 0
      }
    ]
  }
}
```

## Progressive Disclosure

### User Skill Level Tracking
```javascript
const userLevel = computed(() => {
  const completed = progress.value.completedModules.length
  if (completed >= 8) return 'advanced'
  if (completed >= 4) return 'intermediate'
  return 'beginner'
})

// Show different update recommendations based on level
const recommendedUpdates = computed(() => {
  if (userLevel.value === 'beginner') {
    return [] // Don't overwhelm beginners
  }
  return updateModules.value.filter(m => 
    m.tags.includes(userLevel.value)
  )
})
```

## RSS/JSON Feed for Updates

### Public Feed Endpoint
```json
// /public/feeds/updates.json
{
  "title": "Claude Code Learning - Feature Updates",
  "updated": "2024-03-15T10:00:00Z",
  "entries": [
    {
      "id": "update_2024_q1",
      "title": "Q1 2024: New Analysis Features",
      "published": "2024-03-15T10:00:00Z",
      "summary": "Learn about the new /analyze command...",
      "link": "https://username.github.io/claude-learn/#/module/update_2024_q1"
    }
  ]
}
```

## Implementation Benefits

1. **Scalable** - Add updates without modifying core code
2. **User-Friendly** - Clear visual indicators for new content
3. **Flexible** - Support different update cadences
4. **Trackable** - Know what users have/haven't seen
5. **Maintainable** - JSON-based content management