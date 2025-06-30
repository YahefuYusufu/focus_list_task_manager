// ignore_for_file: avoid_print

import 'package:taskmanager/config/api_config.dart';

class TimeUtils {
  // Format seconds into MM:SS format
  static String formatDuration(int seconds) {
    if (seconds <= 0) return "00:00";

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  // Format seconds into human readable format (e.g., "5 min 30 sec")
  static String formatDurationHuman(int seconds) {
    if (seconds <= 0) return "Expired";

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0 && remainingSeconds > 0) {
      return "${minutes}m ${remainingSeconds}s";
    } else if (minutes > 0) {
      return "${minutes}m";
    } else {
      return "${remainingSeconds}s";
    }
  }

  // Parse time limit from minutes picker
  static List<int> getTimePickerOptions() {
    return [1, 2, 3, 5, 10, 15, 20, 25, 30, 45, 60];
  }

  // Convert minutes to display text
  static String formatMinutes(int minutes) {
    if (minutes == 1) return "1 minute";
    if (minutes < 60) return "$minutes minutes";

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return hours == 1 ? "1 hour" : "$hours hours";
    } else {
      return "${hours}h ${remainingMinutes}m";
    }
  }

  // Check if task is in warning state (less than 5 minutes)
  static bool isInWarningState(int remainingSeconds) {
    return remainingSeconds <= ApiConfig.warningThresholdSeconds && remainingSeconds > ApiConfig.urgentThresholdSeconds;
  }

  // Check if task is in urgent state (less than 1 minute)
  static bool isInUrgentState(int remainingSeconds) {
    return remainingSeconds <= ApiConfig.urgentThresholdSeconds && remainingSeconds > 0;
  }

  // Get color based on remaining time
  static String getTimeStateColor(int remainingSeconds) {
    if (remainingSeconds <= 0) return 'expired';
    if (isInUrgentState(remainingSeconds)) return 'urgent';
    if (isInWarningState(remainingSeconds)) return 'warning';
    return 'normal';
  }

  // Calculate progress percentage (0.0 to 1.0)
  static double calculateProgress(int remainingSeconds, int totalMinutes) {
    final totalSeconds = totalMinutes * 60;
    if (totalSeconds <= 0) return 0.0;

    final elapsed = totalSeconds - remainingSeconds;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  // Parse ISO 8601 datetime string to local DateTime
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('Error parsing datetime: $dateTimeString');
      return null;
    }
  }

  // Get current timestamp in ISO format
  static String getCurrentTimestamp() {
    return DateTime.now().toIso8601String();
  }
}
