import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmanager/models/notification_model.dart';

abstract class NotificationRepository {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> scheduleNotification(NotificationModel notification);
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
  Future<List<PendingNotificationRequest>> getPendingNotifications();
  Stream<String?> get onNotificationTapped;
}
