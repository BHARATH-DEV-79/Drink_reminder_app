// lib/router/app_router.dart
import 'package:drink_timmer_app/screens/calander_screen.dart';
import 'package:drink_timmer_app/screens/home_sereen.dart';
import 'package:drink_timmer_app/screens/reminder_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String home = '/';
  static const String calendar = '/calendar';
  static const String remindersList = '/reminders-list';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: calendar, builder: (context, state) => const CalendarScreen()),
      GoRoute(path: remindersList, builder: (context, state) => const RemindersListScreen()),
    ],
  );
}