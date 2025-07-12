-- Fix for RLS Policy Infinite Recursion
-- Run this in Supabase SQL Editor to fix the recursion issue

-- First, drop all existing policies to start fresh
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;

DROP POLICY IF EXISTS "Users can manage own module progress" ON module_progress;
DROP POLICY IF EXISTS "Admins can view all module progress" ON module_progress;

DROP POLICY IF EXISTS "Users can manage own section progress" ON section_progress;
DROP POLICY IF EXISTS "Admins can view all section progress" ON section_progress;

DROP POLICY IF EXISTS "Users can manage own quiz attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Admins can view all quiz attempts" ON quiz_attempts;

DROP POLICY IF EXISTS "Users can manage own quiz answers" ON quiz_answers;
DROP POLICY IF EXISTS "Admins can view all quiz answers" ON quiz_answers;

-- Create simplified policies without recursion

-- Profiles policies (NO admin checks to avoid recursion)
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Module progress policies
CREATE POLICY "Users can manage own module progress" ON module_progress
  FOR ALL USING (auth.uid() = user_id);

-- Section progress policies
CREATE POLICY "Users can manage own section progress" ON section_progress
  FOR ALL USING (auth.uid() = user_id);

-- Quiz attempts policies
CREATE POLICY "Users can manage own quiz attempts" ON quiz_attempts
  FOR ALL USING (auth.uid() = user_id);

-- Quiz answers policies
CREATE POLICY "Users can manage own quiz answers" ON quiz_answers
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM quiz_attempts 
      WHERE id = quiz_answers.attempt_id AND user_id = auth.uid()
    )
  );

-- Note: Admin policies will be added later via a separate admin user setup
-- For now, this focuses on getting basic user functionality working