-- Fix corrupted favorites data
-- Remove records where course_id looks like a UUID (user ID) instead of a course slug

-- First, let's see what corrupted data exists
SELECT 
  user_id,
  course_id,
  resource_id,
  favorited_at,
  CASE 
    WHEN course_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' 
    THEN 'UUID (corrupted)' 
    ELSE 'Valid course slug' 
  END as status
FROM user_favorite_resources_simple 
ORDER BY favorited_at DESC;

-- Delete corrupted records where course_id is a UUID instead of a course slug
DELETE FROM user_favorite_resources_simple 
WHERE course_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- Show remaining records
SELECT 
  user_id,
  course_id,
  resource_id,
  favorited_at
FROM user_favorite_resources_simple 
ORDER BY favorited_at DESC;