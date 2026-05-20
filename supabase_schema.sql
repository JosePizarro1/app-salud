-- ==========================================
-- SCHEMA FOR DIARIO PERSONAL & LISTA DE TAREAS
-- Run this in your Supabase SQL Editor
-- ==========================================

-- 1. Create diary_entries table
CREATE TABLE IF NOT EXISTS public.diary_entries (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  porque     text DEFAULT '',
  meta       text DEFAULT '',
  prioridades text DEFAULT '',
  logros     text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  CONSTRAINT diary_entries_user_date_uq UNIQUE (user_id, entry_date)
);

-- Index foreign keys and search criteria for query performance
CREATE INDEX IF NOT EXISTS diary_entries_user_id_idx ON public.diary_entries (user_id);
CREATE INDEX IF NOT EXISTS diary_entries_user_date_idx ON public.diary_entries (user_id, entry_date);

-- Enable RLS
ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;

-- RLS Policy for diary_entries
CREATE POLICY diary_entries_user_policy ON public.diary_entries
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());


-- 2. Create daily_tasks table (Empty by default)
CREATE TABLE IF NOT EXISTS public.daily_tasks (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  title      text NOT NULL,
  is_done    boolean DEFAULT false,
  position   smallint DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Index foreign keys and search criteria for query performance
CREATE INDEX IF NOT EXISTS daily_tasks_user_id_idx ON public.daily_tasks (user_id);
CREATE INDEX IF NOT EXISTS daily_tasks_user_date_idx ON public.daily_tasks (user_id, entry_date);

-- Enable RLS
ALTER TABLE public.daily_tasks ENABLE ROW LEVEL SECURITY;

-- RLS Policy for daily_tasks
CREATE POLICY daily_tasks_user_policy ON public.daily_tasks
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
