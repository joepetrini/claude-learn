#!/bin/bash
# Archive current content before updates
# Supports both legacy single-file and new category-based structure

# Get current date and version
DATE=$(date +%Y-%m-%d)
VERSION=$(jq -r .contentVersion public/data/version.json 2>/dev/null || echo "2.0.0")
ARCHIVE_DIR="public/data/archive/${DATE}_v${VERSION}"

# Default reason if none provided
REASON="${1:-Manual archive}"

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# Track what we archive
FILES_ARCHIVED=()

# Archive legacy files if they exist
if [ -f "public/data/modules.json" ]; then
    cp public/data/modules.json "$ARCHIVE_DIR/"
    FILES_ARCHIVED+=("modules.json")
    echo "📄 Archived modules.json (legacy)"
fi

if [ -f "public/data/quizzes.json" ]; then
    cp public/data/quizzes.json "$ARCHIVE_DIR/"
    FILES_ARCHIVED+=("quizzes.json")
    echo "📄 Archived quizzes.json (legacy)"
fi

if [ -f "public/data/version.json" ]; then
    cp public/data/version.json "$ARCHIVE_DIR/"
    FILES_ARCHIVED+=("version.json")
fi

# Archive new category structure if it exists
if [ -f "public/data/categories.json" ]; then
    cp public/data/categories.json "$ARCHIVE_DIR/"
    FILES_ARCHIVED+=("categories.json")
    echo "📄 Archived categories.json"
    
    # Archive each category folder
    for category_dir in public/data/*/; do
        # Skip archive directory and non-directories
        if [[ "$category_dir" == *"/archive/"* ]] || [ ! -d "$category_dir" ]; then
            continue
        fi
        
        # Get category name
        category_name=$(basename "$category_dir")
        
        # Create category archive directory
        mkdir -p "$ARCHIVE_DIR/$category_name"
        
        # Copy entire category folder
        cp -r "$category_dir"* "$ARCHIVE_DIR/$category_name/" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "📁 Archived category: $category_name"
            FILES_ARCHIVED+=("$category_name/")
        fi
    done
fi

# Create archive manifest
cat > "$ARCHIVE_DIR/manifest.json" << EOF
{
  "archivedDate": "$DATE",
  "contentVersion": "$VERSION",
  "reason": "$REASON",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "structureType": $([ -f "public/data/categories.json" ] && echo '"category-based"' || echo '"legacy"'),
  "filesIncluded": $(printf '%s\n' "${FILES_ARCHIVED[@]}" | jq -R . | jq -s .)
}
EOF

echo ""
echo "✅ Archived version $VERSION to $ARCHIVE_DIR"
echo "📝 Reason: $REASON"
echo "📊 Structure: $([ -f "public/data/categories.json" ] && echo 'category-based' || echo 'legacy')"
echo "📦 Files archived: ${#FILES_ARCHIVED[@]}"