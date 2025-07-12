# Supabase Database Setup Guide

## Quick Fix for RLS Recursion Error

If you're seeing "infinite recursion detected in policy for relation 'profiles'", run this fix first:

### 1. Open Supabase SQL Editor
1. Go to your Supabase project dashboard
2. Click on "SQL Editor" in the left sidebar
3. Click "New query"

### 2. Run the Fix Script FIRST
1. Copy the entire contents of `docs/fix-rls-policies.sql`
2. Paste it into the SQL Editor
3. Click "Run" to fix the recursion issue

### 3. Then Run the Database Schema (if tables don't exist)
1. Copy the entire contents of `docs/database-schema.sql`
2. Paste it into a new SQL Editor query
3. Click "Run" to execute the schema

### 4. Verify Tables Created
After running the schema, you should see these tables in the Table Editor:
- `profiles`
- `module_progress` 
- `section_progress`
- `quiz_attempts`
- `quiz_answers`

### 4. Test the Setup
1. Reload your app
2. Check browser console for table test results
3. Try completing a quiz - it should now save to the database

## What the Schema Creates

### Tables
- **profiles**: User profiles (auto-created on signup)
- **module_progress**: Tracks which modules users have started/completed
- **section_progress**: Tracks individual section completion within modules
- **quiz_attempts**: Records each quiz attempt with score and pass/fail
- **quiz_answers**: Detailed answer tracking for each quiz question

### Security
- Row Level Security (RLS) enabled on all tables
- Users can only access their own data
- Admin users can view all data (for future dashboard)

### Automatic Features
- Profile auto-creation when users sign up via OAuth
- Timestamp tracking on all records
- Unique constraints to prevent duplicate entries

## Troubleshooting

### If tables still don't work:
1. Check the SQL Editor for any error messages
2. Make sure you're running the query in the correct database
3. Verify your Supabase project URL and keys are correct

### If you see permission errors:
1. Check that RLS policies were created
2. Make sure your user is properly authenticated
3. Try the debug tools: `window.supabaseProgressDebug.testTables()`

## Debug Commands

Once the tables are created, you can test the system:

```javascript
// Test database connectivity
await window.supabaseProgressDebug.testTables()

// Test quiz saving
await window.supabaseProgressDebug.testQuizSave()

// View current progress
window.supabaseProgressDebug.getProgress()
```

After running the database schema, the quiz saving should work perfectly! 🎯