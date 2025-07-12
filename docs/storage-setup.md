# Storage Setup for Profile Pictures

## Create Avatars Storage Bucket

To enable profile picture uploads, you need to create a storage bucket in Supabase:

### 1. Create Storage Bucket

1. Go to your Supabase project dashboard
2. Click on "Storage" in the left sidebar
3. Click "New bucket"
4. Enter bucket name: `avatars`
5. Set as **Public bucket** (checked)
6. Click "Create bucket"

### 2. Set Storage Policies

Run this SQL in the Supabase SQL Editor to set up proper access policies:

```sql
-- Allow users to upload their own avatars
CREATE POLICY "Users can upload own avatar" ON storage.objects
  FOR INSERT 
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to update their own avatars
CREATE POLICY "Users can update own avatar" ON storage.objects
  FOR UPDATE 
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own avatars
CREATE POLICY "Users can delete own avatar" ON storage.objects
  FOR DELETE 
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public access to view avatars
CREATE POLICY "Public avatar access" ON storage.objects
  FOR SELECT 
  USING (bucket_id = 'avatars');
```

### 3. Test Avatar Upload

After setting up the storage bucket:

1. Go to `/profile` in your app
2. Try uploading a profile picture
3. The image should upload successfully and appear immediately

### Troubleshooting

If you see errors like:
- "Avatar storage not configured" - Make sure the `avatars` bucket exists
- "Access denied" - Check that the storage policies are properly set
- "File too large" - Ensure the image is under 2MB

### File Organization

Avatars are stored with the pattern:
```
avatars/
  ├── user-id-1-random.jpg
  ├── user-id-2-random.png
  └── user-id-3-random.gif
```

Each user can have multiple avatar files (older ones are kept for now, but you could implement cleanup later).