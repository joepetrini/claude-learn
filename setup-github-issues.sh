#!/bin/bash

# GitHub Project Setup Script for lampscom/claude-learn
# Run this after installing GitHub CLI: brew install gh

echo "Setting up GitHub issues for Claude Learn project..."

# Create GitHub Project (if not already created)
echo "Creating GitHub project..."
gh project create --owner lampscom --title "Claude Learn Development" --body "E-learning app for Claude Code training"

# Note: You'll need to get the project number from the output and set it here
# PROJECT_NUMBER=1  # Replace with actual project number

# Create all development issues
echo "Creating development issues..."

# Setup and Infrastructure
gh issue create --repo lampscom/claude-learn --title "Set up Vue 3 project with Vite" --body "Initialize the Vue application with Tailwind CSS
- Create Vue 3 project structure
- Configure Vite build tool
- Set up Tailwind CSS with PostCSS
- Configure base routing" --label "setup,priority:high"

gh issue create --repo lampscom/claude-learn --title "Set up GitHub Actions deployment" --body "Automated deployment to GitHub Pages
- Create deployment workflow
- Configure Vite for GitHub Pages base path
- Set up build process
- Enable GitHub Pages in settings" --label "devops,priority:high"

# Core Features
gh issue create --repo lampscom/claude-learn --title "Create module navigation system" --body "Build Vue Router setup and module listing page
- Set up Vue Router with routes for each module
- Create home page with module cards
- Implement navigation component
- Add progress indicators" --label "feature,priority:high"

gh issue create --repo lampscom/claude-learn --title "Implement quiz engine" --body "Create quiz component with localStorage scoring
- Build QuizQuestion.vue component
- Handle answer selection and validation
- Calculate and store scores
- Show explanations after answers" --label "feature,priority:high"

gh issue create --repo lampscom/claude-learn --title "Design and implement progress tracking" --body "LocalStorage-based progress system with visual indicators
- Create useProgress composable
- Track completed modules
- Store quiz scores
- Implement progress visualization" --label "feature,priority:high"

gh issue create --repo lampscom/claude-learn --title "Implement update detection system" --body "Version checking and new content notifications
- Create version.json manifest
- Check for updates on load
- Show 'New' badges on recent modules
- Display update banner" --label "feature,priority:medium"

gh issue create --repo lampscom/claude-learn --title "Build progress export/import feature" --body "Backup codes for cross-browser progress
- Generate shareable progress codes
- Import progress from codes
- Add UI for backup/restore
- Handle validation errors" --label "feature,priority:medium"

gh issue create --repo lampscom/claude-learn --title "Implement quick progress recovery" --body "Bulk complete and module selection features
- 'Mark all complete' option
- Checkbox selection UI
- Save selected progress
- Add to settings page" --label "feature,priority:medium"

# Content Creation
gh issue create --repo lampscom/claude-learn --title "Create Module 1-4 content" --body "Write core module content in JSON format
- Module 1: Introduction to Claude Code
- Module 2: Core Workflows & Capabilities
- Module 3: Modes and Context Management
- Module 4: History and Slash Commands" --label "content,priority:high"

gh issue create --repo lampscom/claude-learn --title "Create Module 5-8 content" --body "Write advanced module content
- Module 5: Memory System (CLAUDE.md)
- Module 6: Claude Hooks
- Module 7: MCP Tools Integration
- Module 8: Advanced Features & Tips" --label "content,priority:high"

gh issue create --repo lampscom/claude-learn --title "Add Module 9: Advanced Integrations" --body "Create advanced module for IDE and CI/CD content
- VS Code integration
- CI/CD pipeline setup
- GitHub Actions workflows
- Team collaboration features" --label "content,priority:medium"

gh issue create --repo lampscom/claude-learn --title "Add quiz questions for all modules" --body "Create comprehensive quiz questions
- 5-10 questions per module
- Multiple choice format
- Include explanations
- Focus on practical scenarios" --label "content,priority:high"

gh issue create --repo lampscom/claude-learn --title "Add image analysis content with examples" --body "Screenshot instructions and use cases
- macOS screenshot commands
- iTerm2 paste instructions (Ctrl+V)
- UI debugging examples
- Diagram generation info" --label "content,priority:medium"

# UI/UX
gh issue create --repo lampscom/claude-learn --title "Create responsive UI with Tailwind" --body "Ensure mobile-friendly design throughout
- Responsive navigation
- Mobile-optimized quiz interface
- Touch-friendly buttons
- Readable typography on all devices" --label "ui,priority:high"

gh issue create --repo lampscom/claude-learn --title "Create printable cheat sheet" --body "Quick reference PDF generation
- Compile key commands
- Format for printing
- Add download button
- Include keyboard shortcuts" --label "feature,priority:low"

# Documentation
gh issue create --repo lampscom/claude-learn --title "Write project documentation" --body "README and contribution guidelines
- Project overview in README
- Development setup instructions
- Contribution guidelines
- Content management guide" --label "docs,priority:medium"

echo "Issues created! Now adding them to the project..."

# Get the project number and uncomment these lines
# gh issue list --repo lampscom/claude-learn --limit 20 --json number --jq '.[].number' | while read issue; do
#   gh project item-add $PROJECT_NUMBER --owner lampscom --url https://github.com/lampscom/claude-learn/issues/$issue
# done

echo "Done! Check your GitHub project at: https://github.com/orgs/lampscom/projects"