-- Remove Overall Progress Function
-- This function is no longer needed as users aren't expected to complete all courses
-- The platform is now a resource tool rather than a completion-based training system

-- Drop the overall progress function
DROP FUNCTION IF EXISTS get_user_overall_progress(UUID);

-- Note: The following tables and functions are still useful and should be kept:
-- - get_course_progress: Still useful for individual course tracking
-- - get_category_progress: Still useful for category-level insights
-- - module_progress tables: Still needed for tracking individual module completion
-- - quiz_attempts: Still needed for quiz functionality