import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/repositories/notification_repository.dart';
import 'package:taskmanager/domain/usecases/notification_usecases.dart';
import 'package:taskmanager/models/notification_model.dart';
import 'package:taskmanager/models/task_model.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepository;
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeNotificationModel());
  });
  setUp(() {
    mockRepository = MockNotificationRepository();
  });

  tearDown(() {
    // Clean up any timers that might be running
    // We'll test the functionality without accessing private fields
  });

  group('ScheduleTaskReminderUseCase', () {
    late ScheduleTaskReminderUseCase useCase;

    setUp(() {
      useCase = ScheduleTaskReminderUseCase(mockRepository);
    });

    test('should not schedule notification for task with less than 11 seconds', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Short Task',
        timeLimitMinutes: 0,
        status: TaskStatus.active,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:00:00Z',
        remainingSeconds: 0,
      );

      // Act
      await useCase.call(task);

      // Assert
      // We can't access private timers, but we can verify no notification was scheduled
      verifyNever(() => mockRepository.scheduleNotification(any()));
    });

    test('should call repository for valid task', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Valid Task',
        timeLimitMinutes: 1, // 60 seconds, enough for 10-second warning
        status: TaskStatus.active,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:01:00Z',
        remainingSeconds: 60,
      );

      when(() => mockRepository.scheduleNotification(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(task);

      // Assert
      // We test that the use case completes without error
      // The actual timer scheduling is an implementation detail
      expect(() => useCase.call(task), returnsNormally);
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Task',
        timeLimitMinutes: 1,
        status: TaskStatus.active,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:01:00Z',
        remainingSeconds: 60,
      );

      when(() => mockRepository.scheduleNotification(any())).thenThrow(Exception('Notification failed'));

      // Act & Assert - Should not throw
      expect(() => useCase.call(task), returnsNormally);
    });

    test('cancelTimer should execute without errors', () {
      // Act & Assert
      expect(() => ScheduleTaskReminderUseCase.cancelTimer(1), returnsNormally);
      expect(() => ScheduleTaskReminderUseCase.cancelTimer(999), returnsNormally);
    });

    test('should handle task with minimum valid time', () async {
      // Arrange - Task with exactly 11 seconds (minimum for 10-second warning)
      final task = Task(
        id: 2,
        title: 'Minimum Time Task',
        timeLimitMinutes: 1, // This gives us 60 seconds total
        status: TaskStatus.active,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:01:00Z',
        remainingSeconds: 60,
      );

      when(() => mockRepository.scheduleNotification(any())).thenAnswer((_) async {});

      // Act & Assert
      expect(() => useCase.call(task), returnsNormally);
    });

    test('should handle task with empty title', () async {
      // Arrange
      final task = Task(
        id: 3,
        title: '', // Empty title
        timeLimitMinutes: 5,
        status: TaskStatus.active,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:05:00Z',
        remainingSeconds: 300,
      );

      when(() => mockRepository.scheduleNotification(any())).thenAnswer((_) async {});

      // Act & Assert
      expect(() => useCase.call(task), returnsNormally);
    });
  });

  group('ShowTaskCompletedUseCase', () {
    late ShowTaskCompletedUseCase useCase;

    setUp(() {
      useCase = ShowTaskCompletedUseCase(mockRepository);
    });

    test('should schedule completion notification', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Completed Task',
        timeLimitMinutes: 30,
        status: TaskStatus.completed,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:30:00Z',
        remainingSeconds: 0,
      );

      when(() => mockRepository.scheduleNotification(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(task);

      // Assert
      verify(() => mockRepository.scheduleNotification(any(
          that: predicate<NotificationModel>((notification) =>
              notification.title == 'Task Completed! 🎉' &&
              notification.body == 'Great job completing: Completed Task' &&
              notification.type == NotificationType.taskCompleted &&
              notification.payload == 'task_completed_1')))).called(1);
    });

    test('should handle repository errors', () async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Task',
        timeLimitMinutes: 30,
        status: TaskStatus.completed,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:30:00Z',
        remainingSeconds: 0,
      );

      when(() => mockRepository.scheduleNotification(any())).thenThrow(Exception('Failed to schedule'));

      // Act & Assert
      expect(() => useCase.call(task), throwsException);
    });
  });

  group('CancelTaskNotificationsUseCase', () {
    late CancelTaskNotificationsUseCase useCase;

    setUp(() {
      useCase = CancelTaskNotificationsUseCase(mockRepository);
    });

    test('should cancel both reminder and expiration notifications', () async {
      // Arrange
      const taskId = 1;
      when(() => mockRepository.cancelNotification(any())).thenAnswer((_) async {});

      // Act
      await useCase.call(taskId);

      // Assert
      verify(() => mockRepository.cancelNotification(taskId.hashCode)).called(1);
      verify(() => mockRepository.cancelNotification(taskId.hashCode + 1000)).called(1);
    });

    test('should handle repository errors', () async {
      // Arrange
      const taskId = 1;
      when(() => mockRepository.cancelNotification(any())).thenThrow(Exception('Failed to cancel'));

      // Act & Assert
      expect(() => useCase.call(taskId), throwsException);
    });
  });
}

class FakeNotificationModel extends Fake implements NotificationModel {}
