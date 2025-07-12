#!/bin/bash
# Restore content from a specific archive

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

# Create backup of current content before restoring
echo "📦 Creating backup of current content..."
npm run archive "Backup before restore from $1" > /dev/null

# Restore files
echo "♻️  Restoring from $ARCHIVE_DIR..."

if [ -f "$ARCHIVE_DIR/modules.json" ]; then
    cp "$ARCHIVE_DIR/modules.json" public/data/
    echo "✅ Restored modules.json"
fi

if [ -f "$ARCHIVE_DIR/quizzes.json" ]; then
    cp "$ARCHIVE_DIR/quizzes.json" public/data/
    echo "✅ Restored quizzes.json"
fi

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