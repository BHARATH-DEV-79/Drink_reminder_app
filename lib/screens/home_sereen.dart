import 'package:drink_timmer_app/bloc/reminder_bloc.dart';
import 'package:drink_timmer_app/bloc/reminder_event.dart';
import 'package:drink_timmer_app/bloc/reminder_state.dart';
import 'package:drink_timmer_app/constant/colors.dart';
import 'package:drink_timmer_app/routes/app_routes.dart';
import 'package:drink_timmer_app/routes/routes.dart';

import 'package:drink_timmer_app/widgets/water_drop.dart';
import 'package:drink_timmer_app/widgets/water_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sip Reminder'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              context.push(PageRoutes.remindersList);
            },
          ),
        ],
      ),
      body: BlocBuilder<ReminderBloc, ReminderState>(
        builder: (context, state) {
          if (state.status == ReminderStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Water Drop Icon
                DropIcon(),
                const SizedBox(height: 40),
                // Water Progress
                WaterProgressWidget(
                  count: state.waterIntakeCount,
                  onIncrement: () {
                    context.read<ReminderBloc>().add(IncrementWaterIntakeEvent());
                  },
                  onReset: () {
                    context.read<ReminderBloc>().add(ResetWaterIntakeEvent());
                  },
                ),

                const SizedBox(height: 40),

                // Next Reminder Card
                if (state.nextReminder != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                color: AppColors.Secondary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Next Reminder',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(state.nextReminder!.dateTime),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.nextReminder!.isAutomatic
                                ? 'Automatic Reminder'
                                : 'Custom Reminder',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off,
                            color: Colors.grey.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Upcoming Reminders',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Auto Reminder Toggle
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Auto Reminder (Every 2 Hours)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      state.autoReminderEnabled
                          ? 'Enabled - You\'ll receive reminders'
                          : 'Disabled - Enable to get automatic reminders',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    value: state.autoReminderEnabled,
                    activeColor: Colors.blue.shade600,
                    onChanged: (value) {
                      context
                          .read<ReminderBloc>()
                          .add(ToggleAutoReminderEvent(value));
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Add Custom Reminder Button
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(PageRoutes.calendar);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Add Custom Reminder'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.Secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),

                const SizedBox(height: 12),

                // View All Reminders Button
                OutlinedButton.icon(
                  onPressed: () {
                    context.push(PageRoutes.remindersList);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>  RemindersListScreen(),
                    //   ),
                    // );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All Reminders'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.Secondary,
                    side: BorderSide(color: AppColors.Secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}