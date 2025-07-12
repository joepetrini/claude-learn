#!/bin/bash
# Archive current content before updates

# Get current date and version
DATE=$(date +%Y-%m-%d)
VERSION=$(jq -r .contentVersion public/data/version.json 2>/dev/null || echo "1.0.0")
ARCHIVE_DIR="public/data/archive/${DATE}_v${VERSION}"

# Default reason if none provided
REASON="${1:-Manual archive}"

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# Copy current files if they exist
if [ -f "public/data/modules.json" ]; then
    cp public/data/modules.json "$ARCHIVE_DIR/"
fi

if [ -f "public/data/quizzes.json" ]; then
    cp public/data/quizzes.json "$ARCHIVE_DIR/"
fi

if [ -f "public/data/version.json" ]; then
    cp public/data/version.json "$ARCHIVE_DIR/"
fi

# Create archive manifest
cat > "$ARCHIVE_DIR/manifest.json" << EOF
{
  "archivedDate": "$DATE",
  "contentVersion": "$VERSION",
  "reason": "$REASON",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "filesIncluded": ["modules.json", "quizzes.json", "version.json"]
}
EOF

echo "✅ Archived version $VERSION to $ARCHIVE_DIR"
echo "📝 Reason: $REASON"