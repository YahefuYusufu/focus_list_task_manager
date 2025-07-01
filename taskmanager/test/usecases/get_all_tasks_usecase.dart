import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/domain/usecases/get_all_tasks_usecase.dart';
import 'package:taskmanager/models/task_response.dart';
import 'package:taskmanager/models/task_model.dart';

import '../mock/mock_task_repository.dart';

void main() {
  late GetAllTasksUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = GetAllTasksUseCase(mockRepository);
  });

  group('GetAllTasksUseCase', () {
    test('returns TasksResponse on success', () async {
      // Arrange
      final now = DateTime.now();
      final mockTask = Task(
        id: 1,
        title: 'Mock Task',
        timeLimitMinutes: 30,
        createdAt: now.toIso8601String(),
        expiresAt: now.add(Duration(minutes: 30)).toIso8601String(),
        status: TaskStatus.active,
        remainingSeconds: 1800,
      );

      final mockTasksResponse = TasksResponse(
        active: [mockTask],
        completed: [],
        missed: [],
      );

      when(mockRepository.getAllTasks()).thenAnswer((_) async => Result.success(mockTasksResponse));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, isA<TasksResponse>());
      expect(result.data!.active.length, 1);
      expect(result.data!.active.first.title, 'Mock Task');
      expect(result.data!.active.first.status, 'active');
    });

    test('returns failure on error', () async {
      // Arrange
      final error = Exception('Failed to fetch tasks');
      when(mockRepository.getAllTasks()).thenAnswer((_) async => Result.failure(error as String));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isSuccess, false);
      expect(result.error, error);
    });
  });
}
