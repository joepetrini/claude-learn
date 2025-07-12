# Content Structure Guide

This document describes how content is organized in the Claude Learn platform with the new category/course/module structure.

## Directory Structure

Content is organized in a hierarchical folder structure with three levels:

```
public/data/
├── categories.json              # Master list of all categories with metadata
├── software-dev/                # Category folder
│   ├── courses.json            # List of courses in this category
│   ├── claude-code-training/   # Course folder
│   │   ├── course.json         # Course metadata
│   │   ├── modules.json        # List of modules in this course
│   │   ├── getting-started/    # Module folder
│   │   │   ├── content.json    # Module content (sections)
│   │   │   └── quiz.json       # Module quiz
│   │   ├── basic-commands/
│   │   │   ├── content.json
│   │   │   └── quiz.json
│   │   └── ...
│   ├── git-fundamentals/       # Another course
│   │   ├── course.json
│   │   ├── modules.json
│   │   └── ...
│   └── ...
├── hr-onboarding/
│   ├── courses.json
│   ├── new-employee-orientation/
│   │   ├── course.json
│   │   ├── modules.json
│   │   ├── company-culture/
│   │   │   ├── content.json
│   │   │   └── quiz.json
│   │   └── ...
│   └── ...
└── customer-support/
    └── ...
```

## File Formats

### categories.json (Root Level)
Lists all available categories and their metadata:

```json
{
  "categories": [
    {
      "slug": "claude-code",
      "name": "Claude Code Training",
      "description": "Master Claude Code for efficient development",
      "icon": "🤖",
      "color": "#3B82F6",
      "sortOrder": 1,
      "isActive": true
    },
    {
      "slug": "hr-onboarding",
      "name": "HR Onboarding",
      "description": "New employee orientation and training",
      "icon": "👥",
      "color": "#10B981",
      "sortOrder": 2,
      "isActive": true
    }
  ]
}
```

### courses.json (Category Level)
Lists all courses within a category:

```json
{
  "courses": [
    {
      "slug": "claude-code-training",
      "title": "Claude Code Training",
      "description": "Master Claude Code for efficient development",
      "icon": "🤖",
      "estimatedDuration": "4 hours",
      "moduleCount": 9,
      "difficultyLevel": "beginner",
      "sortOrder": 1,
      "isActive": true,
      "isFeatured": true,
      "tags": ["ai", "productivity", "development"]
    },
    {
      "slug": "git-fundamentals",
      "title": "Git Fundamentals",
      "description": "Version control basics for developers",
      "icon": "🌿",
      "estimatedDuration": "2 hours",
      "moduleCount": 5,
      "difficultyLevel": "beginner",
      "sortOrder": 2,
      "isActive": true,
      "tags": ["git", "version-control", "collaboration"]
    }
  ]
}
```

### course.json (Course Level)
Course-specific metadata and configuration:

```json
{
  "slug": "claude-code-training",
  "title": "Claude Code Training",
  "description": "Master Claude Code for efficient development",
  "icon": "🤖",
  "metadata": {
    "author": "Engineering Team",
    "targetAudience": "developers",
    "prerequisites": [],
    "learningOutcomes": [
      "Understand Claude Code capabilities",
      "Write effective prompts",
      "Debug and refactor with AI assistance"
    ],
    "lastUpdated": "2025-01-12",
    "version": "2.0"
  },
  "settings": {
    "requiresSequentialCompletion": false,
    "showPrerequisites": true,
    "certificateEnabled": true,
    "passingScore": 80
  }
}
```

### modules.json (Course Level)
Lists all modules within a course:

```json
{
  "modules": [
    {
      "slug": "getting-started",
      "title": "Getting Started with Claude Code",
      "description": "Set up and basic navigation",
      "icon": "🚀",
      "estimatedTime": "20 mins",
      "difficultyLevel": "beginner",
      "sortOrder": 1,
      "isActive": true,
      "isNew": true,
      "newUntil": "2025-02-01",
      "prerequisites": [],
      "tags": ["setup", "basics", "introduction"]
    },
    {
      "slug": "basic-commands",
      "title": "Essential Commands and Shortcuts",
      "description": "Master the most important commands",
      "icon": "⌨️",
      "estimatedTime": "30 mins",
      "difficultyLevel": "beginner",
      "sortOrder": 2,
      "isActive": true,
      "prerequisites": ["getting-started"],
      "tags": ["commands", "shortcuts", "productivity"]
    }
  ]
}
```

### content.json (Module Level)
Contains the actual learning content:

```json
{
  "module": {
    "slug": "getting-started",
    "title": "Getting Started with Claude Code",
    "version": "1.0",
    "lastUpdated": "2025-01-12",
    "sections": [
      {
        "title": "What is Claude Code?",
        "content": "<p>Claude Code is an AI-powered coding assistant...</p>",
        "estimatedTime": "5 mins",
        "example": "// Example code here",
        "tips": [
          "Always review generated code",
          "Use clear, specific prompts"
        ]
      },
      {
        "title": "Installation and Setup",
        "content": "<p>Follow these steps to install Claude Code...</p>",
        "estimatedTime": "10 mins",
        "example": "npm install -g claude-code",
        "resources": [
          {
            "type": "video",
            "title": "Installation Walkthrough",
            "url": "/videos/install-guide.mp4"
          }
        ]
      }
    ]
  }
}
```

### quiz.json (Module Level)
Quiz questions for the module:

```json
{
  "quiz": {
    "passingScore": 80,
    "questions": [
      {
        "question": "What is the primary purpose of Claude Code?",
        "options": [
          "To replace human developers",
          "To assist with coding tasks",
          "To debug production servers",
          "To manage databases"
        ],
        "correctAnswer": 1,
        "explanation": "Claude Code is designed to assist developers..."
      }
    ]
  }
}
```

## Content Management Workflow

### 1. Adding a New Category
1. Create a new folder under `public/data/` with the category slug
2. Add the category to `public/data/categories.json`
3. Create `category.json` and `modules.json` in the category folder
4. Run admin sync to update the database

### 2. Adding a New Module
1. Create a new folder under the category with the module slug
2. Add the module to the category's `modules.json`
3. Create `content.json` and `quiz.json` in the module folder
4. Run admin sync to update the database

### 3. Updating Content
1. Edit the appropriate JSON file
2. Increment the version number
3. Update the lastUpdated timestamp
4. Commit changes to git for version control
5. Run admin sync to update the database

## Admin Sync Process

The admin dashboard provides tools to sync JSON content to the database:

### Full Sync
- Scans all categories and modules
- Updates database to match JSON files
- Reports added/modified/removed items
- Creates sync history record

### Category Sync
- Syncs a specific category and its modules
- Useful for targeted updates
- Faster than full sync

### Module Sync
- Syncs a single module
- Ideal for quick content updates
- Minimal impact on other content

## Best Practices

### 1. File Organization
- Keep module names clear and URL-friendly
- Use consistent naming conventions
- Group related modules in the same category

### 2. Content Updates
- Always update version numbers when changing content
- Keep git commits atomic (one logical change per commit)
- Write clear commit messages for content changes

### 3. Module Dependencies
- Use prerequisites to enforce learning paths
- Keep prerequisite chains reasonable (max 2-3 deep)
- Test navigation flow after adding prerequisites

### 4. Performance
- Keep individual JSON files under 100KB
- Use separate files for large resources (videos, images)
- Consider pagination for categories with many modules

## Migration Guide

### From v1 (Single File) to v2 (Category Structure)

1. **Backup Current Content**
   ```bash
   cp public/data/modules.json public/data/modules-v1-backup.json
   cp public/data/quizzes.json public/data/quizzes-v1-backup.json
   ```

2. **Run Migration Script**
   ```bash
   npm run migrate-content
   ```
   This will:
   - Create category folders
   - Split modules into appropriate categories
   - Generate category.json and modules.json files
   - Preserve all existing content

3. **Verify Structure**
   - Check folder organization
   - Validate JSON files
   - Test loading in development

4. **Update Database**
   - Run the new schema SQL
   - Execute admin sync
   - Verify data integrity

## Content Versioning

### Version Control Benefits
- Track all content changes in git
- Easy rollback to previous versions
- Collaborate on content with PR reviews
- Blame/history for debugging issues

### Version Naming
- Use semantic versioning for modules (1.0, 1.1, 2.0)
- Increment minor version for content updates
- Increment major version for structural changes

### Change Tracking
- Database tracks `content_version` and `last_synced_at`
- Sync history shows what changed and when
- Notifications can reference version changes