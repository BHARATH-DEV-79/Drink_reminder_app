import 'package:drink_timmer_app/constant/colors.dart';
import 'package:drink_timmer_app/routes/routes.dart';
import 'package:drink_timmer_app/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/reminder_bloc.dart';
import 'bloc/reminder_event.dart';
import 'services/storage_service.dart';

void main() async {
  // Ensure Flutter is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Run the app
  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReminderBloc(
        notificationService: notificationService,
        storageService: StorageService(),
      )
      ..add(LoadRemindersEvent()),
      child: MaterialApp.router(
        title: 'Water Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.Secondary,
            foregroundColor: Colors.white,
          ),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
