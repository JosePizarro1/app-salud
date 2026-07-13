import 'package:flutter/material.dart';
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
import '../features/home/pages/knowing_stress_page.dart';
import '../features/home/pages/healthy_eating_page.dart';
import '../features/home/pages/bmi_calculator_page.dart';
import '../features/home/pages/portions_guide_page.dart';
import '../features/home/pages/knowing_foods_page.dart';
import '../features/home/pages/food_discovery_page.dart';
import '../features/home/pages/study_techniques_page.dart';
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
import '../features/home/pages/playlist_page.dart';
import '../features/home/pages/alarm_page.dart';
import '../features/home/pages/rest_timer_page.dart';
import '../features/home/pages/night_routine_page.dart';
import '../features/home/pages/sleep_care_page.dart';
import '../features/home/pages/sleep_care_reader_page.dart';
import '../features/home/pages/forum_page.dart';

CustomTransitionPage<T> _buildFadePage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

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
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const HomePage()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const SettingsPage()),
    ),
    GoRoute(
      path: '/emergency',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const EmergencyPage()),
    ),
    GoRoute(
      path: '/module1',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const Module1Page()),
    ),
    GoRoute(
      path: '/module2',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const Module2Page()),
    ),
    GoRoute(
      path: '/module3',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const Module3Page()),
    ),
    GoRoute(
      path: '/module4',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const Module4Page()),
    ),
    GoRoute(
      path: '/module5',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const Module5Page()),
    ),
    GoRoute(
      path: '/night_routine',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const NightRoutinePage()),
    ),
    GoRoute(
      path: '/sleep_care',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const SleepCarePage()),
    ),
    GoRoute(
      path: '/sleep_care/reader',
      pageBuilder: (context, state) {
        final initialPage = state.extra as int? ?? 0;
        return _buildFadePage(
          state: state,
          child: SleepCareReaderPage(initialPage: initialPage),
        );
      },
    ),
    GoRoute(
      path: '/module6',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const Module6Page()),
    ),
    GoRoute(
      path: '/physical_activity',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const PhysicalActivityPage()),
    ),
    GoRoute(
      path: '/healthy_eating',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const HealthyEatingPage()),
    ),
    GoRoute(
      path: '/bmi_calculator',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const BmiCalculatorPage()),
    ),
    GoRoute(
      path: '/portions_guide',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const PortionsGuidePage()),
    ),
    GoRoute(
      path: '/knowing_foods',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const KnowingFoodsPage()),
    ),
    GoRoute(
      path: '/discovery_foods/:category',
      pageBuilder: (context, state) {
        final categoryId = state.pathParameters['category'] ?? 'energy';
        return _buildFadePage(
          state: state,
          child: FoodDiscoveryPage(categoryId: categoryId),
        );
      },
    ),
    GoRoute(
      path: '/knowing_stress',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const KnowingStressPage()),
    ),
    GoRoute(
      path: '/study_techniques',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const StudyTechniquesPage()),
    ),
    GoRoute(
      path: '/emotions',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const EmotionsCalendarPage()),
    ),
    GoRoute(
      path: '/meditation',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const MeditationPage()),
    ),
    GoRoute(
      path: '/sudoku',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const SudokuPage()),
    ),
    GoRoute(
      path: '/titi_chat',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const TitiChatPage()),
    ),
    GoRoute(
      path: '/active_pause',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const ActivePausePage()),
    ),
    GoRoute(
      path: '/active_pause_timer',
      pageBuilder: (context, state) {
        final exercise = state.extra as ActivePauseExercise;
        return _buildFadePage(
          state: state,
          child: ActivePauseTimerPage(exercise: exercise),
        );
      },
    ),
    GoRoute(
      path: '/relax',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const RelaxPage()),
    ),
    GoRoute(
      path: '/breathing',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const BreathingPage()),
    ),
    GoRoute(
      path: '/box_breathing',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const BoxBreathingPage()),
    ),
    GoRoute(
      path: '/yoga',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const YogaRoutinePage()),
    ),
    GoRoute(
      path: '/admin/dashboard',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const AdminDashboardPage()),
    ),
    GoRoute(
      path: '/organizer',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const OrganizerPage()),
    ),
    GoRoute(
      path: '/organizer/onboarding',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const OrganizerOnboardingPage()),
    ),
    GoRoute(
      path: '/playlist',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const PlaylistPage()),
    ),
    GoRoute(
      path: '/alarm',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const AlarmPage()),
    ),
    GoRoute(
      path: '/rest_timer',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const RestTimerPage()),
    ),
    GoRoute(
      path: '/forum',
      pageBuilder: (context, state) => _buildFadePage(state: state, child: const ForumPage()),
    ),
  ],
);

