class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payload;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.payload,
    required this.type,
  });
}

enum NotificationType {
  taskReminder,
  taskExpired,
  taskCompleted,
}
