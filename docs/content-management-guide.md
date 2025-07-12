# Content Management Guide

## Overview
This guide explains how to manage, update, and maintain the Claude Code training content. The system handles two scenarios:
1. **Updates to existing features** - Direct edits to original modules
2. **Brand new features** - Monthly update modules that users can complete separately

## Content Structure

### Directory Layout
```
public/
├── data/
│   ├── modules.json        # All module metadata & content
│   ├── quizzes.json        # Quiz questions for all modules
│   └── version.json        # Version tracking & changelog
```

### Module Types

#### Core Modules (Permanent)
- IDs: `getting-started`, `core-workflows`, etc.
- Foundational content that rarely changes fundamentally
- Updated in-place when features change

#### Update Modules (Periodic)
- IDs: `updates-2025-01`, `updates-2025-02`, etc.
- Monthly releases for new features
- Shorter focused content (5-10 minutes)
- Allows completed users to stay current

## JSON File Structures

### modules.json
```json
{
  "modules": [
    {
      "id": "getting-started",
      "title": "Getting Started with Claude Code",
      "icon": "🚀",
      "description": "Learn the basics of Claude Code",
      "estimatedTime": "20 minutes",
      "lastUpdated": "2025-01-12",
      "version": "1.2",
      "sections": [
        {
          "title": "What is Claude Code?",
          "content": "<p>Claude Code is a powerful AI coding assistant...</p>",
          "example": "claude --help",
          "lastUpdated": "2025-01-12"
        }
      ]
    },
    {
      "id": "updates-2025-01",
      "title": "January 2025 Updates",
      "icon": "🆕",
      "type": "update",
      "releaseDate": "2025-01-15",
      "description": "New features in Claude Code 1.5",
      "estimatedTime": "10 minutes",
      "features": [
        "New MCP Tools",
        "Enhanced /review command",
        "Performance improvements"
      ],
      "sections": [
        {
          "title": "MCP Tool Integration",
          "content": "<p>Connect external tools...</p>",
          "example": "claude --mcp puppeteer",
          "relatedModule": "advanced-features"
        }
      ]
    }
  ]
}
```

### quizzes.json
```json
{
  "quizzes": {
    "getting-started": {
      "title": "Getting Started Quiz",
      "questions": [
        {
          "question": "What is Claude Code?",
          "options": [
            "A web-based IDE",
            "A CLI-based AI coding assistant",
            "A code formatter",
            "A testing framework"
          ],
          "correct": 1,
          "explanation": "Claude Code is a CLI tool that provides AI assistance."
        }
      ]
    },
    "updates-2025-01": {
      "title": "January 2025 Updates Quiz",
      "questions": [
        {
          "question": "Which MCP tool allows browser automation?",
          "options": ["puppeteer", "filesystem", "slack", "github"],
          "correct": 0,
          "explanation": "The puppeteer MCP tool enables browser automation."
        }
      ]
    }
  }
}
```

### version.json
```json
{
  "contentVersion": "2.1.0",
  "claudeCodeVersion": "1.5.0",
  "lastUpdated": "2025-01-12",
  "moduleUpdates": {
    "getting-started": {
      "version": "1.2",
      "lastUpdated": "2025-01-12",
      "changes": ["Updated installation steps for v1.5"]
    },
    "core-workflows": {
      "version": "1.1",
      "lastUpdated": "2025-01-10",
      "changes": ["Added extended thinking mode section"]
    }
  },
  "monthlyUpdates": [
    {
      "id": "updates-2025-01",
      "month": "January 2025",
      "features": ["MCP Tools", "Enhanced /review command"],
      "claudeCodeVersion": "1.5.0"
    }
  ]
}
```

## Content Update Workflows

### Scenario 1: Updating Existing Content
When Claude Code changes existing functionality (e.g., parameter changes, new options):

1. **Edit the original module** in `modules.json`
2. **Update the section's content**
3. **Increment the module version** (e.g., 1.1 → 1.2)
4. **Update `lastUpdated` timestamp**
5. **Update version.json** with change description
6. **Test locally** before deploying

Example:
```bash
# Claude Code adds a new parameter to the `claude init` command
# Edit modules.json → getting-started module → installation section
# Update the example and explanation
# Change version from "1.1" to "1.2"
# Update lastUpdated to today's date
```

### Scenario 2: Adding New Features
When Claude Code adds entirely new capabilities:

1. **Check if it fits existing modules**
   - Small feature → Add as new section to relevant module
   - Large feature → Create monthly update module

2. **For monthly update modules**:
   ```json
   {
     "id": "updates-2025-02",
     "title": "February 2025 Updates",
     "icon": "🆕",
     "type": "update",
     "releaseDate": "2025-02-01",
     "description": "WebSearch, new slash commands, and more",
     "estimatedTime": "12 minutes",
     "features": [
       "WebSearch capability",
       "/compact command",
       "Improved error handling"
     ],
     "sections": [
       {
         "title": "WebSearch Integration",
         "content": "<p>Claude can now search the web...</p>",
         "example": "How do I implement OAuth in Django?",
         "relatedModule": "core-workflows"
       }
     ]
   }
   ```

3. **Update version.json**
4. **Create quiz questions**
5. **Deploy**

## Content Guidelines

### Writing Style
- **Concise**: Keep sections under 300 words
- **Practical**: Use Python/Django examples
- **Clear**: Avoid jargon, explain technical terms
- **Action-oriented**: Focus on what users can do

### HTML Content Format
```html
<p>Main paragraph text</p>
<h4>Subheading</h4>
<ul>
  <li>Bullet points</li>
  <li>More points</li>
</ul>
<pre><code>claude /review --scope=security</code></pre>
<strong>Important:</strong> Always review before committing
```

### Code Examples
- Always include practical, runnable examples
- Use Python/Django contexts when possible
- Show both command and expected output
- Keep examples concise but complete

## Development Commands

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run linting
npm run lint

# Deploy to GitHub Pages
npm run deploy
```

## Testing Checklist

Before deploying any content updates:

- [ ] All JSON files are valid (no syntax errors)
- [ ] Module IDs are unique
- [ ] Quiz answer indices are correct (0-based)
- [ ] All HTML tags are properly closed
- [ ] Examples are tested and working
- [ ] Version numbers are incremented
- [ ] Timestamps are updated
- [ ] Content displays correctly on mobile
- [ ] Navigation between sections works
- [ ] Quiz scoring is accurate

## Version Management

### Core Module Versioning
- Format: `major.minor` (e.g., "1.0", "1.1", "2.0")
- Minor: Content updates, clarifications
- Major: Complete rewrites or structural changes

### Update Module Versioning
- Use date-based IDs: `updates-YYYY-MM`
- Track Claude Code version covered
- List all features included

### Progress Tracking Integration
The app tracks:
- Module completion by version
- When users last saw updates
- Which update modules are "new" to each user

## Quick Reference

### Add a typo fix
1. Edit content in `modules.json`
2. Commit and push (no version change needed)

### Update existing feature
1. Edit module section in `modules.json`
2. Increment module version
3. Update `lastUpdated`
4. Update `version.json`
5. Test and deploy

### Add new Claude Code feature
1. Determine if it's an update or new content
2. Either:
   - Add section to existing module, OR
   - Add to current month's update module
3. Update version tracking
4. Create quiz questions
5. Test and deploy

### Create monthly update
1. Add new module with `type: "update"`
2. Use ID format: `updates-YYYY-MM`
3. List all new features
4. Add to `version.json`
5. Deploy at month's end

## Future Enhancements

Planned improvements:
- Markdown support for easier editing
- Automated update detection from Claude Code releases
- A/B testing for content effectiveness
- Analytics for popular modules
- Content contribution guidelines for team members