import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskmanager/domain/repositories/notification_repository.dart';
import 'package:taskmanager/models/notification_model.dart';

// Mock implementation for testing
class MockNotificationRepository extends Mock implements NotificationRepository {}

// Fake classes for mocktail
class FakeNotificationModel extends Fake implements NotificationModel {}

class FakePendingNotificationRequest extends Fake implements PendingNotificationRequest {}

void main() {
  late MockNotificationRepository mockRepository;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeNotificationModel());
  });

  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  group('NotificationRepository', () {
    final testNotification = NotificationModel(
      id: 1,
      title: 'Test Notification',
      body: 'This is a test notification',
      scheduledTime: DateTime.now().add(Duration(minutes: 5)),
      payload: 'test_payload',
      type: NotificationType.taskReminder,
    );

    final testPendingNotifications = [
      PendingNotificationRequest(
        1, // id (int)
        'Test Notification', // title (String?)
        'This is a test notification', // body (String?)
        'test_payload', // payload (String?)
      )
    ];

    group('initialize', () {
      test('should complete successfully when initialization succeeds', () async {
        // Arrange
        when(() => mockRepository.initialize()).thenAnswer((_) async => {});

        // Act & Assert
        expect(() => mockRepository.initialize(), returnsNormally);
        verify(() => mockRepository.initialize()).called(1);
      });

      test('should throw exception when initialization fails', () async {
        // Arrange
        when(() => mockRepository.initialize()).thenThrow(Exception('Failed to initialize notifications'));

        // Act & Assert
        expect(() => mockRepository.initialize(), throwsException);
        verify(() => mockRepository.initialize()).called(1);
      });
    });

    group('requestPermissions', () {
      test('should return true when permissions are granted', () async {
        // Arrange
        when(() => mockRepository.requestPermissions()).thenAnswer((_) async => true);

        // Act
        final result = await mockRepository.requestPermissions();

        // Assert
        expect(result, true);
        verify(() => mockRepository.requestPermissions()).called(1);
      });

      test('should return false when permissions are denied', () async {
        // Arrange
        when(() => mockRepository.requestPermissions()).thenAnswer((_) async => false);

        // Act
        final result = await mockRepository.requestPermissions();

        // Assert
        expect(result, false);
        verify(() => mockRepository.requestPermissions()).called(1);
      });
    });

    group('scheduleNotification', () {
      test('should complete successfully when scheduling succeeds', () async {
        // Arrange
        when(() => mockRepository.scheduleNotification(any())).thenAnswer((_) async => {});

        // Act & Assert
        expect(() => mockRepository.scheduleNotification(testNotification), returnsNormally);
        verify(() => mockRepository.scheduleNotification(testNotification)).called(1);
      });

      test('should throw exception when scheduling fails', () async {
        // Arrange
        when(() => mockRepository.scheduleNotification(any())).thenThrow(Exception('Failed to schedule notification'));

        // Act & Assert
        expect(() => mockRepository.scheduleNotification(testNotification), throwsException);
        verify(() => mockRepository.scheduleNotification(testNotification)).called(1);
      });
    });

    group('cancelNotification', () {
      test('should complete successfully when cancellation succeeds', () async {
        // Arrange
        when(() => mockRepository.cancelNotification(any())).thenAnswer((_) async => {});

        // Act & Assert
        expect(() => mockRepository.cancelNotification(1), returnsNormally);
        verify(() => mockRepository.cancelNotification(1)).called(1);
      });

      test('should throw exception when cancellation fails', () async {
        // Arrange
        when(() => mockRepository.cancelNotification(any())).thenThrow(Exception('Failed to cancel notification'));

        // Act & Assert
        expect(() => mockRepository.cancelNotification(1), throwsException);
        verify(() => mockRepository.cancelNotification(1)).called(1);
      });
    });

    group('cancelAllNotifications', () {
      test('should complete successfully when cancelling all succeeds', () async {
        // Arrange
        when(() => mockRepository.cancelAllNotifications()).thenAnswer((_) async => {});

        // Act & Assert
        expect(() => mockRepository.cancelAllNotifications(), returnsNormally);
        verify(() => mockRepository.cancelAllNotifications()).called(1);
      });

      test('should throw exception when cancelling all fails', () async {
        // Arrange
        when(() => mockRepository.cancelAllNotifications()).thenThrow(Exception('Failed to cancel all notifications'));

        // Act & Assert
        expect(() => mockRepository.cancelAllNotifications(), throwsException);
        verify(() => mockRepository.cancelAllNotifications()).called(1);
      });
    });

    group('getPendingNotifications', () {
      test('should return list of pending notifications when successful', () async {
        // Arrange
        when(() => mockRepository.getPendingNotifications()).thenAnswer((_) async => testPendingNotifications);

        // Act
        final result = await mockRepository.getPendingNotifications();

        // Assert
        expect(result, testPendingNotifications);
        expect(result.length, 1);
        expect(result.first.id, 1);
        verify(() => mockRepository.getPendingNotifications()).called(1);
      });

      test('should return empty list when no pending notifications', () async {
        // Arrange
        when(() => mockRepository.getPendingNotifications()).thenAnswer((_) async => []);

        // Act
        final result = await mockRepository.getPendingNotifications();

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getPendingNotifications()).called(1);
      });

      test('should throw exception when fetching pending notifications fails', () async {
        // Arrange
        when(() => mockRepository.getPendingNotifications()).thenThrow(Exception('Failed to get pending notifications'));

        // Act & Assert
        expect(() => mockRepository.getPendingNotifications(), throwsException);
        verify(() => mockRepository.getPendingNotifications()).called(1);
      });
    });

    group('onNotificationTapped', () {
      test('should provide stream of notification taps', () async {
        // Arrange
        final testStream = Stream<String?>.fromIterable(['payload1', 'payload2', null]);
        when(() => mockRepository.onNotificationTapped).thenAnswer((_) => testStream);

        // Act
        final stream = mockRepository.onNotificationTapped;
        final values = await stream.take(3).toList();

        // Assert
        expect(values, ['payload1', 'payload2', null]);
        verify(() => mockRepository.onNotificationTapped).called(1);
      });

      test('should handle empty stream', () async {
        // Arrange
        final emptyStream = Stream<String?>.empty();
        when(() => mockRepository.onNotificationTapped).thenAnswer((_) => emptyStream);

        // Act
        final stream = mockRepository.onNotificationTapped;
        final values = await stream.toList();

        // Assert
        expect(values, isEmpty);
        verify(() => mockRepository.onNotificationTapped).called(1);
      });
    });
  });
}
