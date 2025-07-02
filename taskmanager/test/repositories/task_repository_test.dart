import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/models/task_response.dart';

// This is a mock implementation for testing
class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  group('TaskRepository', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      timeLimitMinutes: 30,
      status: TaskStatus.active,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 1800,
    );

    final testTasksResponse = TasksResponse(
      active: [testTask],
      completed: [],
      missed: [],
    );

    final testStatsResponse = TaskStatsResponse(
      totalTasks: 1,
      activeTasks: 1,
      completedTasks: 0,
      missedTasks: 0,
    );

    group('checkHealth', () {
      test('should return success when repository is healthy', () async {
        // Arrange
        when(() => mockRepository.checkHealth()).thenAnswer((_) async => Result.success(true));

        // Act
        final result = await mockRepository.checkHealth();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, true);
        verify(() => mockRepository.checkHealth()).called(1);
      });

      test('should return failure when repository is unhealthy', () async {
        // Arrange
        when(() => mockRepository.checkHealth()).thenAnswer((_) async => Result.failure('Database connection failed'));

        // Act
        final result = await mockRepository.checkHealth();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Database connection failed');
        verify(() => mockRepository.checkHealth()).called(1);
      });
    });

    group('getAllTasks', () {
      test('should return tasks when successful', () async {
        // Arrange
        when(() => mockRepository.getAllTasks()).thenAnswer((_) async => Result.success(testTasksResponse));

        // Act
        final result = await mockRepository.getAllTasks();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, testTasksResponse);
        expect(result.data!.active.length, 1);
        verify(() => mockRepository.getAllTasks()).called(1);
      });

      test('should return empty lists when no tasks exist', () async {
        // Arrange
        final emptyResponse = TasksResponse(
          active: [],
          completed: [],
          missed: [],
        );
        when(() => mockRepository.getAllTasks()).thenAnswer((_) async => Result.success(emptyResponse));

        // Act
        final result = await mockRepository.getAllTasks();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data!.active.isEmpty, true);
        expect(result.data!.completed.isEmpty, true);
        expect(result.data!.missed.isEmpty, true);
        verify(() => mockRepository.getAllTasks()).called(1);
      });

      test('should return failure when fetch fails', () async {
        // Arrange
        when(() => mockRepository.getAllTasks()).thenAnswer((_) async => Result.failure('Network error'));

        // Act
        final result = await mockRepository.getAllTasks();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Network error');
        verify(() => mockRepository.getAllTasks()).called(1);
      });
    });

    group('getTask', () {
      test('should return task when found', () async {
        // Arrange
        when(() => mockRepository.getTask(1)).thenAnswer((_) async => Result.success(testTask));

        // Act
        final result = await mockRepository.getTask(1);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, testTask);
        expect(result.data!.id, 1);
        verify(() => mockRepository.getTask(1)).called(1);
      });

      test('should return failure when task not found', () async {
        // Arrange
        when(() => mockRepository.getTask(999)).thenAnswer((_) async => Result.failure('Task not found'));

        // Act
        final result = await mockRepository.getTask(999);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Task not found');
        verify(() => mockRepository.getTask(999)).called(1);
      });
    });

    group('createTask', () {
      test('should return created task when successful', () async {
        // Arrange
        when(() => mockRepository.createTask(
              title: any(named: 'title'),
              timeLimitMinutes: any(named: 'timeLimitMinutes'),
            )).thenAnswer((_) async => Result.success(testTask));

        // Act
        final result = await mockRepository.createTask(
          title: 'New Task',
          timeLimitMinutes: 30,
        );

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, testTask);
        verify(() => mockRepository.createTask(
              title: 'New Task',
              timeLimitMinutes: 30,
            )).called(1);
      });

      test('should return failure when creation fails', () async {
        // Arrange
        when(() => mockRepository.createTask(
              title: any(named: 'title'),
              timeLimitMinutes: any(named: 'timeLimitMinutes'),
            )).thenAnswer((_) async => Result.failure('Failed to create task'));

        // Act
        final result = await mockRepository.createTask(
          title: 'New Task',
          timeLimitMinutes: 30,
        );

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Failed to create task');
        verify(() => mockRepository.createTask(
              title: 'New Task',
              timeLimitMinutes: 30,
            )).called(1);
      });
    });

    group('completeTask', () {
      test('should return completed task when successful', () async {
        // Arrange
        final completedTask = Task(
          id: 1,
          title: 'Test Task',
          timeLimitMinutes: 30,
          status: TaskStatus.completed,
          createdAt: '2025-07-02T10:00:00Z',
          expiresAt: '2025-07-02T10:30:00Z',
          remainingSeconds: 0,
        );
        when(() => mockRepository.completeTask(1)).thenAnswer((_) async => Result.success(completedTask));

        // Act
        final result = await mockRepository.completeTask(1);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data!.status, TaskStatus.completed);
        verify(() => mockRepository.completeTask(1)).called(1);
      });

      test('should return failure when completion fails', () async {
        // Arrange
        when(() => mockRepository.completeTask(1)).thenAnswer((_) async => Result.failure('Task already completed'));

        // Act
        final result = await mockRepository.completeTask(1);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Task already completed');
        verify(() => mockRepository.completeTask(1)).called(1);
      });
    });

    group('checkTaskExpiry', () {
      test('should return task with updated expiry status', () async {
        // Arrange
        final expiredTask = Task(
          id: 1,
          title: 'Test Task',
          timeLimitMinutes: 30,
          status: TaskStatus.missed,
          createdAt: '2025-07-02T10:00:00Z',
          expiresAt: '2025-07-02T10:30:00Z',
          remainingSeconds: 0,
        );
        when(() => mockRepository.checkTaskExpiry(1)).thenAnswer((_) async => Result.success(expiredTask));

        // Act
        final result = await mockRepository.checkTaskExpiry(1);

        // Assert
        expect(result.isSuccess, true);
        expect(result.data!.status, TaskStatus.missed);
        verify(() => mockRepository.checkTaskExpiry(1)).called(1);
      });

      test('should return failure when task not found', () async {
        // Arrange
        when(() => mockRepository.checkTaskExpiry(999)).thenAnswer((_) async => Result.failure('Task not found'));

        // Act
        final result = await mockRepository.checkTaskExpiry(999);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Task not found');
        verify(() => mockRepository.checkTaskExpiry(999)).called(1);
      });
    });

    group('deleteTask', () {
      test('should return success when deletion is successful', () async {
        // Arrange
        when(() => mockRepository.deleteTask(1)).thenAnswer((_) async => Result.success(null));

        // Act
        final result = await mockRepository.deleteTask(1);

        // Assert
        expect(result.isSuccess, true);
        verify(() => mockRepository.deleteTask(1)).called(1);
      });

      test('should return failure when deletion fails', () async {
        // Arrange
        when(() => mockRepository.deleteTask(1)).thenAnswer((_) async => Result.failure('Task not found'));

        // Act
        final result = await mockRepository.deleteTask(1);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Task not found');
        verify(() => mockRepository.deleteTask(1)).called(1);
      });
    });

    group('getTaskStats', () {
      test('should return task statistics when successful', () async {
        // Arrange
        when(() => mockRepository.getTaskStats()).thenAnswer((_) async => Result.success(testStatsResponse));

        // Act
        final result = await mockRepository.getTaskStats();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, testStatsResponse);
        expect(result.data!.totalTasks, 1);
        expect(result.data!.activeTasks, 1);
        verify(() => mockRepository.getTaskStats()).called(1);
      });

      test('should return failure when stats fetch fails', () async {
        // Arrange
        when(() => mockRepository.getTaskStats()).thenAnswer((_) async => Result.failure('Database error'));

        // Act
        final result = await mockRepository.getTaskStats();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, 'Database error');
        verify(() => mockRepository.getTaskStats()).called(1);
      });
    });
  });
}
