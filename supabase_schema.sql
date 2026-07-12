-- ============================================================================
-- VITALI — Complete Database Schema
-- ============================================================================
-- This file is the SINGLE SOURCE OF TRUTH for the entire Supabase data model.
-- Run this in the Supabase SQL Editor to bootstrap a fresh project.
--
-- Tables (in dependency order):
--   1. emotion_entries         — Daily emotion tracking (calendar)
--   2. diary_entries           — Personal journal (4 free-text fields per day)
--   3. daily_tasks             — Simple daily to-do list (legacy module)
--   4. organizer_tasks         — Eisenhower-matrix task organizer
--   5. user_points_history     — Gamification points ledger
--   6. user_sessions           — Login/logout session tracking
--   7. emergency_clicks        — SOS button usage counter
--   8. yoga_practice_history   — Yoga session counter per day
--   9. module_access_logs      — Per-module visit counter (analytics)
--  10. meditation_sessions     — Meditation session counter by duration
--  11. meditation_feedback     — Post-meditation experience survey
--  12. recommended_videos      — Admin-curated video recommendations
-- ============================================================================

-- ── Timezone: all DEFAULT now() columns will use America/Lima ──
ALTER DATABASE postgres SET timezone TO 'America/Lima';
SET timezone = 'America/Lima';

-- ──────────────────────────────────────────────
-- 1. emotion_entries
-- ──────────────────────────────────────────────
-- One emotion per user per day. Used by the emotion calendar feature.
CREATE TABLE IF NOT EXISTS public.emotion_entries (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  emotion text NOT NULL,
  -- enum name: happy, sad, angry, anxious, neutral, etc.
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT emotion_entries_user_date_uq UNIQUE (user_id, entry_date)
);
CREATE INDEX IF NOT EXISTS emotion_entries_user_id_idx ON public.emotion_entries (user_id);
CREATE INDEX IF NOT EXISTS emotion_entries_user_date_idx ON public.emotion_entries (user_id, entry_date);
ALTER TABLE public.emotion_entries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS emotion_entries_user_policy ON public.emotion_entries;
CREATE POLICY emotion_entries_user_policy ON public.emotion_entries FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 2. diary_entries
-- ──────────────────────────────────────────────
-- One journal entry per user per day with 4 structured text fields.
CREATE TABLE IF NOT EXISTS public.diary_entries (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  porque text DEFAULT '',
  meta text DEFAULT '',
  prioridades text DEFAULT '',
  logros text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT diary_entries_user_date_uq UNIQUE (user_id, entry_date)
);
CREATE INDEX IF NOT EXISTS diary_entries_user_id_idx ON public.diary_entries (user_id);
CREATE INDEX IF NOT EXISTS diary_entries_user_date_idx ON public.diary_entries (user_id, entry_date);
ALTER TABLE public.diary_entries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS diary_entries_user_policy ON public.diary_entries;
CREATE POLICY diary_entries_user_policy ON public.diary_entries FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 3. daily_tasks
-- ──────────────────────────────────────────────
-- Simple to-do items per day (legacy emotions module).
CREATE TABLE IF NOT EXISTS public.daily_tasks (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  title text NOT NULL,
  is_done boolean DEFAULT false,
  position smallint DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS daily_tasks_user_id_idx ON public.daily_tasks (user_id);
CREATE INDEX IF NOT EXISTS daily_tasks_user_date_idx ON public.daily_tasks (user_id, entry_date);
ALTER TABLE public.daily_tasks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS daily_tasks_user_policy ON public.daily_tasks;
CREATE POLICY daily_tasks_user_policy ON public.daily_tasks FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 4. organizer_tasks
-- ──────────────────────────────────────────────
-- Eisenhower-matrix tasks with time, dimension (1-4), and optional notes.
CREATE TABLE IF NOT EXISTS public.organizer_tasks (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entry_date date NOT NULL,
  title text NOT NULL,
  task_time text NOT NULL DEFAULT '08:00',
  dimension integer NOT NULL DEFAULT 1,
  -- 1=Urgent+Important … 4=Not urgent+Not important
  notes text DEFAULT '',
  is_completed boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS organizer_tasks_user_id_idx ON public.organizer_tasks (user_id);
CREATE INDEX IF NOT EXISTS organizer_tasks_user_date_idx ON public.organizer_tasks (user_id, entry_date);
ALTER TABLE public.organizer_tasks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS organizer_tasks_user_policy ON public.organizer_tasks;
CREATE POLICY organizer_tasks_user_policy ON public.organizer_tasks FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 5. user_points_history
-- ──────────────────────────────────────────────
-- Gamification ledger: one reward entry per reason per day prevents duplicates.
CREATE TABLE IF NOT EXISTS public.user_points_history (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  earned_date date NOT NULL,
  points integer NOT NULL DEFAULT 0,
  reason text NOT NULL,
  -- e.g. 'task_completion'
  created_at timestamptz DEFAULT now(),
  CONSTRAINT user_points_user_date_reason_uq UNIQUE (user_id, earned_date, reason)
);
CREATE INDEX IF NOT EXISTS user_points_history_user_id_idx ON public.user_points_history (user_id);
ALTER TABLE public.user_points_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_points_history_user_policy ON public.user_points_history;
CREATE POLICY user_points_history_user_policy ON public.user_points_history FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 6. user_sessions
-- ──────────────────────────────────────────────
-- Tracks login/logout timestamps and periodic keep-alive pings.
CREATE TABLE IF NOT EXISTS public.user_sessions (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  login_at timestamptz NOT NULL DEFAULT now(),
  logout_at timestamptz,
  last_ping_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS user_sessions_user_id_idx ON public.user_sessions (user_id);
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS user_sessions_user_policy ON public.user_sessions;
CREATE POLICY user_sessions_user_policy ON public.user_sessions FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 7. emergency_clicks
-- ──────────────────────────────────────────────
-- Counts how many times a user presses the SOS/emergency button per day.
CREATE TABLE IF NOT EXISTS public.emergency_clicks (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  click_date date NOT NULL,
  times_clicked integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT emergency_clicks_user_date_uq UNIQUE (user_id, click_date)
);
CREATE INDEX IF NOT EXISTS emergency_clicks_user_id_idx ON public.emergency_clicks (user_id);
CREATE INDEX IF NOT EXISTS emergency_clicks_user_date_idx ON public.emergency_clicks (user_id, click_date);
ALTER TABLE public.emergency_clicks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS emergency_clicks_user_policy ON public.emergency_clicks;
CREATE POLICY emergency_clicks_user_policy ON public.emergency_clicks FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 8. yoga_practice_history
-- ──────────────────────────────────────────────
-- Counts how many yoga practices a user completed per day.
CREATE TABLE IF NOT EXISTS public.yoga_practice_history (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  practice_date date NOT NULL,
  times_practiced integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT yoga_practice_user_date_uq UNIQUE (user_id, practice_date)
);
CREATE INDEX IF NOT EXISTS yoga_practice_history_user_id_idx ON public.yoga_practice_history (user_id);
ALTER TABLE public.yoga_practice_history ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS yoga_practice_history_user_policy ON public.yoga_practice_history;
CREATE POLICY yoga_practice_history_user_policy ON public.yoga_practice_history FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 9. module_access_logs
-- ──────────────────────────────────────────────
-- Tracks how many times a user enters each module per day.
CREATE TABLE IF NOT EXISTS public.module_access_logs (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  access_date date NOT NULL,
  module_name text NOT NULL,
  times_accessed integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT module_access_logs_user_date_mod_uq UNIQUE (user_id, access_date, module_name)
);
CREATE INDEX IF NOT EXISTS module_access_logs_user_id_idx ON public.module_access_logs (user_id);
ALTER TABLE public.module_access_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS module_access_logs_user_policy ON public.module_access_logs;
CREATE POLICY module_access_logs_user_policy ON public.module_access_logs FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 10. meditation_sessions
-- ──────────────────────────────────────────────
-- Counts meditation sessions grouped by duration (1, 3, 5 min) per day.
CREATE TABLE IF NOT EXISTS public.meditation_sessions (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_date date NOT NULL,
  duration_minutes integer NOT NULL,
  times_meditated integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT meditation_sessions_user_date_dur_uq UNIQUE (user_id, session_date, duration_minutes)
);
CREATE INDEX IF NOT EXISTS meditation_sessions_user_id_idx ON public.meditation_sessions (user_id);
ALTER TABLE public.meditation_sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS meditation_sessions_user_policy ON public.meditation_sessions;
CREATE POLICY meditation_sessions_user_policy ON public.meditation_sessions FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 11. meditation_feedback
-- ──────────────────────────────────────────────
-- Post-meditation survey: how was the experience and how does the user feel.
CREATE TABLE IF NOT EXISTS public.meditation_feedback (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  duration_minutes integer NOT NULL,
  experience text NOT NULL,
  -- e.g. 'relaxing', 'difficult', 'neutral'
  feeling text NOT NULL,
  -- e.g. 'calm', 'energized', 'sleepy'
  created_at timestamptz DEFAULT now()
);
CREATE INDEX IF NOT EXISTS meditation_feedback_user_id_idx ON public.meditation_feedback (user_id);
ALTER TABLE public.meditation_feedback ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS meditation_feedback_user_policy ON public.meditation_feedback;
CREATE POLICY meditation_feedback_user_policy ON public.meditation_feedback FOR ALL TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- ──────────────────────────────────────────────
-- 12. recommended_videos
-- ──────────────────────────────────────────────
-- Admin-curated list of recommended video resources (read-only for users).
CREATE TABLE IF NOT EXISTS public.recommended_videos (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title text NOT NULL,
  url text NOT NULL,
  thumbnail text,
  order_index integer DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.recommended_videos ENABLE ROW LEVEL SECURITY;
-- Users can read but not modify. Admins manage via Supabase Dashboard.
DROP POLICY IF EXISTS recommended_videos_read_policy ON public.recommended_videos;
CREATE POLICY recommended_videos_read_policy ON public.recommended_videos FOR SELECT TO authenticated USING (true);


-- ──────────────────────────────────────────────
-- 13. forum_posts
-- ──────────────────────────────────────────────
-- User posts in the community forum.
CREATE TABLE IF NOT EXISTS public.forum_posts (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     uuid         REFERENCES auth.users(id) ON DELETE SET NULL,
  author_name text         NOT NULL,
  content     text         NOT NULL,
  likes_count integer      DEFAULT 0,
  created_at  timestamptz  DEFAULT now(),
  updated_at  timestamptz  DEFAULT now()
);

CREATE INDEX IF NOT EXISTS forum_posts_created_idx ON public.forum_posts (created_at DESC);

ALTER TABLE public.forum_posts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS forum_posts_read_policy ON public.forum_posts;
CREATE POLICY forum_posts_read_policy ON public.forum_posts FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS forum_posts_insert_policy ON public.forum_posts;
CREATE POLICY forum_posts_insert_policy ON public.forum_posts FOR INSERT TO authenticated WITH CHECK (true);


-- ──────────────────────────────────────────────
-- 14. forum_post_likes
-- ──────────────────────────────────────────────
-- Tracks unique likes to prevent spam.
CREATE TABLE IF NOT EXISTS public.forum_post_likes (
  post_id    bigint  REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  user_id    uuid    REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (post_id, user_id)
);

ALTER TABLE public.forum_post_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS forum_likes_read_policy ON public.forum_post_likes;
CREATE POLICY forum_likes_read_policy ON public.forum_post_likes FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS forum_likes_insert_policy ON public.forum_post_likes;
CREATE POLICY forum_likes_insert_policy ON public.forum_post_likes FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS forum_likes_delete_policy ON public.forum_post_likes;
CREATE POLICY forum_likes_delete_policy ON public.forum_post_likes FOR DELETE TO authenticated USING (user_id = auth.uid());


-- ──────────────────────────────────────────────
-- 15. forum_replies
-- ──────────────────────────────────────────────
-- Replies/comments to forum posts (e.g. from administrators or other users).
CREATE TABLE IF NOT EXISTS public.forum_replies (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id     bigint       NOT NULL REFERENCES public.forum_posts(id) ON DELETE CASCADE,
  user_id     uuid         REFERENCES auth.users(id) ON DELETE SET NULL,
  author_name text         NOT NULL,
  content     text         NOT NULL,
  is_admin    boolean      DEFAULT false,
  created_at  timestamptz  DEFAULT now()
);

CREATE INDEX IF NOT EXISTS forum_replies_post_idx ON public.forum_replies (post_id);

ALTER TABLE public.forum_replies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS forum_replies_read_policy ON public.forum_replies;
CREATE POLICY forum_replies_read_policy ON public.forum_replies FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS forum_replies_insert_policy ON public.forum_replies;
CREATE POLICY forum_replies_insert_policy ON public.forum_replies FOR INSERT TO authenticated WITH CHECK (true);


-- ──────────────────────────────────────────────
-- RPC: Admin Forum Functions
-- ──────────────────────────────────────────────

-- Retrieves all forum posts and their nested replies as JSON.
-- Bypasses normal user RLS checks because it executes as SECURITY DEFINER (superuser/creator role)
-- and authenticates via admin_pass parameter.
CREATE OR REPLACE FUNCTION public.get_admin_forum_posts(
  admin_pass text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  posts_json json;
BEGIN
  IF admin_pass <> 'admin123' THEN
    RETURN json_build_object('success', false, 'error', 'Invalid admin password');
  END IF;

  SELECT coalesce(json_agg(t), '[]'::json) INTO posts_json
  FROM (
    SELECT 
      p.id,
      p.author_name,
      p.content,
      p.likes_count,
      p.created_at,
      (
        SELECT coalesce(json_agg(r), '[]'::json)
        FROM (
          SELECT id, author_name, content, is_admin, created_at
          FROM public.forum_replies
          WHERE post_id = p.id
          ORDER BY created_at ASC
        ) r
      ) as replies
    FROM public.forum_posts p
    ORDER BY p.created_at DESC
  ) t;

  RETURN json_build_object('success', true, 'posts', posts_json);
END;
$$;


-- Submits a reply to a forum post as "Titi".
-- Bypasses normal RLS because it executes as SECURITY DEFINER,
-- authenticating via admin_pass.
CREATE OR REPLACE FUNCTION public.reply_to_forum_post_as_admin(
  admin_pass text,
  target_post_id bigint,
  reply_content text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF admin_pass <> 'admin123' THEN
    RETURN json_build_object('success', false, 'error', 'Invalid admin password');
  END IF;

  INSERT INTO public.forum_replies (post_id, author_name, content, is_admin)
  VALUES (target_post_id, 'Titi', reply_content, true);

  RETURN json_build_object('success', true);
END;
$$;