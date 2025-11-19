import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class StorageService {
  static const String remindersKey = 'water_reminders';
  static const String autoReminderKey = 'auto_reminder_enabled';
  static const String waterIntakeKey = 'water_intake_count';

  // Save reminders to local storage
  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = reminders.map((r) => r.toJson()).toList();
    await prefs.setString(remindersKey, jsonEncode(remindersJson));
  }

  // Load reminders from local storage
  Future<List<ReminderModel>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersString = prefs.getString(remindersKey);
    
    if (remindersString == null || remindersString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> remindersJson = jsonDecode(remindersString);
      return remindersJson
          .map((json) => ReminderModel.fromJson(json as Map<String, dynamic>))
          .where((reminder) => reminder.dateTime.isAfter(DateTime.now()))
          .toList();
    } catch (e) {
      print('Error loading reminders: $e');
      return [];
    }
  }

  //  CORRECT METHOD NAME - matches what BLoC expects
  Future<void> saveAutoReminderState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(autoReminderKey, enabled);
  }

  //  CORRECT METHOD NAME - matches what BLoC expects
  Future<bool> loadAutoReminderState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(autoReminderKey) ?? false;
  }

  // Save water intake count
  Future<void> saveWaterIntake(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(waterIntakeKey, count);
  }

  // CORRECT METHOD NAME - matches what BLoC expects
  Future<int> getWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(waterIntakeKey) ?? 0;
  }

  // Increment water intake
  Future<void> incrementWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(waterIntakeKey) ?? 0;
    await prefs.setInt(waterIntakeKey, currentCount + 1);
  }

  // Reset water intake
  Future<void> resetWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(waterIntakeKey, 0);
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}