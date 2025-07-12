#!/bin/bash
# Reorganize existing category structure to include courses layer

echo "🔄 Reorganizing content to category → course → module structure..."

# Check if claude-code folder exists
if [ ! -d "public/data/claude-code" ]; then
    echo "❌ Error: claude-code folder not found."
    echo "This script reorganizes the existing claude-code category into a course under software-dev."
    exit 1
fi

# Create backup first
echo "📦 Creating backup of current content..."
npm run archive "Pre-reorganization backup" || exit 1

# Step 1: Clean up nested category.json files
echo "🧹 Removing nested category.json files..."
rm -f public/data/*/category.json
rm -f public/data/*/*/category.json

# Step 2: Create/update software-dev courses structure
echo "📁 Creating software-dev course structure..."
mkdir -p public/data/software-dev

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

# Step 3: Move claude-code content to software-dev/claude-code-training
echo "📦 Moving Claude Code content to software-dev as a course..."
if [ -d "public/data/software-dev/claude-code-training" ]; then
    echo "  ⚠️  Removing existing claude-code-training folder..."
    rm -rf public/data/software-dev/claude-code-training
fi

# Move the entire claude-code folder
mv public/data/claude-code public/data/software-dev/claude-code-training

# Step 4: Create course.json for claude-code-training
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

# Step 5: Update categories.json to ensure software-dev is first
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

# Step 6: Ensure other categories have courses.json
for category in hr-onboarding customer-support product-training; do
    if [ ! -f "public/data/$category/courses.json" ]; then
        echo "  📝 Creating courses.json for $category..."
        cat > "public/data/$category/courses.json" << 'EOF'
{
  "courses": []
}
EOF
    fi
done

# Step 7: Update version.json
cat > public/data/version.json << EOF
{
  "contentVersion": "2.0.0",
  "structureVersion": "category-course-module",
  "lastUpdated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "reorganizationDate": "$(date +%Y-%m-%d)"
}
EOF

# Show summary
echo ""
echo "✨ Reorganization completed successfully!"
echo ""
echo "📊 Summary:"
echo "  - Moved claude-code → software-dev/claude-code-training"
echo "  - Added course layer between categories and modules"
echo "  - Removed nested category.json files"
echo "  - Updated categories.json as single source of truth"
echo ""
echo "📁 New structure:"
echo "  public/data/"
echo "  ├── categories.json (single source of truth)"
echo "  ├── software-dev/"
echo "  │   ├── courses.json"
echo "  │   └── claude-code-training/"
echo "  │       ├── course.json"
echo "  │       ├── modules.json"
echo "  │       └── [modules...]"
echo "  ├── hr-onboarding/"
echo "  │   └── courses.json"
echo "  ├── customer-support/"
echo "  │   └── courses.json"
echo "  └── product-training/"
echo "      └── courses.json"