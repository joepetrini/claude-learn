#!/bin/bash
# Restore content from a specific archive
# Supports both legacy single-file and new category-based structure

# Check if archive directory is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide an archive directory name"
    echo "Usage: npm run restore 2025-01-12_v1.0.0"
    echo ""
    echo "Available archives:"
    ls -1 public/data/archive/ 2>/dev/null || echo "No archives found"
    exit 1
fi

ARCHIVE_DIR="public/data/archive/$1"

# Check if archive exists
if [ ! -d "$ARCHIVE_DIR" ]; then
    echo "❌ Error: Archive not found: $ARCHIVE_DIR"
    echo ""
    echo "Available archives:"
    ls -1 public/data/archive/ 2>/dev/null || echo "No archives found"
    exit 1
fi

# Detect archive structure type
STRUCTURE_TYPE="legacy"
if [ -f "$ARCHIVE_DIR/manifest.json" ]; then
    STRUCTURE_TYPE=$(jq -r .structureType "$ARCHIVE_DIR/manifest.json" 2>/dev/null || echo "legacy")
fi

# Create backup of current content before restoring
echo "📦 Creating backup of current content..."
npm run archive "Backup before restore from $1" > /dev/null

echo "♻️  Restoring from $ARCHIVE_DIR (${STRUCTURE_TYPE} structure)..."

# Function to clean current content
clean_current_content() {
    # Remove legacy files if they exist
    rm -f public/data/modules.json
    rm -f public/data/quizzes.json
    
    # Remove category-based files/folders if they exist
    if [ -f "public/data/categories.json" ]; then
        rm -f public/data/categories.json
        
        # Remove all category directories (except archive)
        for category_dir in public/data/*/; do
            if [[ "$category_dir" != *"/archive/"* ]] && [ -d "$category_dir" ]; then
                rm -rf "$category_dir"
            fi
        done
    fi
}

# Clean current content
clean_current_content

# Restore based on structure type
if [ "$STRUCTURE_TYPE" = "category-based" ]; then
    # Restore category-based structure
    if [ -f "$ARCHIVE_DIR/categories.json" ]; then
        cp "$ARCHIVE_DIR/categories.json" public/data/
        echo "✅ Restored categories.json"
    fi
    
    # Restore each category folder
    for category_path in "$ARCHIVE_DIR"/*/; do
        if [ -d "$category_path" ] && [ "$(basename "$category_path")" != "archive" ]; then
            category_name=$(basename "$category_path")
            
            # Skip manifest.json and other non-category files
            if [[ "$category_name" == *.json ]]; then
                continue
            fi
            
            # Create category directory and copy contents
            mkdir -p "public/data/$category_name"
            cp -r "$category_path"* "public/data/$category_name/" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "✅ Restored category: $category_name"
            fi
        fi
    done
else
    # Restore legacy structure
    if [ -f "$ARCHIVE_DIR/modules.json" ]; then
        cp "$ARCHIVE_DIR/modules.json" public/data/
        echo "✅ Restored modules.json"
    fi
    
    if [ -f "$ARCHIVE_DIR/quizzes.json" ]; then
        cp "$ARCHIVE_DIR/quizzes.json" public/data/
        echo "✅ Restored quizzes.json"
    fi
fi

# Always restore version.json if it exists
if [ -f "$ARCHIVE_DIR/version.json" ]; then
    cp "$ARCHIVE_DIR/version.json" public/data/
    echo "✅ Restored version.json"
fi

# Show restore info
if [ -f "$ARCHIVE_DIR/manifest.json" ]; then
    echo ""
    echo "📋 Restored archive info:"
    jq . "$ARCHIVE_DIR/manifest.json"
fi

echo ""
echo "✨ Content restored successfully from $1"
echo "📊 Structure type: $STRUCTURE_TYPE"