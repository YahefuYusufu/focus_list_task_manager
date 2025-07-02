import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/create_task_usecase.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CreateTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = CreateTaskUseCase(mockRepository);
  });

  group('CreateTaskUseCase', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      timeLimitMinutes: 30,
      status: TaskStatus.active,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 1800,
    );

    test('should return failure when title is empty', () async {
      // Act
      final result = await useCase.call(
        title: '',
        timeLimitMinutes: 30,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Task title cannot be empty');
      verifyNever(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          ));
    });

    test('should return failure when title is only whitespace', () async {
      // Act
      final result = await useCase.call(
        title: '   ',
        timeLimitMinutes: 30,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Task title cannot be empty');
      verifyNever(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          ));
    });

    test('should return failure when timeLimitMinutes is 0', () async {
      // Act
      final result = await useCase.call(
        title: 'Valid Title',
        timeLimitMinutes: 0,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Time limit must be between 1 and 120 minutes');
      verifyNever(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          ));
    });

    test('should return failure when timeLimitMinutes is greater than 120', () async {
      // Act
      final result = await useCase.call(
        title: 'Valid Title',
        timeLimitMinutes: 121,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Time limit must be between 1 and 120 minutes');
      verifyNever(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          ));
    });

    test('should trim title and call repository when inputs are valid', () async {
      // Arrange
      when(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          )).thenAnswer((_) async => Result.success(testTask));

      // Act
      final result = await useCase.call(
        title: '  Valid Title  ',
        timeLimitMinutes: 30,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, testTask);
      verify(() => mockRepository.createTask(
            title: 'Valid Title',
            timeLimitMinutes: 30,
          )).called(1);
    });

    test('should return success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          )).thenAnswer((_) async => Result.success(testTask));

      // Act
      final result = await useCase.call(
        title: 'Valid Title',
        timeLimitMinutes: 30,
      );

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, testTask);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      when(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          )).thenAnswer((_) async => Result.failure('Failed to create task'));

      // Act
      final result = await useCase.call(
        title: 'Valid Title',
        timeLimitMinutes: 30,
      );

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Failed to create task');
    });

    test('should accept minimum valid time limit', () async {
      // Arrange
      when(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          )).thenAnswer((_) async => Result.success(testTask));

      // Act
      final result = await useCase.call(
        title: 'Valid Title',
        timeLimitMinutes: 1,
      );

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockRepository.createTask(
            title: 'Valid Title',
            timeLimitMinutes: 1,
          )).called(1);
    });

    test('should accept maximum valid time limit', () async {
      // Arrange
      when(() => mockRepository.createTask(
            title: any(named: 'title'),
            timeLimitMinutes: any(named: 'timeLimitMinutes'),
          )).thenAnswer((_) async => Result.success(testTask));

      // Act
      final result = await useCase.call(
        title: 'Valid Title',
        timeLimitMinutes: 120,
      );

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockRepository.createTask(
            title: 'Valid Title',
            timeLimitMinutes: 120,
          )).called(1);
    });
  });
}
