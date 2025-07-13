-- Safe Reset Database Script
-- WARNING: This will DELETE ALL DATA in the public schema! 
-- Run this before running database-schema.sql to start fresh
-- This script dynamically finds and drops all objects, so it won't fail if objects don't exist

-- Start transaction
BEGIN;

-- 1. Drop all RLS policies dynamically
DO $$ 
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            pol.policyname, pol.schemaname, pol.tablename);
        RAISE NOTICE 'Dropped policy: % on %.%', 
            pol.policyname, pol.schemaname, pol.tablename;
    END LOOP;
END $$;

-- 2. Drop all triggers on user tables (except system triggers)
DO $$ 
DECLARE
    trig RECORD;
BEGIN
    FOR trig IN 
        SELECT DISTINCT trigger_name, event_object_schema, event_object_table 
        FROM information_schema.triggers 
        WHERE trigger_schema = 'public' 
        AND event_object_schema = 'public'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I.%I', 
            trig.trigger_name, trig.event_object_schema, trig.event_object_table);
        RAISE NOTICE 'Dropped trigger: % on %.%', 
            trig.trigger_name, trig.event_object_schema, trig.event_object_table;
    END LOOP;
END $$;

-- 3. Drop trigger on auth.users if it exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 4. Drop all functions in public schema
DO $$ 
DECLARE
    func RECORD;
BEGIN
    FOR func IN 
        SELECT proname, oidvectortypes(proargtypes) as argtypes 
        FROM pg_proc 
        WHERE pronamespace = 'public'::regnamespace
        AND prokind = 'f'
    LOOP
        EXECUTE format('DROP FUNCTION IF EXISTS public.%I(%s) CASCADE', 
            func.proname, func.argtypes);
        RAISE NOTICE 'Dropped function: public.%(%)', func.proname, func.argtypes;
    END LOOP;
END $$;

-- 5. Drop all views in public schema
DO $$ 
DECLARE
    view_rec RECORD;
BEGIN
    FOR view_rec IN 
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'public'
    LOOP
        EXECUTE format('DROP VIEW IF EXISTS public.%I CASCADE', view_rec.table_name);
        RAISE NOTICE 'Dropped view: public.%', view_rec.table_name;
    END LOOP;
END $$;

-- 6. Drop all tables in public schema (CASCADE will handle foreign keys)
DO $$ 
DECLARE
    tbl RECORD;
BEGIN
    -- First, drop tables with foreign key dependencies in correct order
    EXECUTE 'DROP TABLE IF EXISTS public.user_resource_views CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS public.user_favorite_resources CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS public.course_resources CASCADE';
    
    -- Then drop all remaining tables
    FOR tbl IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format('DROP TABLE IF EXISTS public.%I CASCADE', tbl.table_name);
        RAISE NOTICE 'Dropped table: public.%', tbl.table_name;
    END LOOP;
END $$;

-- 7. Drop all custom types in public schema
DO $$ 
DECLARE
    typ RECORD;
BEGIN
    FOR typ IN 
        SELECT typname 
        FROM pg_type 
        WHERE typnamespace = 'public'::regnamespace 
        AND typtype = 'e'
    LOOP
        EXECUTE format('DROP TYPE IF EXISTS public.%I CASCADE', typ.typname);
        RAISE NOTICE 'Dropped type: public.%', typ.typname;
    END LOOP;
END $$;

-- Commit transaction
COMMIT;

-- Success message
DO $$ 
BEGIN 
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Database reset completed successfully!';
    RAISE NOTICE 'All tables, policies, triggers, and functions in the public schema have been dropped.';
    RAISE NOTICE 'You can now run database-schema.sql to recreate everything.';
    RAISE NOTICE '==============================================';
END $$;