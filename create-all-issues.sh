#!/bin/bash

# GitHub Project 6 - Complete Task List
PROJECT_NUMBER=6

echo "Creating comprehensive issue list for Claude Learn project..."

# ✅ COMPLETED TASKS
echo "Creating completed task issues..."

gh issue create --repo joepetrini/claude-learn --title "✅ Initialize Vue 3 project with Vite and Tailwind" --body "COMPLETED: Set up the development environment with Vue 3, Vite, and Tailwind CSS"

gh issue create --repo joepetrini/claude-learn --title "✅ Create project documentation structure" --body "COMPLETED: Created comprehensive docs including overview, content management guide, update system, etc."

gh issue create --repo joepetrini/claude-learn --title "✅ Design module content structure" --body "COMPLETED: Created 8 core modules with detailed content in JSON format"

gh issue create --repo joepetrini/claude-learn --title "✅ Set up GitHub Actions deployment" --body "COMPLETED: Created workflow for automatic deployment to GitHub Pages"

gh issue create --repo joepetrini/claude-learn --title "✅ Create basic navigation and routing" --body "COMPLETED: Implemented Vue Router with routes for modules, quiz, and results"

gh issue create --repo joepetrini/claude-learn --title "✅ Build home page with module cards" --body "COMPLETED: Created responsive module grid with icons and descriptions"

# 🚧 IN PROGRESS TASKS
echo "Creating in-progress task issues..."

gh issue create --repo joepetrini/claude-learn --title "🚧 Implement Module viewer component" --body "IN PROGRESS: Create component to display module content with sections and navigation
- Display module sections
- Add previous/next navigation
- Show progress indicator
- Add code syntax highlighting"

# 📋 TODO TASKS - Core Features
echo "Creating TODO task issues..."

gh issue create --repo joepetrini/claude-learn --title "📋 Build Quiz Engine Component" --body "TODO: Create interactive quiz component
- Display questions one at a time
- Handle answer selection
- Show explanations after answer
- Calculate and store scores
- Animate transitions between questions"

gh issue create --repo joepetrini/claude-learn --title "📋 Implement Progress Tracking System" --body "TODO: LocalStorage-based progress system
- Create useProgress composable
- Track completed modules
- Store quiz scores with timestamps
- Calculate overall progress percentage
- Show visual progress indicators"

gh issue create --repo joepetrini/claude-learn --title "📋 Create Quiz Questions for All Modules" --body "TODO: Write comprehensive quiz questions
- 5-10 questions per module
- Focus on practical scenarios
- Include detailed explanations
- Cover all key concepts
- Add Django-specific examples"

gh issue create --repo joepetrini/claude-learn --title "📋 Build Results/Dashboard Page" --body "TODO: Create comprehensive results view
- Overall progress summary
- Quiz scores by module
- Time spent learning
- Completion certificates
- Export progress feature"

gh issue create --repo joepetrini/claude-learn --title "📋 Implement Update Detection System" --body "TODO: Check for new content
- Create version.json manifest
- Check for updates on app load
- Show 'New' badges on recent modules
- Display update notifications
- Handle version comparison"

gh issue create --repo joepetrini/claude-learn --title "📋 Add Progress Import/Export Feature" --body "TODO: Cross-browser progress backup
- Generate shareable progress codes
- Import progress from codes
- Validate imported data
- Handle merge conflicts
- Add copy-to-clipboard functionality"

gh issue create --repo joepetrini/claude-learn --title "📋 Create Quick Progress Recovery UI" --body "TODO: Bulk completion features
- 'Mark all complete' button
- Module selection checkboxes
- Quick setup wizard
- Import from URL parameters"

gh issue create --repo joepetrini/claude-learn --title "📋 Add Module 9: Advanced Integrations" --body "TODO: Create advanced module content
- VS Code integration guide
- CI/CD pipeline examples
- GitHub Actions workflows
- Team collaboration features
- Real Django project examples"

# 🎨 UI/UX Enhancements
gh issue create --repo joepetrini/claude-learn --title "🎨 Add Loading States and Animations" --body "TODO: Improve user experience
- Skeleton loaders for content
- Smooth page transitions
- Progress animations
- Success celebrations
- Error state handling"

gh issue create --repo joepetrini/claude-learn --title "🎨 Implement Dark Mode Support" --body "TODO: Add theme toggle
- Dark mode color scheme
- System preference detection
- Smooth theme transitions
- Persist user preference"

gh issue create --repo joepetrini/claude-learn --title "🎨 Create Printable Cheat Sheet" --body "TODO: Quick reference generator
- Compile essential commands
- Format for PDF export
- Add keyboard shortcuts
- Include common workflows
- Make it customizable"

# 🔧 Technical Improvements
gh issue create --repo joepetrini/claude-learn --title "🔧 Add Search Functionality" --body "TODO: Search across all content
- Full-text search in modules
- Command search
- Fuzzy matching
- Search history
- Keyboard shortcuts (Cmd+K)"

gh issue create --repo joepetrini/claude-learn --title "🔧 Implement Keyboard Navigation" --body "TODO: Power user features
- Navigate modules with arrows
- Quiz shortcuts (1-4 for answers)
- Quick jump to modules (Cmd+1-9)
- Vim-style navigation option"

gh issue create --repo joepetrini/claude-learn --title "🔧 Add Analytics Tracking" --body "TODO: Usage insights (privacy-friendly)
- Module completion rates
- Common search terms
- Quiz problem areas
- Time per module
- Anonymous aggregation"

# 📱 Mobile Optimization
gh issue create --repo joepetrini/claude-learn --title "📱 Optimize Mobile Experience" --body "TODO: Enhanced mobile support
- Touch gestures for navigation
- Improved mobile quiz layout
- Responsive code examples
- Mobile-specific shortcuts
- Offline capability with PWA"

# 📚 Content Enhancements
gh issue create --repo joepetrini/claude-learn --title "📚 Add Video Demonstrations" --body "TODO: Visual learning aids
- Record screen captures
- Embed in relevant sections
- Show real Claude Code usage
- Django workflow examples
- Host on GitHub/YouTube"

gh issue create --repo joepetrini/claude-learn --title "📚 Create Interactive Playground" --body "TODO: Practice environment
- Simulated Claude Code interface
- Try commands safely
- Guided exercises
- Instant feedback
- Progress tracking"

# 🚀 Deployment & Distribution
gh issue create --repo joepetrini/claude-learn --title "🚀 Enable GitHub Pages Deployment" --body "TODO: Complete deployment setup
- Enable Pages in settings
- Configure custom domain (optional)
- Set up deployment monitoring
- Add deployment badge to README"

gh issue create --repo joepetrini/claude-learn --title "🚀 Create Comprehensive README" --body "TODO: Project documentation
- Project overview
- Development setup guide
- Contribution guidelines
- Content management instructions
- Deployment guide"

# Now add all issues to Project 6
echo "Adding issues to Project 6..."
ISSUE_NUMBERS=$(gh issue list --repo joepetrini/claude-learn --limit 50 --json number --jq '.[].number')

for issue in $ISSUE_NUMBERS; do
  echo "Adding issue #$issue to project..."
  gh project item-add $PROJECT_NUMBER --owner joepetrini --url https://github.com/joepetrini/claude-learn/issues/$issue
done

echo "Done! All tasks have been added to: https://github.com/users/joepetrini/projects/6"
echo ""
echo "Summary:"
echo "✅ Completed: 6 tasks"
echo "🚧 In Progress: 1 task" 
echo "📋 TODO Core: 9 tasks"
echo "🎨 TODO UI/UX: 3 tasks"
echo "🔧 TODO Technical: 3 tasks"
echo "📱 TODO Mobile: 1 task"
echo "📚 TODO Content: 2 tasks"
echo "🚀 TODO Deployment: 2 tasks"
echo "------------------------"
echo "Total: 27 tasks"