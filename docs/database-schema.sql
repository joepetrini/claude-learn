-- Claude Learn Database Schema v2.0
-- Complete database setup for Claude Learn with Categories and Content Organization
-- 
-- This is the ONLY SQL file needed for initial setup.
-- Run this entire script in Supabase SQL Editor before launch.
-- 
-- Includes:
-- - All table definitions with three-level hierarchy (Category → Course → Module)
-- - Row Level Security (RLS) policies
-- - Helper functions for progress tracking
-- - Triggers for auto-updating timestamps
-- - Auto-profile creation for new users
-- - Admin content sync support
-- - Fixes for RLS recursion issues

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Categories table
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug VARCHAR(100) UNIQUE NOT NULL, -- URL-friendly identifier matching folder name
  name VARCHAR(255) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  color VARCHAR(50), -- For UI theming
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}', -- Flexible field for additional data
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses table (linked to categories)
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  slug VARCHAR(100) NOT NULL, -- URL-friendly identifier matching folder name
  title VARCHAR(255) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  estimated_duration VARCHAR(50),
  module_count INTEGER DEFAULT 0,
  difficulty_level VARCHAR(50), -- beginner, intermediate, advanced
  prerequisites JSONB DEFAULT '[]', -- Array of course slugs
  tags JSONB DEFAULT '[]', -- For searching/filtering
  is_featured BOOLEAN DEFAULT false,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_new BOOLEAN DEFAULT false, -- Flag for new courses
  new_until DATE, -- Auto-remove "new" flag after this date
  metadata JSONB DEFAULT '{}', -- author, learning outcomes, etc.
  settings JSONB DEFAULT '{}', -- course-specific settings
  content_version VARCHAR(50), -- Track content version for sync
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(category_id, slug)
);

-- Modules table (linked to courses)
CREATE TABLE modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  slug VARCHAR(100) NOT NULL, -- URL-friendly identifier matching folder name
  json_id VARCHAR(100), -- Legacy ID for migration
  title VARCHAR(255) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  estimated_time VARCHAR(50),
  difficulty_level VARCHAR(50), -- beginner, intermediate, advanced
  prerequisites JSONB DEFAULT '[]', -- Array of module slugs within same course
  tags JSONB DEFAULT '[]', -- For searching/filtering
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  is_new BOOLEAN DEFAULT false, -- Flag for new modules
  new_until DATE, -- Auto-remove "new" flag after this date
  metadata JSONB DEFAULT '{}',
  content_version VARCHAR(50), -- Track content version for sync
  last_synced_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(course_id, slug)
);

-- User profiles table (existing, no changes)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  is_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User favorite categories
CREATE TABLE user_favorite_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category_id)
);

-- Module progress (updated to reference modules table)
CREATE TABLE module_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  status VARCHAR(50) DEFAULT 'not_started', -- not_started, in_progress, completed
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  current_section INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, module_id)
);

-- Section progress (updated to reference modules table)
CREATE TABLE section_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  section_index INTEGER NOT NULL,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  time_spent INTEGER DEFAULT 0, -- in seconds
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, module_id, section_index)
);

-- Quiz attempts (updated to reference modules table)
CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  passed BOOLEAN NOT NULL,
  time_taken INTEGER, -- in seconds
  attempt_number INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Quiz answers
CREATE TABLE quiz_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_index INTEGER NOT NULL,
  selected_answer INTEGER NOT NULL,
  is_correct BOOLEAN NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content sync history (for admin tracking)
CREATE TABLE content_sync_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES profiles(id),
  sync_type VARCHAR(50) NOT NULL, -- full, category, course, module
  target_id UUID, -- category_id, course_id, or module_id if partial sync
  changes_summary JSONB NOT NULL, -- what was added/updated/removed
  status VARCHAR(50) NOT NULL, -- pending, in_progress, completed, failed
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  error_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User notifications (for new content in favorite categories)
CREATE TABLE user_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- new_module, updated_module, etc.
  title VARCHAR(255) NOT NULL,
  message TEXT,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  module_id UUID REFERENCES modules(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMP WITH TIME ZONE,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_courses_category ON courses(category_id);
CREATE INDEX idx_courses_slug ON courses(slug);
CREATE INDEX idx_modules_course ON modules(course_id);
CREATE INDEX idx_modules_slug ON modules(slug);
CREATE INDEX idx_module_progress_user ON module_progress(user_id);
CREATE INDEX idx_module_progress_module ON module_progress(module_id);
CREATE INDEX idx_section_progress_user_module ON section_progress(user_id, module_id);
CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_module ON quiz_attempts(module_id);
CREATE INDEX idx_user_favorites_user ON user_favorite_categories(user_id);
CREATE INDEX idx_user_notifications_user ON user_notifications(user_id, is_read);
CREATE INDEX idx_content_sync_admin ON content_sync_history(admin_id);

-- Row Level Security Policies

-- Categories (public read)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (is_active = true);

-- Courses (public read for active courses)
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active courses are viewable by everyone" ON courses
  FOR SELECT USING (is_active = true);

-- Modules (public read for active modules)
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active modules are viewable by everyone" ON modules
  FOR SELECT USING (is_active = true);

-- User favorite categories
ALTER TABLE user_favorite_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own favorites" ON user_favorite_categories
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites" ON user_favorite_categories
  FOR ALL USING (auth.uid() = user_id);

-- Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Module progress
ALTER TABLE module_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own progress" ON module_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own progress" ON module_progress
  FOR ALL USING (auth.uid() = user_id);

-- Section progress
ALTER TABLE section_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own section progress" ON section_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own section progress" ON section_progress
  FOR ALL USING (auth.uid() = user_id);

-- Quiz attempts
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own quiz attempts" ON quiz_attempts
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own quiz attempts" ON quiz_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Quiz answers
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own quiz answers" ON quiz_answers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM quiz_attempts 
      WHERE quiz_attempts.id = quiz_answers.attempt_id 
      AND quiz_attempts.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can create own quiz answers" ON quiz_answers
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM quiz_attempts 
      WHERE quiz_attempts.id = quiz_answers.attempt_id 
      AND quiz_attempts.user_id = auth.uid()
    )
  );

-- User notifications
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notifications" ON user_notifications
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON user_notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Content sync history (admin only)
ALTER TABLE content_sync_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Only admins can view sync history" ON content_sync_history
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

-- Admin policies for data management
CREATE POLICY "Admins can manage all categories" ON categories
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can manage all courses" ON courses
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can manage all modules" ON modules
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can view all user data" ON module_progress
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can create notifications" ON user_notifications
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

-- Helper functions

-- Function to get course progress
CREATE OR REPLACE FUNCTION get_course_progress(p_user_id UUID, p_course_id UUID)
RETURNS TABLE(
  total_modules INTEGER,
  completed_modules INTEGER,
  in_progress_modules INTEGER,
  progress_percentage INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(m.id)::INTEGER as total_modules,
    COUNT(CASE WHEN mp.status = 'completed' THEN 1 END)::INTEGER as completed_modules,
    COUNT(CASE WHEN mp.status = 'in_progress' THEN 1 END)::INTEGER as in_progress_modules,
    CASE 
      WHEN COUNT(m.id) > 0 
      THEN (COUNT(CASE WHEN mp.status = 'completed' THEN 1 END) * 100 / COUNT(m.id))::INTEGER
      ELSE 0
    END as progress_percentage
  FROM modules m
  LEFT JOIN module_progress mp ON m.id = mp.module_id AND mp.user_id = p_user_id
  WHERE m.course_id = p_course_id AND m.is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Function to get category progress (all courses in category)
CREATE OR REPLACE FUNCTION get_category_progress(p_user_id UUID, p_category_id UUID)
RETURNS TABLE(
  total_courses INTEGER,
  total_modules INTEGER,
  completed_modules INTEGER,
  in_progress_modules INTEGER,
  progress_percentage INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(DISTINCT c.id)::INTEGER as total_courses,
    COUNT(m.id)::INTEGER as total_modules,
    COUNT(CASE WHEN mp.status = 'completed' THEN 1 END)::INTEGER as completed_modules,
    COUNT(CASE WHEN mp.status = 'in_progress' THEN 1 END)::INTEGER as in_progress_modules,
    CASE 
      WHEN COUNT(m.id) > 0 
      THEN (COUNT(CASE WHEN mp.status = 'completed' THEN 1 END) * 100 / COUNT(m.id))::INTEGER
      ELSE 0
    END as progress_percentage
  FROM courses c
  INNER JOIN modules m ON c.id = m.course_id AND m.is_active = true
  LEFT JOIN module_progress mp ON m.id = mp.module_id AND mp.user_id = p_user_id
  WHERE c.category_id = p_category_id AND c.is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Function to get user's overall progress
CREATE OR REPLACE FUNCTION get_user_overall_progress(p_user_id UUID)
RETURNS TABLE(
  total_categories INTEGER,
  total_courses INTEGER,
  total_modules INTEGER,
  completed_modules INTEGER,
  in_progress_modules INTEGER,
  favorite_categories INTEGER,
  overall_percentage INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT COUNT(*)::INTEGER FROM categories WHERE is_active = true) as total_categories,
    (SELECT COUNT(*)::INTEGER FROM courses WHERE is_active = true) as total_courses,
    (SELECT COUNT(*)::INTEGER FROM modules WHERE is_active = true) as total_modules,
    (SELECT COUNT(*)::INTEGER FROM module_progress WHERE user_id = p_user_id AND status = 'completed') as completed_modules,
    (SELECT COUNT(*)::INTEGER FROM module_progress WHERE user_id = p_user_id AND status = 'in_progress') as in_progress_modules,
    (SELECT COUNT(*)::INTEGER FROM user_favorite_categories WHERE user_id = p_user_id) as favorite_categories,
    CASE 
      WHEN (SELECT COUNT(*) FROM modules WHERE is_active = true) > 0 
      THEN ((SELECT COUNT(*) FROM module_progress WHERE user_id = p_user_id AND status = 'completed') * 100 / 
            (SELECT COUNT(*) FROM modules WHERE is_active = true))::INTEGER
      ELSE 0
    END as overall_percentage;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at columns
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for all tables with updated_at
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_modules_updated_at BEFORE UPDATE ON modules
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_module_progress_updated_at BEFORE UPDATE ON module_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_section_progress_updated_at BEFORE UPDATE ON section_progress
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create sync_log table (used by admin content sync)
CREATE TABLE IF NOT EXISTS sync_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_type VARCHAR(50) NOT NULL,
  status VARCHAR(50) NOT NULL,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on sync_log
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies for sync_log (admin only)
CREATE POLICY "Only admins can view sync logs" ON sync_log
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

CREATE POLICY "Only admins can create sync logs" ON sync_log
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- Fix for potential RLS recursion issues
-- Drop and recreate problematic policies with simpler logic
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

-- Recreate profiles policies without recursion
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Function to create profile if missing (for auto-profile creation)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      split_part(NEW.email, '@', 1)
    ),
    NEW.raw_user_meta_data->>'avatar_url'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Helper query to create missing profile for existing users
-- Run this after initial setup if you have existing users
/*
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
*/