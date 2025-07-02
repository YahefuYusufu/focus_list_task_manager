import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/complete_task_usecase.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CompleteTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = CompleteTaskUseCase(mockRepository);
  });

  group('CompleteTaskUseCase', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      timeLimitMinutes: 30,
      status: TaskStatus.completed,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 0,
    );

    test('should return failure when taskId is 0', () async {
      // Act
      final result = await useCase.call(0);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Invalid task ID');
      verifyNever(() => mockRepository.completeTask(any()));
    });

    test('should return failure when taskId is negative', () async {
      // Act
      final result = await useCase.call(-1);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Invalid task ID');
      verifyNever(() => mockRepository.completeTask(any()));
    });

    test('should return success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.completeTask(1)).thenAnswer((_) async => Result.success(testTask));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, testTask);
      verify(() => mockRepository.completeTask(1)).called(1);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      when(() => mockRepository.completeTask(1)).thenAnswer((_) async => Result.failure('Failed to complete task'));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Failed to complete task');
      verify(() => mockRepository.completeTask(1)).called(1);
    });
  });
}
