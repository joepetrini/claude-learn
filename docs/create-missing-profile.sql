-- Create Missing User Profile
-- Run this in Supabase SQL Editor to create your profile

-- This will create a profile for your current authenticated user
-- Replace with your actual user info if needed

INSERT INTO profiles (id, email, full_name, avatar_url, is_admin, created_at, updated_at)
SELECT 
  auth.uid() as id,
  (auth.jwt() -> 'email')::text as email,
  COALESCE(
    (auth.jwt() -> 'user_metadata' ->> 'full_name'), 
    (auth.jwt() -> 'user_metadata' ->> 'name'),
    'User'
  ) as full_name,
  (auth.jwt() -> 'user_metadata' ->> 'avatar_url') as avatar_url,
  false as is_admin,
  NOW() as created_at,
  NOW() as updated_at
WHERE auth.uid() IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid());