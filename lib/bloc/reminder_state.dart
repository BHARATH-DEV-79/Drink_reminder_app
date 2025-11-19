import 'package:drink_timmer_app/models/reminder_model.dart';
import 'package:equatable/equatable.dart';


enum ReminderStatus { initial, loading, loaded, error }

class ReminderState extends Equatable {
  final ReminderStatus status;
  final List<ReminderModel> reminders;
  final bool autoReminderEnabled;
  final int waterIntakeCount;
  final String? errorMessage;

  const ReminderState({
    this.status = ReminderStatus.initial,
    this.reminders = const [],
    this.autoReminderEnabled = false,
    this.waterIntakeCount = 0,
    this.errorMessage,
  });

  ReminderState copyWith({
    ReminderStatus? status,
    List<ReminderModel>? reminders,
    bool? autoReminderEnabled,
    int? waterIntakeCount,
    String? errorMessage,
  }) {
    return ReminderState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      autoReminderEnabled: autoReminderEnabled ?? this.autoReminderEnabled,
      waterIntakeCount: waterIntakeCount ?? this.waterIntakeCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<ReminderModel> get customReminders =>
      reminders.where((r) => !r.isAutomatic).toList();

  List<ReminderModel> get automaticReminders =>
      reminders.where((r) => r.isAutomatic).toList();

  ReminderModel? get nextReminder {
    final now = DateTime.now();
    final upcomingReminders = reminders
        .where((r) => r.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return upcomingReminders.isNotEmpty ? upcomingReminders.first : null;
  }

  @override
  List<Object?> get props => [
        status,
        reminders,
        autoReminderEnabled,
        waterIntakeCount,
        errorMessage,
      ];
}