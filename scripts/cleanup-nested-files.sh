#!/bin/bash
# Clean up nested category.json files that shouldn't exist in the new structure

echo "🧹 Cleaning up nested category.json files..."

# Find and remove any category.json files inside category folders
FOUND_FILES=0

# Check each category directory
for category_dir in public/data/*/; do
    # Skip archive directory
    if [[ "$category_dir" == *"/archive/"* ]]; then
        continue
    fi
    
    # Look for category.json in the category folder
    if [ -f "${category_dir}category.json" ]; then
        echo "  🗑️  Removing: ${category_dir}category.json"
        rm "${category_dir}category.json"
        ((FOUND_FILES++))
    fi
    
    # Also check in course folders for any misplaced category.json
    for course_dir in "$category_dir"*/; do
        if [ -d "$course_dir" ] && [ -f "${course_dir}category.json" ]; then
            echo "  🗑️  Removing: ${course_dir}category.json"
            rm "${course_dir}category.json"
            ((FOUND_FILES++))
        fi
    done
done

if [ $FOUND_FILES -eq 0 ]; then
    echo "✅ No nested category.json files found. Structure is clean!"
else
    echo ""
    echo "✅ Removed $FOUND_FILES nested category.json file(s)"
    echo "📁 The only category metadata should be in public/data/categories.json"
fi