import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/reminder_model.dart';


import '../services/notification_services.dart';
import '../services/storage_service.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final NotificationService notificationService;
  final StorageService storageService;

  ReminderBloc({
    required this.notificationService,
    required this.storageService,
  }) : super(const ReminderState()) {
    on<LoadRemindersEvent>(onLoadReminders);
    on<ToggleAutoReminderEvent>(onToggleAutoReminder);
    on<AddCustomReminderEvent>(onAddCustomReminder);
    on<DeleteReminderEvent>(onDeleteReminder);
    on<IncrementWaterIntakeEvent>(onIncrementWaterIntake);
    on<ResetWaterIntakeEvent>(onResetWaterIntake);
  }

  Future<void> onLoadReminders(
    LoadRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(state.copyWith(status: ReminderStatus.loading));

    try {
      final customReminders = await storageService.loadReminders();
      final autoReminderEnabled = await storageService.loadAutoReminderState();
      final waterIntake = await storageService.getWaterIntake();

      final now = DateTime.now();
      final validReminders = customReminders
          .where((r) => r.dateTime.isAfter(now))
          .toList();

      List<ReminderModel> allReminders = List.from(validReminders);

      if (autoReminderEnabled) {
        allReminders.addAll(generateAutoReminders());
      }

      emit(state.copyWith(
        status: ReminderStatus.loaded,
        reminders: allReminders,
        autoReminderEnabled: autoReminderEnabled,
        waterIntakeCount: waterIntake,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> onToggleAutoReminder(
    ToggleAutoReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await storageService.saveAutoReminderState(event.enabled);

      List<ReminderModel> updatedReminders = List.from(state.customReminders);

      final autoReminders = state.automaticReminders;
      for (var reminder in autoReminders) {
        await notificationService.cancelNotification(reminder.id.hashCode);
      }

      if (event.enabled) {
        final autoReminders = generateAutoReminders();
        updatedReminders.addAll(autoReminders);

        for (var reminder in autoReminders) {
          await notificationService.scheduleNotification(
            id: reminder.id.hashCode,
            title: 'Water Reminder',
            body: reminder.message,
            scheduledTime: reminder.dateTime,
          );
        }
      }

      emit(state.copyWith(
        autoReminderEnabled: event.enabled,
        reminders: updatedReminders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> onAddCustomReminder(
    AddCustomReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final reminder = ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: event.dateTime,
        isAutomatic: false,
        message: event.message ?? '💧 Time to Drink Water! Stay Hydrated.',
      );

      await notificationService.scheduleNotification(
        id: reminder.id.hashCode,
        title: 'Water Reminder',
        body: reminder.message,
        scheduledTime: reminder.dateTime,
      );

      final updatedReminders = List<ReminderModel>.from(state.reminders)
        ..add(reminder);

      await storageService.saveReminders(
        updatedReminders.where((r) => !r.isAutomatic).toList(),
      );

      emit(state.copyWith(reminders: updatedReminders));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> onDeleteReminder(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await notificationService.cancelNotification(event.reminder.id.hashCode);

      final updatedReminders = state.reminders
          .where((r) => r.id != event.reminder.id)
          .toList();

      await storageService.saveReminders(
        updatedReminders.where((r) => !r.isAutomatic).toList(),
      );

      emit(state.copyWith(reminders: updatedReminders));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> onIncrementWaterIntake(
    IncrementWaterIntakeEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await storageService.incrementWaterIntake();
      final newCount = await storageService.getWaterIntake();
      emit(state.copyWith(waterIntakeCount: newCount));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> onResetWaterIntake(
    ResetWaterIntakeEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await storageService.resetWaterIntake();
      emit(state.copyWith(waterIntakeCount: 0));
    } catch (e) {
      emit(state.copyWith(
        status: ReminderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  List<ReminderModel> generateAutoReminders() {
    final now = DateTime.now();
    final reminders = <ReminderModel>[];

    for (int i = 1; i <= 6; i++) {
      final reminderTime = now.add(Duration(hours: i * 2));
      
      reminders.add(ReminderModel(
        id: 'auto_${reminderTime.millisecondsSinceEpoch}',
        dateTime: reminderTime,
        isAutomatic: true,
      ));
    }

    return reminders;
  }
}