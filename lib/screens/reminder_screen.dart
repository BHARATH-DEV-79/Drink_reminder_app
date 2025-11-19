import 'package:drink_timmer_app/bloc/reminder_bloc.dart';
import 'package:drink_timmer_app/bloc/reminder_event.dart';
import 'package:drink_timmer_app/bloc/reminder_state.dart';
import 'package:drink_timmer_app/models/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RemindersListScreen extends StatelessWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reminders'),
        elevation: 0,
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state.status == ReminderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final now = DateTime.now();
          final upcomingReminders = state.reminders
              .where((r) => r.dateTime.isAfter(now))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

          if (upcomingReminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Upcoming Reminders',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a custom reminder or enable auto reminders',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final customReminders = upcomingReminders
              .where((r) => !r.isAutomatic)
              .toList();
          final autoReminders = upcomingReminders
              .where((r) => r.isAutomatic)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (autoReminders.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Automatic Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...autoReminders.map((reminder) => 
                    ReminderCard(reminder: reminder, canDelete: false)),
                const SizedBox(height: 16),
              ],
              
              if (customReminders.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Custom Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...customReminders.map((reminder) => 
                    ReminderCard(reminder: reminder, canDelete: true)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final bool canDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = reminder.dateTime.difference(now);
    
    String timeUntil;
    if (difference.inHours > 24) {
      timeUntil = 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      timeUntil = 'in ${difference.inHours} hours';
    } else {
      timeUntil = 'in ${difference.inMinutes} minutes';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: reminder.isAutomatic 
                ? Colors.blue.shade50 
                : Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            reminder.isAutomatic ? Icons.refresh : Icons.calendar_today,
            color: reminder.isAutomatic 
                ? Colors.blue.shade600 
                : Colors.green.shade600,
          ),
        ),
        title: Text(
          DateFormat('MMM dd, yyyy').format(reminder.dateTime),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(reminder.dateTime),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeUntil,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: canDelete
            ? IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) => AlertDialog(
                      title: const Text('Delete Reminder'),
                      content: const Text(
                        'Are you sure you want to delete this reminder?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<ReminderBloc>()
                                .add(DeleteReminderEvent(reminder));
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder deleted'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}