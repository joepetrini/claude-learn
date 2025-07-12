# Category Migration Plan

This document outlines the migration strategy from the current single-module structure to the new category-based architecture.

## Current State

- Single `modules.json` file with all modules
- Single `quizzes.json` file with all quizzes  
- Module IDs are strings like "getting-started", "basic-commands"
- Progress tracked by module ID strings
- No category concept

## Target State

- Hierarchical folder structure by category
- Separate JSON files per module
- Database-driven categories and modules
- UUIDs for all records
- Progress tracked by UUID with migration mapping

## Migration Phases

### Phase 1: Database Schema Update ✅
**Status**: Ready to implement

1. Drop existing tables (we're not live yet)
2. Create new schema with categories and modules tables
3. Add migration mapping fields

### Phase 2: Content Reorganization
**Status**: Planning

1. **Create Initial Categories**
   - Claude Code Training (existing content)
   - HR Onboarding (placeholder)
   - Software Development (placeholder)
   - Customer Support (placeholder)

2. **Reorganize Files**
   ```bash
   # Current structure
   public/data/
   ├── modules.json
   └── quizzes.json

   # New structure
   public/data/
   ├── categories.json
   ├── claude-code/
   │   ├── category.json
   │   ├── modules.json
   │   ├── getting-started/
   │   │   ├── content.json
   │   │   └── quiz.json
   │   ├── basic-commands/
   │   │   ├── content.json
   │   │   └── quiz.json
   │   └── [other existing modules]
   ├── hr-onboarding/
   │   ├── category.json
   │   ├── modules.json
   │   └── [placeholder modules]
   └── [other categories]
   ```

### Phase 3: Migration Script
**Status**: To be implemented

Create `scripts/migrate-content.js`:

```javascript
// Pseudo-code for migration script
async function migrateContent() {
  // 1. Read existing modules.json and quizzes.json
  const modules = await readJSON('public/data/modules.json');
  const quizzes = await readJSON('public/data/quizzes.json');
  
  // 2. Create categories.json
  const categories = [
    {
      slug: 'claude-code',
      name: 'Claude Code Training',
      description: 'Master Claude Code for efficient development',
      icon: '🤖',
      color: '#3B82F6',
      sortOrder: 1,
      isActive: true
    }
  ];
  
  // 3. Create claude-code category folder
  await createFolder('public/data/claude-code');
  
  // 4. Create category.json
  await writeJSON('public/data/claude-code/category.json', {
    ...categories[0],
    metadata: {
      targetAudience: 'developers',
      version: '2.0'
    }
  });
  
  // 5. Transform modules for modules.json
  const transformedModules = modules.modules.map((module, index) => ({
    slug: module.id,
    title: module.title,
    description: module.description,
    icon: module.icon,
    estimatedTime: module.estimatedTime,
    difficultyLevel: 'beginner',
    sortOrder: index + 1,
    isActive: true,
    prerequisites: [],
    tags: []
  }));
  
  // 6. Create modules.json
  await writeJSON('public/data/claude-code/modules.json', {
    modules: transformedModules
  });
  
  // 7. Create individual module folders and files
  for (const module of modules.modules) {
    const moduleFolder = `public/data/claude-code/${module.id}`;
    await createFolder(moduleFolder);
    
    // Create content.json
    await writeJSON(`${moduleFolder}/content.json`, {
      module: {
        slug: module.id,
        title: module.title,
        version: '1.0',
        lastUpdated: new Date().toISOString(),
        sections: module.sections
      }
    });
    
    // Create quiz.json
    const quiz = quizzes.quizzes.find(q => q.moduleId === module.id);
    if (quiz) {
      await writeJSON(`${moduleFolder}/quiz.json`, {
        quiz: {
          passingScore: 80,
          questions: quiz.questions
        }
      });
    }
  }
}
```

### Phase 4: Frontend Updates
**Status**: To be implemented

1. **Update Router**
   - Add category routes: `/category/:slug`, `/category/:slug/module/:moduleSlug`
   - Update existing routes for backward compatibility

2. **Create New Components**
   - `CategoryList.vue` - Display all categories
   - `CategoryDetail.vue` - Show modules in a category
   - `FavoriteButton.vue` - Toggle favorite categories

3. **Update Existing Components**
   - `Home.vue` - Show categories instead of modules
   - `Navigation.vue` - Add category breadcrumbs
   - `Module.vue` - Load from new file structure

4. **Update Composables**
   - Create `useCategories.js` for category operations
   - Update `useSupabaseProgress.js` for UUID-based tracking
   - Add `useFavorites.js` for favorite management

### Phase 5: Admin Sync Implementation
**Status**: To be implemented

1. **Create Sync Components**
   - `ContentSync.vue` - Main sync dashboard
   - `SyncStatus.vue` - Show sync progress
   - `SyncHistory.vue` - View past syncs

2. **Implement Sync Logic**
   - File scanner to detect changes
   - Diff generator for preview
   - Database updater with transaction support
   - Rollback capability

### Phase 6: Data Migration
**Status**: To be implemented

For existing user data (when going live):

```sql
-- Migration script for existing progress data
-- Map old string IDs to new UUIDs

-- 1. Create temporary mapping table
CREATE TABLE module_id_mapping (
  old_id VARCHAR(100),
  new_id UUID,
  category_slug VARCHAR(100),
  module_slug VARCHAR(100)
);

-- 2. Insert mappings after content sync
INSERT INTO module_id_mapping (old_id, new_id, category_slug, module_slug)
SELECT 
  json_id as old_id,
  id as new_id,
  'claude-code' as category_slug,
  slug as module_slug
FROM modules
WHERE category_id = (SELECT id FROM categories WHERE slug = 'claude-code');

-- 3. Migrate progress data (example for module_progress)
-- This would be done programmatically to handle the string->UUID conversion
```

## Implementation Timeline

1. **Week 1**: Database schema and content reorganization
2. **Week 2**: Migration script and frontend category browsing
3. **Week 3**: Admin sync functionality
4. **Week 4**: Testing and refinement

## Rollback Plan

Since we're not live yet, rollback is straightforward:
1. Keep backup of current JSON files
2. Git commits for each migration step
3. Database can be dropped and recreated

## Testing Checklist

- [ ] All existing modules load correctly
- [ ] Category navigation works
- [ ] Module progress tracking continues
- [ ] Quiz attempts are recorded
- [ ] Admin sync detects changes
- [ ] File structure is maintainable
- [ ] Performance is acceptable
- [ ] URLs are SEO-friendly

## Future Considerations

1. **Multi-language Support**
   - Add language folders under categories
   - Track preferred language per user

2. **Content Permissions**
   - Some categories may be restricted
   - Role-based access control

3. **External Content**
   - API for third-party content
   - Content marketplace

4. **Analytics**
   - Track popular categories
   - Module completion rates by category
   - User engagement metrics