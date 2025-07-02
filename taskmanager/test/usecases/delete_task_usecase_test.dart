import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/domain/entities/result.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late DeleteTaskUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = DeleteTaskUseCase(mockRepository);
  });

  group('DeleteTaskUseCase', () {
    test('should return failure when taskId is 0', () async {
      // Act
      final result = await useCase.call(0);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Invalid task ID');
      verifyNever(() => mockRepository.deleteTask(any()));
    });

    test('should return failure when taskId is negative', () async {
      // Act
      final result = await useCase.call(-1);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Invalid task ID');
      verifyNever(() => mockRepository.deleteTask(any()));
    });

    test('should return success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.deleteTask(1)).thenAnswer((_) async => Result.success(null));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isSuccess, true);
      verify(() => mockRepository.deleteTask(1)).called(1);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      when(() => mockRepository.deleteTask(1)).thenAnswer((_) async => Result.failure('Failed to delete task'));

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Failed to delete task');
      verify(() => mockRepository.deleteTask(1)).called(1);
    });
  });
}
