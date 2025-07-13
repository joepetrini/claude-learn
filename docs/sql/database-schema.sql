-- Claude Learn Database Schema v2.1
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
-- - JSON-based module tracking tables for string-based module IDs
-- - Simplified resource tracking tables for string-based resource IDs
--
-- IMPORTANT: This schema includes both UUID-based tables (for future use) and
-- string-based tables (for current JSON content). The string-based tables have
-- "_json" or "_simple" suffixes.

-- =====================================================
-- 1. EXTENSIONS
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 2. ALL TABLE CREATES (in dependency order)
-- =====================================================

-- Categories table (no dependencies)
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

-- Courses table (depends on categories)
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

-- Modules table (depends on courses)
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

-- User profiles table (depends on auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  is_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User favorite categories (depends on profiles and categories)
CREATE TABLE user_favorite_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category_id)
);

-- User favorite categories (simplified for string slugs, depends on profiles)
CREATE TABLE user_favorite_categories_simple (
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_slug VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, category_slug)
);

-- Module progress (depends on profiles and modules)
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

-- Section progress (depends on profiles and modules)
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

-- Quiz attempts (depends on profiles and modules)
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

-- Quiz answers (depends on quiz_attempts)
CREATE TABLE quiz_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_index INTEGER NOT NULL,
  selected_answer INTEGER NOT NULL,
  is_correct BOOLEAN NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Content sync history (depends on profiles)
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

-- User notifications (depends on profiles, categories, and modules)
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

-- Course resources table (depends on courses)
CREATE TABLE course_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  resource_id VARCHAR(100) NOT NULL, -- ID from resources.json
  type VARCHAR(50) NOT NULL, -- cheat-sheet, links, glossary, etc.
  title VARCHAR(255) NOT NULL,
  description TEXT,
  path VARCHAR(255) NOT NULL, -- Path to resource file
  icon VARCHAR(50),
  tags TEXT[] DEFAULT '{}',
  metadata JSONB DEFAULT '{}',
  view_count INTEGER DEFAULT 0,
  last_viewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(course_id, resource_id)
);

-- User favorite resources (depends on profiles, course_resources, and courses)
CREATE TABLE user_favorite_resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES course_resources(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  sort_order INTEGER DEFAULT 0, -- For custom ordering of favorites
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, resource_id)
);

-- User resource views (depends on profiles and course_resources)
CREATE TABLE user_resource_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES course_resources(id) ON DELETE CASCADE,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  view_duration INTEGER, -- Time spent in seconds
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create sync_log table (no dependencies)
CREATE TABLE IF NOT EXISTS sync_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sync_type VARCHAR(50) NOT NULL,
  status VARCHAR(50) NOT NULL,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- JSON-BASED MODULE TRACKING TABLES
-- These tables support module progress tracking using string slugs
-- instead of UUIDs for JSON-based content
-- =====================================================

-- Module progress for JSON modules (depends on profiles)
CREATE TABLE module_progress_json (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_slug VARCHAR(100) NOT NULL,
  course_slug VARCHAR(100) NOT NULL,
  module_slug VARCHAR(100) NOT NULL,
  status VARCHAR(50) DEFAULT 'not_started', -- not_started, started, in_progress, completed
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  current_section INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category_slug, course_slug, module_slug)
);

-- Section progress for JSON modules (depends on profiles)
CREATE TABLE section_progress_json (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_slug VARCHAR(100) NOT NULL,
  course_slug VARCHAR(100) NOT NULL,
  module_slug VARCHAR(100) NOT NULL,
  section_index INTEGER NOT NULL,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  time_spent INTEGER DEFAULT 0, -- in seconds
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, category_slug, course_slug, module_slug, section_index)
);

-- Quiz attempts for JSON modules (depends on profiles)
CREATE TABLE quiz_attempts_json (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  category_slug VARCHAR(100) NOT NULL,
  course_slug VARCHAR(100) NOT NULL,
  module_slug VARCHAR(100) NOT NULL,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  passed BOOLEAN NOT NULL,
  time_taken INTEGER, -- in seconds
  attempt_number INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User favorite resources (simplified for string IDs, depends on profiles)
CREATE TABLE user_favorite_resources_simple (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id VARCHAR(100) NOT NULL,
  resource_id VARCHAR(100) NOT NULL,
  is_favorited BOOLEAN DEFAULT true,
  favorited_at TIMESTAMP WITH TIME ZONE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id, resource_id)
);

-- User resource views (simplified for string IDs, depends on profiles)
CREATE TABLE user_resource_views_simple (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  course_id VARCHAR(100) NOT NULL,
  resource_id VARCHAR(100) NOT NULL,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  view_count INTEGER DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id, resource_id)
);

-- =====================================================
-- 3. ALL INDEXES
-- =====================================================

-- Indexes for core tables
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
CREATE INDEX idx_user_favorite_categories_simple_user ON user_favorite_categories_simple(user_id);
CREATE INDEX idx_user_favorite_categories_simple_slug ON user_favorite_categories_simple(category_slug);
CREATE INDEX idx_user_notifications_user ON user_notifications(user_id, is_read);
CREATE INDEX idx_content_sync_admin ON content_sync_history(admin_id);
CREATE INDEX idx_course_resources_course ON course_resources(course_id);
CREATE INDEX idx_course_resources_type ON course_resources(type);
CREATE INDEX idx_user_favorite_resources_user ON user_favorite_resources(user_id);
CREATE INDEX idx_user_favorite_resources_resource ON user_favorite_resources(resource_id);
CREATE INDEX idx_user_resource_views_user ON user_resource_views(user_id);
CREATE INDEX idx_user_resource_views_resource ON user_resource_views(resource_id);
CREATE INDEX idx_user_resource_views_viewed_at ON user_resource_views(viewed_at DESC);

-- Indexes for JSON-based tables
CREATE INDEX idx_module_progress_json_user ON module_progress_json(user_id);
CREATE INDEX idx_module_progress_json_module ON module_progress_json(category_slug, course_slug, module_slug);
CREATE INDEX idx_section_progress_json_user ON section_progress_json(user_id);
CREATE INDEX idx_quiz_attempts_json_user ON quiz_attempts_json(user_id);
CREATE INDEX idx_user_favorite_resources_simple_user ON user_favorite_resources_simple(user_id);
CREATE INDEX idx_user_favorite_resources_simple_course ON user_favorite_resources_simple(course_id);
CREATE INDEX idx_user_resource_views_simple_user ON user_resource_views_simple(user_id);
CREATE INDEX idx_user_resource_views_simple_course ON user_resource_views_simple(course_id);
CREATE INDEX idx_user_resource_views_simple_viewed_at ON user_resource_views_simple(viewed_at DESC);

-- =====================================================
-- 4. ALL TRIGGERS
-- =====================================================

-- Function for updating timestamps (must be created before triggers)
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

CREATE TRIGGER update_course_resources_updated_at BEFORE UPDATE ON course_resources
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_module_progress_json_updated_at BEFORE UPDATE ON module_progress_json
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_section_progress_json_updated_at BEFORE UPDATE ON section_progress_json
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_favorite_resources_simple_updated_at BEFORE UPDATE ON user_favorite_resources_simple
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_resource_views_simple_updated_at BEFORE UPDATE ON user_resource_views_simple
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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

-- =====================================================
-- 5. ENABLE RLS ON ALL TABLES
-- =====================================================

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorite_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorite_categories_simple ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE section_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_sync_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorite_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_resource_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_progress_json ENABLE ROW LEVEL SECURITY;
ALTER TABLE section_progress_json ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts_json ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorite_resources_simple ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_resource_views_simple ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 6. ALL RLS POLICIES
-- =====================================================

-- Categories (public read)
CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (is_active = true);

-- Courses (public read for active courses)
CREATE POLICY "Active courses are viewable by everyone" ON courses
  FOR SELECT USING (is_active = true);

-- Modules (public read for active modules)
CREATE POLICY "Active modules are viewable by everyone" ON modules
  FOR SELECT USING (is_active = true);

-- User favorite categories
CREATE POLICY "Users can view own favorites" ON user_favorite_categories
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites" ON user_favorite_categories
  FOR ALL USING (auth.uid() = user_id);

-- User favorite categories simple
CREATE POLICY "Users can view own favorites simple" ON user_favorite_categories_simple
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites simple" ON user_favorite_categories_simple
  FOR ALL USING (auth.uid() = user_id);

-- Profiles
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Module progress
CREATE POLICY "Users can view own progress" ON module_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own progress" ON module_progress
  FOR ALL USING (auth.uid() = user_id);

-- Section progress
CREATE POLICY "Users can view own section progress" ON section_progress
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own section progress" ON section_progress
  FOR ALL USING (auth.uid() = user_id);

-- Quiz attempts
CREATE POLICY "Users can view own quiz attempts" ON quiz_attempts
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own quiz attempts" ON quiz_attempts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Quiz answers
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
CREATE POLICY "Users can view own notifications" ON user_notifications
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON user_notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Content sync history (admin only)
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

-- RLS Policies for course_resources (public read, admin write)
CREATE POLICY "Course resources are viewable by everyone" ON course_resources
  FOR SELECT USING (true);

CREATE POLICY "Only admins can manage course resources" ON course_resources
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- RLS Policies for user_favorite_resources
CREATE POLICY "Users can view own favorite resources" ON user_favorite_resources
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own favorite resources" ON user_favorite_resources
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies for user_resource_views
CREATE POLICY "Users can view own resource views" ON user_resource_views
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own resource views" ON user_resource_views
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all resource analytics" ON user_resource_views
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- RLS Policies for module_progress_json
CREATE POLICY "Users can view own module progress json" ON module_progress_json
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own module progress json" ON module_progress_json
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own module progress json" ON module_progress_json
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own module progress json" ON module_progress_json
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for section_progress_json
CREATE POLICY "Users can view own section progress json" ON section_progress_json
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own section progress json" ON section_progress_json
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own section progress json" ON section_progress_json
  FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own section progress json" ON section_progress_json
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for quiz_attempts_json
CREATE POLICY "Users can view own quiz attempts json" ON quiz_attempts_json
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own quiz attempts json" ON quiz_attempts_json
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for user_favorite_resources_simple
CREATE POLICY "Users can view own favorite resources simple" ON user_favorite_resources_simple
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own favorite resources simple" ON user_favorite_resources_simple
  FOR ALL USING (auth.uid() = user_id);

-- RLS Policies for user_resource_views_simple
CREATE POLICY "Users can view own resource views simple" ON user_resource_views_simple
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own resource views simple" ON user_resource_views_simple
  FOR ALL USING (auth.uid() = user_id);

-- Admin policies for JSON tables
CREATE POLICY "Admins can view all module progress json" ON module_progress_json
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can view all quiz attempts json" ON quiz_attempts_json
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.is_admin = true
    )
  );

CREATE POLICY "Admins can view all resource analytics simple" ON user_resource_views_simple
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

-- =====================================================
-- 7. ALL FUNCTIONS
-- =====================================================

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
-- REMOVED: Overall progress is no longer needed as the platform is a resource tool
-- rather than a completion-based training system. Users aren't expected to complete
-- all courses or modules.
--
-- CREATE OR REPLACE FUNCTION get_user_overall_progress(p_user_id UUID)
-- RETURNS TABLE(
--   total_categories INTEGER,
--   total_courses INTEGER,
--   total_modules INTEGER,
--   completed_modules INTEGER,
--   in_progress_modules INTEGER,
--   favorite_categories INTEGER,
--   overall_percentage INTEGER
-- ) AS $$
-- BEGIN
--   RETURN QUERY
--   SELECT 
--     (SELECT COUNT(*)::INTEGER FROM categories WHERE is_active = true) as total_categories,
--     (SELECT COUNT(*)::INTEGER FROM courses WHERE is_active = true) as total_courses,
--     (SELECT COUNT(*)::INTEGER FROM modules WHERE is_active = true) as total_modules,
--     (SELECT COUNT(*)::INTEGER FROM module_progress WHERE user_id = p_user_id AND status = 'completed') as completed_modules,
--     (SELECT COUNT(*)::INTEGER FROM module_progress WHERE user_id = p_user_id AND status = 'in_progress') as in_progress_modules,
--     (SELECT COUNT(*)::INTEGER FROM user_favorite_categories WHERE user_id = p_user_id) as favorite_categories,
--     CASE 
--       WHEN (SELECT COUNT(*) FROM modules WHERE is_active = true) > 0 
--       THEN ((SELECT COUNT(*) FROM module_progress WHERE user_id = p_user_id AND status = 'completed') * 100 / 
--             (SELECT COUNT(*) FROM modules WHERE is_active = true))::INTEGER
--       ELSE 0
--     END as overall_percentage;
-- END;
-- $$ LANGUAGE plpgsql;

-- Helper function to get user's favorite resources
CREATE OR REPLACE FUNCTION get_user_favorite_resources(p_user_id UUID)
RETURNS TABLE(
  resource_id UUID,
  course_id UUID,
  type VARCHAR(50),
  title VARCHAR(255),
  description TEXT,
  icon VARCHAR(50),
  path VARCHAR(255),
  sort_order INTEGER,
  favorited_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cr.id as resource_id,
    cr.course_id,
    cr.type,
    cr.title,
    cr.description,
    cr.icon,
    cr.path,
    ufr.sort_order,
    ufr.created_at as favorited_at
  FROM user_favorite_resources ufr
  INNER JOIN course_resources cr ON ufr.resource_id = cr.id
  WHERE ufr.user_id = p_user_id
  ORDER BY ufr.sort_order, ufr.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Helper function to get recently viewed resources
CREATE OR REPLACE FUNCTION get_user_recent_resources(p_user_id UUID, p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
  resource_id UUID,
  course_id UUID,
  type VARCHAR(50),
  title VARCHAR(255),
  description TEXT,
  icon VARCHAR(50),
  path VARCHAR(255),
  last_viewed TIMESTAMP WITH TIME ZONE,
  view_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cr.id as resource_id,
    cr.course_id,
    cr.type,
    cr.title,
    cr.description,
    cr.icon,
    cr.path,
    MAX(urv.viewed_at) as last_viewed,
    COUNT(urv.id) as view_count
  FROM user_resource_views urv
  INNER JOIN course_resources cr ON urv.resource_id = cr.id
  WHERE urv.user_id = p_user_id
  GROUP BY cr.id, cr.course_id, cr.type, cr.title, cr.description, cr.icon, cr.path
  ORDER BY MAX(urv.viewed_at) DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Helper function to track resource view
CREATE OR REPLACE FUNCTION track_resource_view(
  p_user_id UUID,
  p_resource_id UUID,
  p_duration INTEGER DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
  -- Insert view record
  INSERT INTO user_resource_views (user_id, resource_id, view_duration)
  VALUES (p_user_id, p_resource_id, p_duration);
  
  -- Update resource view count and last viewed
  UPDATE course_resources
  SET view_count = view_count + 1,
      last_viewed_at = NOW()
  WHERE id = p_resource_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get module progress for JSON modules
CREATE OR REPLACE FUNCTION get_json_module_progress(
  p_user_id UUID,
  p_category_slug VARCHAR,
  p_course_slug VARCHAR
)
RETURNS TABLE(
  module_slug VARCHAR(100),
  status VARCHAR(50),
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  current_section INTEGER,
  last_accessed_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mpj.module_slug,
    mpj.status,
    mpj.started_at,
    mpj.completed_at,
    mpj.current_section,
    mpj.last_accessed_at
  FROM module_progress_json mpj
  WHERE mpj.user_id = p_user_id
    AND mpj.category_slug = p_category_slug
    AND mpj.course_slug = p_course_slug
  ORDER BY mpj.last_accessed_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to get resource analytics for string-based resources
CREATE OR REPLACE FUNCTION get_resource_analytics(course_id_param VARCHAR)
RETURNS TABLE(
  resource_id VARCHAR(100),
  total_views BIGINT,
  unique_viewers BIGINT,
  last_viewed TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    urv.resource_id,
    SUM(urv.view_count)::BIGINT as total_views,
    COUNT(DISTINCT urv.user_id)::BIGINT as unique_viewers,
    MAX(urv.viewed_at) as last_viewed
  FROM user_resource_views_simple urv
  WHERE urv.course_id = course_id_param
  GROUP BY urv.resource_id;
END;
$$ LANGUAGE plpgsql;

-- Function to get popular resources (string-based)
CREATE OR REPLACE FUNCTION get_popular_resources(limit_param INTEGER DEFAULT 10)
RETURNS TABLE(
  course_id VARCHAR(100),
  resource_id VARCHAR(100),
  type VARCHAR(50),
  title VARCHAR(255),
  description TEXT,
  icon VARCHAR(50),
  total_views BIGINT,
  unique_viewers BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    urv.course_id,
    urv.resource_id,
    cr.type,
    cr.title,
    cr.description,
    cr.icon,
    SUM(urv.view_count)::BIGINT as total_views,
    COUNT(DISTINCT urv.user_id)::BIGINT as unique_viewers
  FROM user_resource_views_simple urv
  LEFT JOIN course_resources cr ON cr.resource_id = urv.resource_id AND cr.course_id::VARCHAR = urv.course_id
  GROUP BY urv.course_id, urv.resource_id, cr.type, cr.title, cr.description, cr.icon
  ORDER BY SUM(urv.view_count) DESC
  LIMIT limit_param;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. ALL GRANTS
-- =====================================================

-- Grant permissions for JSON tables
GRANT ALL ON module_progress_json TO authenticated;
GRANT ALL ON section_progress_json TO authenticated;
GRANT ALL ON quiz_attempts_json TO authenticated;
GRANT ALL ON user_favorite_categories_simple TO authenticated;
GRANT ALL ON user_favorite_resources_simple TO authenticated;
GRANT ALL ON user_resource_views_simple TO authenticated;

-- =====================================================
-- Helper query to create missing profile for existing users
-- Run this after initial setup if you have existing users
-- =====================================================
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