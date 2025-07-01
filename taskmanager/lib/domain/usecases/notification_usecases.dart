import 'dart:async';

import 'package:taskmanager/domain/repositories/notification_repository.dart';
import 'package:taskmanager/models/notification_model.dart';
import 'package:taskmanager/models/task_model.dart';

class ScheduleTaskReminderUseCase {
  final NotificationRepository _repository;
  static final Map<int, Timer> _activeTimers = {};

  ScheduleTaskReminderUseCase(this._repository);

  Future<void> call(Task task) async {
    try {
      print('🔔 Setting up timer-based notification for: ${task.title}');

      // Calculate delay until 10 seconds before expiration
      final totalTaskSeconds = task.timeLimitMinutes * 60; // Convert minutes to seconds
      final delaySeconds = totalTaskSeconds - 10; // 10 seconds before expiration

      // ignore: unnecessary_brace_in_string_interps
      print('🔍 Task duration: ${task.timeLimitMinutes} minutes (${totalTaskSeconds} seconds)');
      // ignore: unnecessary_brace_in_string_interps
      print('🔍 Will show notification in: ${delaySeconds} seconds');

      if (delaySeconds <= 0) {
        print('⚠️ Task time is too short for 10-second warning (need at least 11 seconds)');
        return;
      }

      // Cancel any existing timer for this task
      _activeTimers[task.id]?.cancel();

      // Create a timer that will fire at the right time
      _activeTimers[task.id] = Timer(Duration(seconds: delaySeconds), () async {
        print('⏰ Timer fired! Showing notification for: ${task.title}');

        // Show immediate notification (no scheduling needed)
        final notification = NotificationModel(
          id: task.id.hashCode,
          title: '⏰ Task Almost Expired!',
          body: 'Only 10 seconds left for: ${task.title.isEmpty ? "your task" : task.title}',
          scheduledTime: DateTime.now(), // Show immediately when timer fires
          payload: 'task_reminder_${task.id}',
          type: NotificationType.taskReminder,
        );

        try {
          await _repository.scheduleNotification(notification);
          print('✅ Timer-based notification shown successfully!');
        } catch (e) {
          print('❌ Failed to show timer-based notification: $e');
        }

        // Clean up timer
        _activeTimers.remove(task.id);
      });

      // ignore: unnecessary_brace_in_string_interps
      print('✅ Timer set successfully! Will fire in ${delaySeconds} seconds');
    } catch (e) {
      print('❌ Error setting up timer: $e');
    }
  }

  // Method to cancel timer for a specific task
  static void cancelTimer(int taskId) {
    print('🔕 Cancelling timer for task: $taskId');
    _activeTimers[taskId]?.cancel();
    _activeTimers.remove(taskId);
  }
}

class ShowTaskCompletedUseCase {
  final NotificationRepository _repository;

  ShowTaskCompletedUseCase(this._repository);

  Future<void> call(Task task) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Task Completed! 🎉',
      body: 'Great job completing: ${task.title}',
      scheduledTime: DateTime.now(),
      payload: 'task_completed_${task.id}',
      type: NotificationType.taskCompleted,
    );

    await _repository.scheduleNotification(notification);
  }
}

class CancelTaskNotificationsUseCase {
  final NotificationRepository _repository;

  CancelTaskNotificationsUseCase(this._repository);

  Future<void> call(int taskId) async {
    await _repository.cancelNotification(taskId.hashCode); // Reminder
    await _repository.cancelNotification(taskId.hashCode + 1000); // Expiration
  }
}
