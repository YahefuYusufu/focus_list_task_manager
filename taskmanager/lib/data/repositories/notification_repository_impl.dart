import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taskmanager/domain/repositories/notification_repository.dart';
import 'package:taskmanager/models/notification_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationRepositoryImpl implements NotificationRepository {
  final FlutterLocalNotificationsPlugin _notifications;
  final StreamController<String?> _notificationTapController = StreamController<String?>.broadcast();

  NotificationRepositoryImpl(this._notifications);

  @override
  Stream<String?> get onNotificationTapped => _notificationTapController.stream;

  @override
  Future<void> initialize() async {
    final AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _notificationTapController.add(response.payload);
      },
    );
  }

  @override
  Future<bool> requestPermissions() async {
    print('🔔 Requesting notification permissions...');

    if (Platform.isAndroid) {
      // Android permission handling
      final status = await Permission.notification.request();
      print('🤖 Android permission status: $status');
      return status.isGranted;
    } else if (Platform.isIOS) {
      print('🍎 Requesting iOS notification permissions explicitly...');

      try {
        final bool? result = await _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );

        print('🍎 iOS permission request result: $result');

        // Double-check the permission status
        await Future.delayed(Duration(milliseconds: 500)); // Wait a bit

        final settings = await _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.checkPermissions();

        print('🍎 iOS permission settings after request: $settings');

        // Test immediate notification to verify permissions
        if (result == true) {
          try {
            await _notifications.show(
              12345,
              '🍎 Permissions Granted!',
              'iOS notifications are now enabled for your task app.',
              NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
            );
            print('✅ Test permission notification sent');
          } catch (e) {
            print('❌ Test notification failed: $e');
          }
        }

        return result ?? false;
      } catch (e) {
        print('❌ iOS permission request error: $e');
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> scheduleNotification(NotificationModel notification) async {
    print('🔔 About to schedule notification on ${Platform.isIOS ? "iOS" : "Android"}');
    print('🔔 Notification time: ${notification.scheduledTime}');
    print('🔔 Current time: ${DateTime.now()}');

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_notifications',
        'Task Notifications',
        channelDescription: 'Notifications for task management',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    if (notification.scheduledTime.isAfter(DateTime.now())) {
      try {
        print('📅 Scheduling notification...');

        await _notifications.zonedSchedule(
          notification.id,
          notification.title,
          notification.body,
          tz.TZDateTime.from(notification.scheduledTime, tz.local),
          details,
          payload: notification.payload,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.alarmClock, // Required for all platforms
        );

        print('✅ Notification scheduled successfully');
      } catch (e) {
        print('❌ Failed to schedule notification: $e');

        // Fallback: show immediate notification
        try {
          await _notifications.show(
            notification.id,
            '⏰ Task Reminder Set',
            'Your timer is running. Check back soon!',
            details,
            payload: notification.payload,
          );
          print('✅ Immediate notification shown as fallback');
        } catch (e2) {
          print('❌ Even immediate notification failed: $e2');
        }
      }
    } else {
      // Show immediately
      print('📱 Showing immediate notification');
      try {
        await _notifications.show(
          notification.id,
          notification.title,
          notification.body,
          details,
          payload: notification.payload,
        );
        print('✅ Immediate notification shown');
      } catch (e) {
        print('❌ Immediate notification failed: $e');
      }
    }
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // ignore: unused_element
  Color? _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskReminder:
        return Colors.blue;
      case NotificationType.taskExpired:
        return Colors.red;
      case NotificationType.taskCompleted:
        return Colors.green;
    }
  }

  void dispose() {
    _notificationTapController.close();
  }
}
