import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService.internal();
  factory NotificationService() => instance;
  NotificationService.internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool isInitialized = false;

  Future<void> initialize() async {
    if (isInitialized) return;
    
    try {
      // Initialize timezone with local timezone
      tz.initializeTimeZones();
      
      // Get local timezone
      final String timeZoneName = await _getTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      debugPrint('Timezone initialized: $timeZoneName');

      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: onNotificationTapped,
      );

      await requestPermissions();
      
      isInitialized = true;
      debugPrint(' Notifications initialized successfully');
    } catch (e) {
      debugPrint(' Notification initialization error: $e');
    }
  }

  Future<String> _getTimeZone() async {
    try {
      // Try to get system timezone
      return 'Asia/Kolkata'; // Default for India
    } catch (e) {
      return 'UTC';
    }
  }

  Future<bool> requestPermissions() async {
    try {
      // Android 13+ notification permission
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      debugPrint(' Notification permission: ${granted ?? false}');

      // Request exact alarm permission for Android 12+
      final bool? exactAlarmGranted = await androidImplementation?.requestExactAlarmsPermission();
      debugPrint(' Exact alarm permission: ${exactAlarmGranted ?? false}');

      // iOS permissions
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return granted ?? false;
    } catch (e) {
      debugPrint(' Permission request error: $e');
      return false;
    }
  }

  void onNotificationTapped(NotificationResponse response) {
    debugPrint(' Notification tapped: ${response.payload}');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Check if time is in the future
      if (scheduledTime.isBefore(DateTime.now())) {
        debugPrint(' Cannot schedule notification in the past');
        return;
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'water_reminder_channel',
        'Water Reminders',
        channelDescription: 'Notifications for water drinking reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(' Notification scheduled for: $scheduledTime (ID: $id)');
      
      // Verify it was scheduled
      await _verifyScheduledNotification(id);
    } catch (e) {
      debugPrint(' Schedule notification error: $e');
    }
  }

  Future<void> _verifyScheduledNotification(int id) async {
    final pendingNotifications = await getPendingNotifications();
    final exists = pendingNotifications.any((n) => n.id == id);
    debugPrint(exists ? ' Notification $id verified in queue' : ' Notification $id NOT in queue');
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'water_reminder_channel',
        'Water Reminders',
        channelDescription: 'Notifications for water drinking reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
      );

      debugPrint(' Instant notification shown: $title');
    } catch (e) {
      debugPrint(' Show notification error: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint(' Notification cancelled: $id');
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    debugPrint(' All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    debugPrint(' Pending notifications: ${pending.length}');
    for (var notification in pending) {
      debugPrint('   - ID: ${notification.id}, Title: ${notification.title}');
    }
    return pending;
  }
}