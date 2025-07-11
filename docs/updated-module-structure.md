# Updated Module Structure with Additional Content

## Content Placement Strategy

### Module 2: Core Workflows & Capabilities (EXPANDED)
Add these features to the existing workflow module:

#### New Sections:
1. **Code Review Workflow**
   - Using `/review` command
   - Best practices for AI-assisted code reviews
   - Django/Python specific review patterns

2. **GitHub Integration**
   - `/pr_comments` command usage
   - Viewing and responding to PR feedback
   - Integrating Claude into your PR workflow

3. **Extended Thinking Mode**
   - When to use extended thinking
   - Complex Django architecture decisions
   - Performance optimization problems
   - Database design challenges

### Module 3: Modes and Context Management (EXPANDED)
Add image analysis as a new section:

#### New Section: Image Analysis Mode
- **Taking Screenshots**
  - macOS: `Ctrl+Shift+Cmd+4` for selection
  - Pasting in iTerm2: `Ctrl+V` (not Cmd+V)
  - Windows/Linux alternatives
  
- **Use Cases**
  - Debugging UI issues
  - Analyzing Django template problems
  - Understanding error screenshots
  - Reviewing design mockups
  
- **Diagram Creation**
  - Can Claude create diagrams? (No, but can generate code for diagram tools)
  - Mermaid diagram generation
  - PlantUML for architecture diagrams
  - ASCII diagrams for documentation

### Module 4: History and Slash Commands (EXPANDED)
Add custom commands section:

#### New Section: Custom Slash Commands
- Creating project-specific commands
- Django workflow automation examples:
  ```json
  {
    "commands": {
      "migrate": "python manage.py makemigrations && python manage.py migrate",
      "test-app": "python manage.py test {{app_name}}",
      "deploy": "git push && cap production deploy"
    }
  }
  ```
- Team-wide custom commands

### Module 5: Memory System (CLAUDE.md) (EXPANDED)
Add team collaboration features:

#### New Section: Team Conventions
- Shared CLAUDE.md patterns
- Team-specific coding standards
- Django project conventions:
  ```markdown
  ## Team Conventions
  - Always use class-based views
  - Follow our custom model naming pattern
  - Use our internal auth decorators
  ```
- Version control for team memories

## NEW Module 9: Advanced Integrations

Create a new advanced module for power users:

### Module 9: IDE & CI/CD Integrations
**Learning Objectives:**
- Set up VS Code integration
- Implement CI/CD pipelines with Claude
- Create GitHub Actions workflows
- Advanced team features

#### Sections:

##### 1. VS Code Integration
- Installing Claude Code extension
- Keyboard shortcuts
- Side-by-side coding
- Debugging integration

##### 2. CI/CD Pipeline Integration
- Pre-commit hooks with Claude
- Automated code review in pipelines
- Django-specific CI checks:
  ```yaml
  - name: Claude Security Review
    run: claude /review --scope=security --files="**/*.py"
  ```

##### 3. GitHub Actions Workflows
- Automated PR reviews
- Deploy previews with Claude checks
- Migration safety validation
- Example workflow:
  ```yaml
  name: Claude Code Review
  on: [pull_request]
  jobs:
    review:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v3
        - name: Claude Review
          run: |
            claude /review --format=github
            claude /pr_comments --add-suggestions
  ```

##### 4. Team Collaboration Features
- Leaderboard setup (gamification)
- Shared learning paths
- Team memory synchronization
- Progress tracking across team

## Content Distribution Summary

### Existing Module Updates:
- **Module 2**: +3 sections (review, PR comments, extended thinking)
- **Module 3**: +1 major section (image analysis)
- **Module 4**: +1 section (custom commands)
- **Module 5**: +1 section (team conventions)

### New Module:
- **Module 9**: Advanced Integrations (4 sections)

## Implementation Priority

1. **High Priority** (Core features):
   - `/review` command (Module 2)
   - Image analysis (Module 3)
   - Extended thinking (Module 2)

2. **Medium Priority** (Team features):
   - Custom commands (Module 4)
   - Team conventions (Module 5)
   - `/pr_comments` (Module 2)

3. **Lower Priority** (Advanced):
   - IDE integrations (Module 9)
   - CI/CD workflows (Module 9)
   - Gamification (Module 9)

## Quiz Questions to Add

### Module 2 Additions:
```json
{
  "question": "When should you use extended thinking mode?",
  "options": [
    "For every coding task",
    "For complex architectural decisions",
    "Only for bug fixes",
    "Never, it's too slow"
  ],
  "correct": 1,
  "explanation": "Extended thinking is best for complex problems requiring deep analysis."
}
```

### Module 3 Additions:
```json
{
  "question": "How do you paste a screenshot in iTerm2?",
  "options": [
    "Cmd+V",
    "Ctrl+V",
    "Right-click and paste",
    "Drag and drop only"
  ],
  "correct": 1,
  "explanation": "iTerm2 requires Ctrl+V for pasting images, not the standard Cmd+V."
}
```

### Module 9 Questions:
```json
{
  "question": "What's the benefit of Claude in CI/CD pipelines?",
  "options": [
    "Faster deployments",
    "Automated code review and security checks",
    "Reduced server costs",
    "Automatic bug fixes"
  ],
  "correct": 1,
  "explanation": "Claude can automatically review code and check for security issues in your pipeline."
}
```