#!/bin/bash
# Clean up legacy files after successful migration to category structure

echo "🧹 Cleaning up legacy content files..."

# Check if migration has been done
if [ ! -f "public/data/categories.json" ]; then
    echo "❌ Error: categories.json not found. Please run migration first."
    echo "Run: npm run migrate-content"
    exit 1
fi

# Check if legacy files exist
LEGACY_EXISTS=false
if [ -f "public/data/modules.json" ] || [ -f "public/data/quizzes.json" ]; then
    LEGACY_EXISTS=true
fi

if [ "$LEGACY_EXISTS" = false ]; then
    echo "✅ No legacy files found. Already cleaned up!"
    exit 0
fi

# Confirm with user
echo "⚠️  This will remove the following legacy files:"
[ -f "public/data/modules.json" ] && echo "  - modules.json"
[ -f "public/data/quizzes.json" ] && echo "  - quizzes.json"
echo ""
read -p "Are you sure you want to remove legacy files? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 1
fi

# Create one last backup
echo "📦 Creating final backup of legacy files..."
BACKUP_DIR="public/data/archive/legacy-final-backup-$(date +%Y-%m-%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "public/data/modules.json" ]; then
    cp public/data/modules.json "$BACKUP_DIR/"
fi

if [ -f "public/data/quizzes.json" ]; then
    cp public/data/quizzes.json "$BACKUP_DIR/"
fi

echo "✅ Legacy files backed up to: $BACKUP_DIR"

# Remove legacy files
echo "🗑️  Removing legacy files..."
rm -f public/data/modules.json
rm -f public/data/quizzes.json

echo ""
echo "✨ Legacy cleanup complete!"
echo "📁 Your content now uses the category-based structure exclusively."