// lib/router/app_router.dart
import 'package:drink_timmer_app/routes/app_routes.dart';
import 'package:drink_timmer_app/screens/calander_screen.dart';
import 'package:drink_timmer_app/screens/home_sereen.dart';
import 'package:drink_timmer_app/screens/reminder_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  

  static final GoRouter router = GoRouter(
    initialLocation: PageRoutes.home,
    routes: [
      GoRoute(
        // name: '/',
        path: PageRoutes.home,
         builder: (context, state) => const HomeScreen()
         ),
      GoRoute(
        // name: '/calendar',
        path: PageRoutes.calendar, 
        builder: (context, state) => const CalendarScreen()
        ),
      GoRoute(
        // name: '/reminder',
        path: PageRoutes.remindersList, 
        builder: (context, state) => const RemindersListScreen()
        ),
    ],
  );
}