import 'package:intl/intl.dart';

class TimeService {
  // Format DateTime to readable string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  // Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Format date only
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  // Get relative time
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      return 'Passed';
    }

    if (difference.inMinutes < 60) {
      return 'in ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'in ${difference.inHours} hr${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
  }

  // Calculate next automatic reminder time
  static DateTime getNextAutoReminderTime() {
    final now = DateTime.now();
    return now.add(const Duration(hours: 2));
  }

  // Check if time is in the past
  static bool isPastTime(DateTime dateTime) {
    return dateTime.isBefore(DateTime.now());
  }

  // Get time until next reminder
  static Duration getTimeUntil(DateTime dateTime) {
    return dateTime.difference(DateTime.now());
  }

  // Format duration to readable string
  static String formatDuration(Duration duration) {
    if (duration.isNegative) return 'Passed';
    
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  // Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  // Get friendly date label
  static String getFriendlyDateLabel(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today';
    } else if (isTomorrow(dateTime)) {
      return 'Tomorrow';
    } else {
      return formatDate(dateTime);
    }
  }
}