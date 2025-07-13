-- Fix missing user profile for favorites functionality
-- This creates the missing profile record that should have been auto-created

-- Check if the user exists in auth.users but not in profiles
SELECT 
  auth_users.id,
  auth_users.email,
  CASE WHEN profiles.id IS NULL THEN 'MISSING PROFILE' ELSE 'HAS PROFILE' END as profile_status
FROM auth.users auth_users
LEFT JOIN profiles ON profiles.id = auth_users.id
WHERE auth_users.email = 'joepetrini@gmail.com';

-- Insert the missing profile (adjust the user ID based on the result above)
INSERT INTO profiles (id, email, full_name, avatar_url, is_admin, created_at, updated_at)
SELECT 
  auth_users.id,
  auth_users.email,
  COALESCE(
    auth_users.raw_user_meta_data->>'full_name',
    auth_users.raw_user_meta_data->>'name',
    split_part(auth_users.email, '@', 1)
  ) as full_name,
  auth_users.raw_user_meta_data->>'avatar_url' as avatar_url,
  false as is_admin,
  NOW(),
  NOW()
FROM auth.users auth_users
WHERE auth_users.email = 'joepetrini@gmail.com'
  AND NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth_users.id);

-- Verify the profile was created
SELECT 
  id,
  email,
  full_name,
  is_admin,
  created_at
FROM profiles 
WHERE email = 'joepetrini@gmail.com';