#!/bin/bash
# Migrate from legacy single-file structure to category-based structure

echo "🔄 Starting migration to category-based content structure..."

# Check if already migrated
if [ -f "public/data/categories.json" ]; then
    echo "⚠️  Warning: categories.json already exists. Content appears to be already migrated."
    read -p "Continue anyway? This will overwrite existing category structure. (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Migration cancelled."
        exit 1
    fi
fi

# Check for legacy files
if [ ! -f "public/data/modules.json" ] || [ ! -f "public/data/quizzes.json" ]; then
    echo "❌ Error: Legacy files (modules.json, quizzes.json) not found."
    echo "This script migrates from the legacy structure to category-based structure."
    exit 1
fi

# Create backup first
echo "📦 Creating backup of current content..."
npm run archive "Pre-migration backup" || exit 1

# Create categories.json
echo "📝 Creating categories.json..."
cat > public/data/categories.json << 'EOF'
{
  "categories": [
    {
      "slug": "software-dev",
      "name": "Software Development",
      "description": "Technical training for developers and engineers",
      "icon": "💻",
      "color": "#8B5CF6",
      "sortOrder": 1,
      "isActive": true
    },
    {
      "slug": "hr-onboarding",
      "name": "HR & Onboarding",
      "description": "New employee orientation and company culture",
      "icon": "👥",
      "color": "#10B981",
      "sortOrder": 2,
      "isActive": true
    },
    {
      "slug": "customer-support",
      "name": "Customer Support",
      "description": "Customer service excellence and support training",
      "icon": "🎧",
      "color": "#F59E0B",
      "sortOrder": 3,
      "isActive": true
    },
    {
      "slug": "product-training",
      "name": "Product Training",
      "description": "Product knowledge and feature training",
      "icon": "📦",
      "color": "#EC4899",
      "sortOrder": 4,
      "isActive": true
    }
  ]
}
EOF

# Create software-dev category folder and claude-code-training course
echo "📁 Creating category and course folders..."
mkdir -p public/data/software-dev/claude-code-training

# Create courses.json for software-dev
cat > public/data/software-dev/courses.json << 'EOF'
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
      "tags": ["ai", "productivity", "development", "claude"]
    }
  ]
}
EOF

# Create course.json for claude-code-training
cat > public/data/software-dev/claude-code-training/course.json << 'EOF'
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
      "Debug and refactor with AI assistance",
      "Integrate Claude Code into your workflow"
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
EOF

# Read existing modules and quizzes
echo "📖 Reading legacy content..."
MODULES=$(cat public/data/modules.json)
QUIZZES=$(cat public/data/quizzes.json)

# Transform modules for new structure
echo "🔧 Transforming modules..."
echo "$MODULES" | jq '.modules | map({
  slug: .id,
  title: .title,
  description: .description,
  icon: .icon,
  estimatedTime: .estimatedTime,
  difficultyLevel: "beginner",
  sortOrder: 0,
  isActive: true,
  isNew: false,
  prerequisites: [],
  tags: []
})' | jq '{ modules: . }' > public/data/software-dev/claude-code-training/modules.json

# Create individual module folders and content
echo "📂 Creating module folders..."
echo "$MODULES" | jq -c '.modules[]' | while read -r module; do
    MODULE_ID=$(echo "$module" | jq -r '.id')
    MODULE_TITLE=$(echo "$module" | jq -r '.title')
    
    # Create module directory
    mkdir -p "public/data/software-dev/claude-code-training/$MODULE_ID"
    
    # Create content.json
    echo "$module" | jq '{
      module: {
        slug: .id,
        title: .title,
        version: "1.0",
        lastUpdated: (now | strftime("%Y-%m-%d")),
        sections: .sections
      }
    }' > "public/data/software-dev/claude-code-training/$MODULE_ID/content.json"
    
    # Find and create quiz.json
    QUIZ=$(echo "$QUIZZES" | jq --arg id "$MODULE_ID" '.quizzes[] | select(.moduleId == $id)')
    if [ ! -z "$QUIZ" ]; then
        echo "$QUIZ" | jq '{
          quiz: {
            passingScore: 80,
            questions: .questions
          }
        }' > "public/data/software-dev/claude-code-training/$MODULE_ID/quiz.json"
    fi
    
    echo "  ✅ Created module: $MODULE_ID - $MODULE_TITLE"
done

# Update version.json
echo "📝 Updating version file..."
cat > public/data/version.json << EOF
{
  "contentVersion": "2.0.0",
  "structureVersion": "category-course-based",
  "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "migrationDate": "$(date +%Y-%m-%d)"
}
EOF

# Create placeholder categories
echo "🆕 Creating placeholder categories..."

# HR Onboarding
mkdir -p public/data/hr-onboarding
cat > public/data/hr-onboarding/courses.json << 'EOF'
{
  "courses": []
}
EOF

# Customer Support
mkdir -p public/data/customer-support
cat > public/data/customer-support/courses.json << 'EOF'
{
  "courses": []
}
EOF

# Product Training
mkdir -p public/data/product-training
cat > public/data/product-training/courses.json << 'EOF'
{
  "courses": []
}
EOF

# Show summary
echo ""
echo "✨ Migration completed successfully!"
echo ""
echo "📊 Migration Summary:"
echo "  - Created 4 categories"
echo "  - Created Claude Code Training course in Software Development"
echo "  - Migrated $(echo "$MODULES" | jq '.modules | length') modules to the course"
echo "  - Created placeholder categories for future content"
echo ""
echo "📁 New structure:"
echo "  public/data/"
echo "  ├── categories.json"
echo "  ├── software-dev/"
echo "  │   ├── courses.json"
echo "  │   └── claude-code-training/"
echo "  │       ├── course.json"
echo "  │       ├── modules.json"
echo "  │       └── [$(echo "$MODULES" | jq '.modules | length') modules]"
echo "  ├── hr-onboarding/"
echo "  └── customer-support/"
echo ""
echo "⚠️  Note: Legacy files (modules.json, quizzes.json) are still present."
echo "Run 'npm run cleanup-legacy' after verifying the migration."