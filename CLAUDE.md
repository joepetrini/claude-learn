# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a multi-department e-learning platform designed to deliver training content across various teams. Initially focused on Claude Code training for developers, it now supports categories for HR onboarding, software development, customer support, and more. The platform includes interactive modules, quizzes, progress tracking, and admin tools.

## Tech Stack

- **Build Tool**: Vite for fast development and optimized builds
- **Framework**: Vue 3 with Composition API
- **Styling**: Tailwind CSS via PostCSS
- **Routing**: Vue Router for navigation
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Data Storage**: Supabase database with real-time sync
- **Content**: Organized JSON files by category/module
- **Authentication**: Google OAuth via Supabase
- **Hosting**: Static site hosting (GitHub Pages)

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
│   ├── lib/               # External libraries (Supabase client)
│   ├── components/        # Reusable Vue components
│   │   ├── Navigation.vue
│   │   ├── ModuleCard.vue
│   │   ├── QuizQuestion.vue
│   │   ├── LoadingSkeletons.vue
│   │   └── NotificationCenter.vue
│   ├── views/             # Page components
│   │   ├── Home.vue       # Category listing
│   │   ├── Login.vue      # OAuth login
│   │   ├── Module.vue     # Module content
│   │   ├── Quiz.vue       # Quiz interface
│   │   ├── Profile.vue    # User profile
│   │   └── admin/         # Admin pages
│   ├── composables/       # Reusable composition functions
│   │   ├── useAuth.js
│   │   ├── useSupabaseProgress.js
│   │   ├── useAdmin.js
│   │   └── useProfile.js
│   └── assets/
│       └── styles/        # Global styles
├── public/
│   └── data/              # Content organization (future)
│       ├── categories.json
│       ├── claude-code/   # Category folder
│       │   ├── category.json
│       │   ├── modules.json
│       │   └── [modules]/
│       └── [other-categories]/
├── docs/                  # Project documentation
│   ├── database-schema.sql
│   ├── content-structure.md
│   ├── category-migration-plan.md
│   ├── deployment-guide.md
│   └── security-audit.md
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

## Key Features

### Implemented ✅
1. **Category System** - Organize content by department (Claude Code, HR, Dev, Support)
2. **Learning Modules** - Interactive modules with sections and examples
3. **Quiz System** - Multiple choice quizzes with score tracking
4. **Progress Tracking** - Database-backed progress persistence
5. **User Authentication** - Google OAuth with profile management
6. **Admin Dashboard** - User management and analytics
7. **Favorites System** - Users can favorite categories for quick access

### In Development 🚧
1. **Content Sync** - Admin tool to sync JSON content to database
2. **New Module Notifications** - Alert users to new content in favorites
3. **Category Navigation** - Browse modules by category
4. **Migration Tools** - Move from single-file to category structure

## Development Guidelines

- Follow Vue 3 Composition API best practices
- Use Supabase for all data persistence
- Implement responsive design with Tailwind CSS
- Keep content in version-controlled JSON files
- Database serves runtime queries, not content storage
- Include comprehensive error handling
- Maintain backward compatibility during migrations
- **Always create a feature branch when starting work on a new issue**

## GitHub Project Management

We use GitHub Projects (Project #6: Claude Learn Project) to track and manage development tasks. The project board has the following columns:

### Status Columns

1. **No Status** - Issues that haven't been triaged or categorized yet
   - When: New issues are created
   - Next: Move to Todo when ready to be worked on

2. **Todo** - Issues that are ready to be worked on
   - When: Issue is defined and ready for implementation
   - Next: Move to In Progress when work begins
   - **Important**: When moving an issue to Todo, position it at the top of the list

3. **In Progress** - Issues currently being worked on
   - When: Active development has started
   - Next: Move to Done when completed and merged
   - **Important**: When moving an issue to In Progress, position it at the top of the list

4. **Done** - Completed issues
   - When: Work is complete, PR is merged, and issue is closed
   - Ordered by: Most recently completed at the top
   - **Important**: When moving an issue to Done, position it at the top of the list

### Workflow

1. Create issue with clear title and description
2. Add to project and set status to Todo (position at top)
3. When starting work, move to In Progress (position at top)
4. Create feature branch and implement solution
5. Submit PR and merge
6. Close issue and move to Done (position at top)

### CLI Commands

```bash
# View project issues
gh project item-list 6 --owner joepetrini

# Create and add issue to project
gh issue create --title "Title" --body "Description" --project 6

# Move issue between columns using GraphQL API
# First, get the project and field IDs:
gh api graphql -f query='
{
  user(login: "joepetrini") {
    projectV2(number: 6) {
      id
      field(name: "Status") {
        ... on ProjectV2SingleSelectField {
          id
          options {
            id
            name
          }
        }
      }
    }
  }
}'

# Find the issue's project item ID:
gh project item-list 6 --owner joepetrini --format json | jq '.items[] | select(.content.number == ISSUE_NUMBER)'

# Move issue to different status (example: move to Todo):
gh api graphql -X POST -f query='
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwHOAC8Mps4A9r7G"
    itemId: "ITEM_ID_FROM_ABOVE"
    fieldId: "PVTSSF_lAHOAC8Mps4A9r7GzgxULn8"
    value: { singleSelectOptionId: "f75ad846" }  # Todo status
  }) {
    projectV2Item {
      id
    }
  }
}'

# Status option IDs for this project:
# - Todo: "f75ad846"
# - In Progress: "47fc9ee4"
# - Done: "98236657"

# Move item to top of column:
gh api graphql -X POST -f query='
mutation {
  updateProjectV2ItemPosition(input: {
    projectId: "PVT_kwHOAC8Mps4A9r7G"
    itemId: "ITEM_ID_FROM_ABOVE"
  }) {
    clientMutationId
  }
}'
```

## Content Management

### Content Structure
Content is organized in a hierarchical folder structure:
- **Categories**: Top-level organization (Claude Code, HR, etc.)
- **Modules**: Learning units within categories
- **Sections**: Individual lessons within modules
- **Quizzes**: Assessment for each module

See `docs/content-structure.md` for detailed file organization.

### Adding Content
1. Create appropriate folder structure under `public/data/`
2. Add JSON files following the schema in documentation
3. Run admin sync to update database
4. Content is version controlled in git

### Content Guidelines
- Keep modules focused on specific topics
- Use clear, actionable language
- Include practical examples relevant to the audience
- Ensure quiz questions test understanding, not memorization
- Tag new modules appropriately for notifications