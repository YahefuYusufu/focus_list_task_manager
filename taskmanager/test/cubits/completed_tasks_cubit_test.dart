import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:taskmanager/domain/usecases/get_all_tasks_usecase.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/models/task_response.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';

// Mock classes
class MockGetAllTasksUseCase extends Mock implements GetAllTasksUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  late CompletedTasksCubit cubit;
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    cubit = CompletedTasksCubit(
      getAllTasksUseCase: mockGetAllTasksUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('CompletedTasksCubit', () {
    final testTask1 = Task(
      id: 1,
      title: 'Completed Task 1',
      timeLimitMinutes: 30,
      status: TaskStatus.completed,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 0,
    );

    final testTask2 = Task(
      id: 2,
      title: 'Completed Task 2',
      timeLimitMinutes: 45,
      status: TaskStatus.completed,
      createdAt: '2025-07-02T09:00:00Z',
      expiresAt: '2025-07-02T09:45:00Z',
      remainingSeconds: 0,
    );

    final testTasksResponse = TasksResponse(
      active: [],
      completed: [testTask1, testTask2],
      missed: [],
    );

    test('initial state is CompletedTasksInitial', () {
      expect(cubit.state, isA<CompletedTasksInitial>());
    });

    group('loadCompletedTasks', () {
      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'emits [loading, loaded] when loadCompletedTasks succeeds',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.success(testTasksResponse));
          return cubit;
        },
        act: (cubit) => cubit.loadCompletedTasks(),
        expect: () => [
          CompletedTasksLoading(),
          CompletedTasksLoaded([testTask1, testTask2]),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'emits [loading, loaded] with empty list when no completed tasks',
        build: () {
          final emptyResponse = TasksResponse(
            active: [],
            completed: [],
            missed: [],
          );
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.success(emptyResponse));
          return cubit;
        },
        act: (cubit) => cubit.loadCompletedTasks(),
        expect: () => [
          CompletedTasksLoading(),
          CompletedTasksLoaded([]),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'emits [loading, error] when loadCompletedTasks fails',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.failure('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadCompletedTasks(),
        expect: () => [
          CompletedTasksLoading(),
          CompletedTasksError('Network error'),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'emits [loading, error] when repository throws exception',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenThrow(Exception('Unexpected error'));
          return cubit;
        },
        act: (cubit) => cubit.loadCompletedTasks(),
        expect: () => [
          CompletedTasksLoading(),
        ],
        errors: () => [
          isA<Exception>(),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );
    });

    group('addCompletedTask', () {
      final newTask = Task(
        id: 3,
        title: 'New Completed Task',
        timeLimitMinutes: 60,
        status: TaskStatus.completed,
        createdAt: '2025-07-02T08:00:00Z',
        expiresAt: '2025-07-02T09:00:00Z',
        remainingSeconds: 0,
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'adds task to completed list when state is loaded',
        build: () => cubit,
        seed: () => CompletedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.addCompletedTask(newTask),
        expect: () => [
          CompletedTasksLoaded([testTask1, testTask2, newTask]),
        ],
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'adds task to empty completed list',
        build: () => cubit,
        seed: () => CompletedTasksLoaded([]),
        act: (cubit) => cubit.addCompletedTask(newTask),
        expect: () => [
          CompletedTasksLoaded([newTask]),
        ],
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'does nothing when state is not loaded',
        build: () => cubit,
        seed: () => CompletedTasksInitial(),
        act: (cubit) => cubit.addCompletedTask(newTask),
        expect: () => [],
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'does nothing when state is loading',
        build: () => cubit,
        seed: () => CompletedTasksLoading(),
        act: (cubit) => cubit.addCompletedTask(newTask),
        expect: () => [],
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'does nothing when state is error',
        build: () => cubit,
        seed: () => CompletedTasksError('Some error'),
        act: (cubit) => cubit.addCompletedTask(newTask),
        expect: () => [],
      );
    });

    group('deleteTask', () {
      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'removes task from list when deletion succeeds',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => CompletedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [
          CompletedTasksLoaded([testTask2]), // Task 1 removed
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'removes correct task when multiple tasks exist',
        build: () {
          when(() => mockDeleteTaskUseCase.call(2)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => CompletedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(2),
        expect: () => [
          CompletedTasksLoaded([testTask1]), // Task 2 removed
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(2)).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'handles deletion of non-existent task gracefully',
        build: () {
          when(() => mockDeleteTaskUseCase.call(999)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => CompletedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(999),
        expect: () => [], // No state change since task doesn't exist in list
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(999)).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'emits error when deletion fails',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.failure('Task not found'));
          return cubit;
        },
        seed: () => CompletedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [
          CompletedTasksError('Task not found'),
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'emits error when use case throws exception',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenThrow(Exception('Network error'));
          return cubit;
        },
        seed: () => CompletedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [],
        errors: () => [
          isA<Exception>(),
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'calls delete use case but maintains state when not loaded',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => CompletedTasksInitial(),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<CompletedTasksCubit, CompletedTasksState>(
        'handles deletion from empty list',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => CompletedTasksLoaded([]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [], // No state change since list is already empty
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );
    });

    group('state equality', () {
      test('CompletedTasksLoaded states with same tasks are equal', () {
        final state1 = CompletedTasksLoaded([testTask1, testTask2]);
        final state2 = CompletedTasksLoaded([testTask1, testTask2]);
        expect(state1, equals(state2));
      });

      test('CompletedTasksError states with same message are equal', () {
        final state1 = CompletedTasksError('Error message');
        final state2 = CompletedTasksError('Error message');
        expect(state1, equals(state2));
      });

      test('different CompletedTasksLoaded states are not equal', () {
        final state1 = CompletedTasksLoaded([testTask1]);
        final state2 = CompletedTasksLoaded([testTask2]);
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
