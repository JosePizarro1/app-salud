# Project Context - Health App (Vitali/Salud)

## Supabase Information
- **Project ID**: `jwwxeengyrkmoxpggsrz`
- **Main Tables**:
  - `public.users`: Profiles with `full_name` and `student_code`.
  - `public.emotion_entries`: Emotional registry (one per user per day).
  - `public.diary_entries`: Daily personal diary entries (responses to prompt questions).
  - `public.daily_tasks`: Daily customizable tasks and self-care list (empty by default).
- **Authentication**: Using `@unjbg.edu.pe` as a standard institution domain.

## Key Features
- **Module 3**: Mental wellness module (emotions, breathing, meditation).
- **Emotional Registry**: 
  - 6 Emotions: `happy`, `relaxed`, `sad`, `anxious`, `stressed`, `overwhelmed`.
  - Monthly calendar tracking with local persistence (moving to Supabase).

## Design System
- **Colors**: Centralized in `lib/app/theme/app_colors.dart`.
- **Assets**: Case-sensitive paths (mostly `.png` and `.gif` in lowercase).
- **Header**: `ModuleHeader` widget (Home + Emergency buttons).

## Active Components
- **GoRouter**: Navigation management in `lib/app/router.dart`.
- **AnimateDo**: UI animations.
- **Supabase Flutter**: Backend connection.
