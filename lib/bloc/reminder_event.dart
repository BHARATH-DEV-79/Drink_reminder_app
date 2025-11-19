import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadRemindersEvent extends ReminderEvent {}

class ToggleAutoReminderEvent extends ReminderEvent {
  final bool enabled;

  const ToggleAutoReminderEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class AddCustomReminderEvent extends ReminderEvent {
  final DateTime dateTime;
  final String? message;

  const AddCustomReminderEvent(this.dateTime, {this.message});

  @override
  List<Object?> get props => [dateTime, message];
}

class DeleteReminderEvent extends ReminderEvent {
  final ReminderModel reminder;

  const DeleteReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class IncrementWaterIntakeEvent extends ReminderEvent {}

class ResetWaterIntakeEvent extends ReminderEvent {}