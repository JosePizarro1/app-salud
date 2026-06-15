import 'package:go_router/go_router.dart';
import '../features/auth/pages/welcome_splash_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/register_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/home/pages/emergency_page.dart';
import '../features/home/pages/module1_page.dart';
import '../features/home/pages/module2_page.dart';
import '../features/home/pages/module3_page.dart';
import '../features/home/pages/module4_page.dart';
import '../features/home/pages/module5_page.dart';
import '../features/home/pages/module6_page.dart';
import '../features/home/pages/physical_activity_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/emotions/pages/emotions_calendar_page.dart';
import '../features/emotions/pages/meditation_page.dart';
import '../features/games/pages/sudoku_page.dart';
import '../features/home/pages/titi_chat_page.dart';
import '../features/home/pages/active_pause_page.dart';
import '../features/home/pages/active_pause_timer_page.dart';
import '../features/home/pages/relax_page.dart';
import '../features/home/pages/breathing_page.dart';
import '../features/home/pages/box_breathing_page.dart';
import '../features/home/pages/yoga_routine_page.dart';
import '../features/admin/pages/admin_dashboard_page.dart';
import '../features/organizer/pages/organizer_page.dart';
import '../features/organizer/pages/organizer_onboarding_page.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeSplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyPage(),
    ),
    GoRoute(
      path: '/module1',
      builder: (context, state) => const Module1Page(),
    ),
    GoRoute(
      path: '/module2',
      builder: (context, state) => const Module2Page(),
    ),
    GoRoute(
      path: '/module3',
      builder: (context, state) => const Module3Page(),
    ),
    GoRoute(
      path: '/module4',
      builder: (context, state) => const Module4Page(),
    ),
    GoRoute(
      path: '/module5',
      builder: (context, state) => const Module5Page(),
    ),
    GoRoute(
      path: '/module6',
      builder: (context, state) => const Module6Page(),
    ),
    GoRoute(
      path: '/physical_activity',
      builder: (context, state) => const PhysicalActivityPage(),
    ),
    GoRoute(
      path: '/emotions',
      builder: (context, state) => const EmotionsCalendarPage(),
    ),
    GoRoute(
      path: '/meditation',
      builder: (context, state) => const MeditationPage(),
    ),
    GoRoute(
      path: '/sudoku',
      builder: (context, state) => const SudokuPage(),
    ),
    GoRoute(
      path: '/titi_chat',
      builder: (context, state) => const TitiChatPage(),
    ),
    GoRoute(
      path: '/active_pause',
      builder: (context, state) => const ActivePausePage(),
    ),
    GoRoute(
      path: '/active_pause_timer',
      builder: (context, state) {
        final exercise = state.extra as ActivePauseExercise;
        return ActivePauseTimerPage(exercise: exercise);
      },
    ),
    GoRoute(
      path: '/relax',
      builder: (context, state) => const RelaxPage(),
    ),
    GoRoute(
      path: '/breathing',
      builder: (context, state) => const BreathingPage(),
    ),
    GoRoute(
      path: '/box_breathing',
      builder: (context, state) => const BoxBreathingPage(),
    ),
    GoRoute(
      path: '/yoga',
      builder: (context, state) => const YogaRoutinePage(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/organizer',
      builder: (context, state) => const OrganizerPage(),
    ),
    GoRoute(
      path: '/organizer/onboarding',
      builder: (context, state) => const OrganizerOnboardingPage(),
    ),
  ],
);

