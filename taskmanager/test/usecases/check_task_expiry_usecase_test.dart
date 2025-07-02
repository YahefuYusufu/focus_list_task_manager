import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/check_task_expiry_usecase.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CheckTaskExpiryUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = CheckTaskExpiryUseCase(mockRepository);
  });

  group('CheckTaskExpiryUseCase', () {
    final testTask = Task(
      id: 1,
      title: 'Test Task',
      timeLimitMinutes: 30,
      status: TaskStatus.active,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 1800,
    );

    test('should return failure when taskId is 0', () async {
      // Act
      final result = await useCase.call(0);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Invalid task ID');
      verifyNever(() => mockRepository.checkTaskExpiry(any()));
    });

    test('should return failure when taskId is negative', () async {
      // Act
      final result = await useCase.call(-1);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Invalid task ID');
      verifyNever(() => mockRepository.checkTaskExpiry(any()));
    });

    test('should return success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.checkTaskExpiry(1)).thenAnswer((_) async => Result.success(testTask));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, testTask);
      verify(() => mockRepository.checkTaskExpiry(1)).called(1);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      when(() => mockRepository.checkTaskExpiry(1)).thenAnswer((_) async => Result.failure('Task not found'));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Task not found');
      verify(() => mockRepository.checkTaskExpiry(1)).called(1);
    });
  });
}
