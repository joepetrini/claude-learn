# Content Management Guide

## Overview
This guide explains how to manage, update, and maintain the Claude Code training content. All content is stored as JSON files, making updates simple and version-controlled.

## Content Structure

### Directory Layout
```
public/
├── data/
│   ├── modules.json         # Core module metadata & content
│   ├── quizzes.json        # Quiz questions for all modules
│   ├── version.json        # Version tracking file
│   └── updates/            # Update module files
│       ├── 2024-q1.json
│       ├── 2024-q2.json
│       └── ...
```

## Managing Core Content

### 1. Editing Existing Modules

#### Update Module Content
1. Open `/public/data/modules.json`
2. Find the module to update (e.g., `module_1`)
3. Edit the content sections
4. Commit and push changes

Example structure:
```json
{
  "module_1": {
    "id": "module_1",
    "title": "Introduction to Claude Code",
    "description": "Learn what Claude Code is and how it differs from other AI tools",
    "estimatedTime": "20 minutes",
    "sections": [
      {
        "title": "What is Claude Code?",
        "content": "<p>Claude Code is a CLI tool that...</p>",
        "example": "claude --help"
      }
    ]
  }
}
```

#### Update Quiz Questions
1. Open `/public/data/quizzes.json`
2. Find the corresponding module quiz
3. Add, edit, or remove questions
4. Ensure answer indices are correct

Example:
```json
{
  "module_1": [
    {
      "id": "m1_q1",
      "question": "What makes Claude Code different from GitHub Copilot?",
      "options": [
        "It's a web-based tool only",
        "It's a CLI tool with file system access",
        "It only works with Python",
        "It requires no setup"
      ],
      "correct": 1,
      "explanation": "Claude Code is a CLI tool that can directly interact with your file system."
    }
  ]
}
```

### 2. Content Guidelines

#### Writing Style
- **Concise**: Keep sections under 300 words
- **Practical**: Use Python/Django examples
- **Clear**: Avoid jargon, explain technical terms
- **Action-oriented**: Focus on what users can do

#### HTML in Content
Content supports basic HTML:
```html
<p>Main paragraph text</p>
<h4>Subheading</h4>
<ul>
  <li>Bullet points</li>
</ul>
<pre><code>claude init</code></pre>
<strong>Important text</strong>
```

#### Code Examples
Always include practical examples:
```json
{
  "content": "<p>Initialize a new project with memory files:</p>",
  "example": "cd my-django-project\nclaude /init"
}
```

## Adding Update Modules

### 1. Create Update Module File

Create `/public/data/updates/2024-q2.json`:
```json
{
  "id": "update_2024_q2",
  "title": "Q2 2024: New Collaboration Features",
  "type": "update",
  "releaseDate": "2024-06-15",
  "estimatedTime": "10 minutes",
  "features": [
    "Team memory sharing",
    "Enhanced /review command",
    "New MCP integrations"
  ],
  "sections": [
    {
      "title": "Team Memory Sharing",
      "content": "<p>Share your CLAUDE.md files with your team...</p>",
      "example": "claude share-memory --team backend"
    },
    {
      "title": "Enhanced Code Review",
      "content": "<p>The /review command now supports...</p>",
      "example": "claude /review --scope=security"
    }
  ],
  "quiz": [
    {
      "id": "u2024q2_q1",
      "question": "How do you share memory files with your team?",
      "options": [
        "Use the share-memory command",
        "Copy files manually",
        "Email the files",
        "Use Git only"
      ],
      "correct": 0,
      "explanation": "The share-memory command handles team synchronization."
    }
  ]
}
```

### 2. Update Version Manifest

Edit `/public/data/version.json`:
```json
{
  "version": "2024.2",
  "lastUpdated": "2024-06-15",
  "totalModules": 12,
  "coreModules": 8,
  "updateModules": 4,
  "latestModules": [
    {
      "id": "update_2024_q2",
      "title": "Q2 2024: New Collaboration Features",
      "releaseDate": "2024-06-15"
    }
  ]
}
```

### 3. Update Module Registry

Add reference in `/public/data/modules.json`:
```json
{
  "core": {
    // ... existing core modules
  },
  "updates": {
    "update_2024_q2": {
      "source": "/data/updates/2024-q2.json"
    }
  }
}
```

## Deployment Process

### 1. Local Testing
```bash
# Start development server
npm run dev

# Test your changes:
# - Navigate through updated modules
# - Complete quizzes
# - Verify examples render correctly
# - Check responsive design
```

### 2. Build and Preview
```bash
# Build production version
npm run build

# Preview production build
npm run preview
```

### 3. Deploy to GitHub Pages
```bash
# Commit changes
git add .
git commit -m "Add Q2 2024 update module"

# Push to main branch (triggers auto-deploy)
git push origin main
```

## Content Update Checklist

- [ ] Content is accurate and up-to-date
- [ ] All code examples are tested
- [ ] Quiz questions have correct answer indices
- [ ] HTML is properly formatted (no unclosed tags)
- [ ] Images (if any) are optimized and have alt text
- [ ] Module metadata is complete (title, time, description)
- [ ] Version.json is updated
- [ ] Tested locally before deployment

## Quick Update Scenarios

### Scenario 1: Fix a Typo
1. Edit the typo in `modules.json` or `quizzes.json`
2. Commit with message: "Fix typo in module X"
3. Push to deploy

### Scenario 2: Add New Claude Code Feature
1. Create update module in `/public/data/updates/`
2. Update `version.json`
3. Add to module registry
4. Test locally
5. Deploy

### Scenario 3: Update Existing Module
1. Edit content in `modules.json`
2. Update any affected quiz questions
3. Increment version in module metadata
4. Test and deploy

## Content Versioning

### Module Version Schema
```json
{
  "version": "1.0",    // Major.Minor
  "lastUpdated": "2024-06-15",
  "changelog": [
    {
      "version": "1.1",
      "date": "2024-06-15",
      "changes": ["Updated MCP section", "Added new examples"]
    }
  ]
}
```

## Best Practices

### 1. Always Test Content
- Read through all content changes
- Complete quizzes to verify correctness
- Test on mobile and desktop

### 2. Keep Updates Focused
- One topic per update module
- 5-15 minutes completion time
- 3-5 quiz questions maximum

### 3. Maintain Consistency
- Use same terminology throughout
- Follow established patterns
- Match existing tone and style

### 4. Version Control
- Meaningful commit messages
- Tag major releases
- Document significant changes

## Troubleshooting

### Content Not Updating
1. Clear browser cache
2. Check GitHub Actions deployment status
3. Verify JSON syntax is valid
4. Ensure file paths are correct

### Quiz Not Working
1. Verify answer indices (0-based)
2. Check question ID uniqueness
3. Ensure quiz array exists for module

### Images Not Loading
1. Place images in `/public/images/`
2. Use relative paths: `/images/screenshot.png`
3. Verify image file names (case-sensitive)

## Future Enhancements

Consider implementing:
- Markdown support for easier editing
- CMS integration for non-technical editors
- A/B testing for content effectiveness
- Analytics for popular modules