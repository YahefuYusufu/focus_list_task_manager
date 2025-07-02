import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/get_task_stats_usecase.dart';
import 'package:taskmanager/domain/repositories/task_repository.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_response.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetTaskStatsUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = GetTaskStatsUseCase(mockRepository);
  });

  group('GetTaskStatsUseCase', () {
    final testStatsResponse = TaskStatsResponse(
      totalTasks: 10,
      activeTasks: 3,
      completedTasks: 5,
      missedTasks: 2,
    );

    test('should return success when repository call succeeds', () async {
      // Arrange
      when(() => mockRepository.getTaskStats()).thenAnswer((_) async => Result.success(testStatsResponse));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, testStatsResponse);
      expect(result.data!.totalTasks, 10);
      expect(result.data!.activeTasks, 3);
      expect(result.data!.completedTasks, 5);
      expect(result.data!.missedTasks, 2);
      verify(() => mockRepository.getTaskStats()).called(1);
    });

    test('should return success with zero stats when no tasks exist', () async {
      // Arrange
      final emptyStatsResponse = TaskStatsResponse(
        totalTasks: 0,
        activeTasks: 0,
        completedTasks: 0,
        missedTasks: 0,
      );
      when(() => mockRepository.getTaskStats()).thenAnswer((_) async => Result.success(emptyStatsResponse));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data!.totalTasks, 0);
      expect(result.data!.activeTasks, 0);
      expect(result.data!.completedTasks, 0);
      expect(result.data!.missedTasks, 0);
      verify(() => mockRepository.getTaskStats()).called(1);
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      when(() => mockRepository.getTaskStats()).thenAnswer((_) async => Result.failure('Failed to fetch stats'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isFailure, true);
      expect(result.error, 'Failed to fetch stats');
      verify(() => mockRepository.getTaskStats()).called(1);
    });

    test('should verify stats calculation consistency', () async {
      // Arrange
      final consistentStatsResponse = TaskStatsResponse(
        totalTasks: 15,
        activeTasks: 6,
        completedTasks: 7,
        missedTasks: 2,
      );
      when(() => mockRepository.getTaskStats()).thenAnswer((_) async => Result.success(consistentStatsResponse));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isSuccess, true);
      final stats = result.data!;
      // Verify that active + completed + missed = total
      expect(stats.activeTasks + stats.completedTasks + stats.missedTasks, stats.totalTasks);
      verify(() => mockRepository.getTaskStats()).called(1);
    });
  });
}
