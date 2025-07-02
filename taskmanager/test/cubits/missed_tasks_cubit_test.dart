import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/get_all_tasks_usecase.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/models/task_response.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';

// Mock classes
class MockGetAllTasksUseCase extends Mock implements GetAllTasksUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

void main() {
  late MissedTasksCubit cubit;
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    cubit = MissedTasksCubit(
      getAllTasksUseCase: mockGetAllTasksUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('MissedTasksCubit', () {
    final testTask1 = Task(
      id: 1,
      title: 'Missed Task 1',
      timeLimitMinutes: 30,
      status: TaskStatus.missed,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 0,
    );

    final testTask2 = Task(
      id: 2,
      title: 'Missed Task 2',
      timeLimitMinutes: 45,
      status: TaskStatus.missed,
      createdAt: '2025-07-02T09:00:00Z',
      expiresAt: '2025-07-02T09:45:00Z',
      remainingSeconds: 0,
    );

    final testTasksResponse = TasksResponse(
      active: [],
      completed: [],
      missed: [testTask1, testTask2],
    );

    test('initial state is MissedTasksInitial', () {
      expect(cubit.state, isA<MissedTasksInitial>());
    });

    group('loadMissedTasks', () {
      blocTest<MissedTasksCubit, MissedTasksState>(
        'emits [loading, loaded] when loadMissedTasks succeeds',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.success(testTasksResponse));
          return cubit;
        },
        act: (cubit) => cubit.loadMissedTasks(),
        expect: () => [
          MissedTasksLoading(),
          MissedTasksLoaded([testTask1, testTask2]),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'emits [loading, loaded] with empty list when no missed tasks',
        build: () {
          final emptyResponse = TasksResponse(
            active: [],
            completed: [],
            missed: [],
          );
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.success(emptyResponse));
          return cubit;
        },
        act: (cubit) => cubit.loadMissedTasks(),
        expect: () => [
          MissedTasksLoading(),
          MissedTasksLoaded([]),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'emits [loading, error] when loadMissedTasks fails',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.failure('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadMissedTasks(),
        expect: () => [
          MissedTasksLoading(),
          MissedTasksError('Network error'),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'emits [loading, error] when repository throws exception',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenThrow(Exception('Unexpected error'));
          return cubit;
        },
        act: (cubit) => cubit.loadMissedTasks(),
        expect: () => [
          MissedTasksLoading(),
        ],
        errors: () => [
          isA<Exception>(),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );
    });

    group('addMissedTask', () {
      final newTask = Task(
        id: 3,
        title: 'New Missed Task',
        timeLimitMinutes: 60,
        status: TaskStatus.missed,
        createdAt: '2025-07-02T08:00:00Z',
        expiresAt: '2025-07-02T09:00:00Z',
        remainingSeconds: 0,
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'adds task to missed list when state is loaded',
        build: () => cubit,
        seed: () => MissedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.addMissedTask(newTask),
        expect: () => [
          MissedTasksLoaded([testTask1, testTask2, newTask]),
        ],
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'adds task to empty missed list',
        build: () => cubit,
        seed: () => MissedTasksLoaded([]),
        act: (cubit) => cubit.addMissedTask(newTask),
        expect: () => [
          MissedTasksLoaded([newTask]),
        ],
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'does nothing when state is not loaded',
        build: () => cubit,
        seed: () => MissedTasksInitial(),
        act: (cubit) => cubit.addMissedTask(newTask),
        expect: () => [],
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'does nothing when state is loading',
        build: () => cubit,
        seed: () => MissedTasksLoading(),
        act: (cubit) => cubit.addMissedTask(newTask),
        expect: () => [],
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'does nothing when state is error',
        build: () => cubit,
        seed: () => MissedTasksError('Some error'),
        act: (cubit) => cubit.addMissedTask(newTask),
        expect: () => [],
      );
    });

    group('deleteTask', () {
      blocTest<MissedTasksCubit, MissedTasksState>(
        'removes task from list when deletion succeeds',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => MissedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [
          MissedTasksLoaded([testTask2]), // Task 1 removed
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'removes correct task when multiple tasks exist',
        build: () {
          when(() => mockDeleteTaskUseCase.call(2)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => MissedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(2),
        expect: () => [
          MissedTasksLoaded([testTask1]), // Task 2 removed
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(2)).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'handles deletion of non-existent task gracefully',
        build: () {
          when(() => mockDeleteTaskUseCase.call(999)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => MissedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(999),
        expect: () => [], // No state change since task doesn't exist in list
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(999)).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'emits error when deletion fails',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.failure('Task not found'));
          return cubit;
        },
        seed: () => MissedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [
          MissedTasksError('Task not found'),
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'emits error when use case throws exception',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenThrow(Exception('Network error'));
          return cubit;
        },
        seed: () => MissedTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [],
        errors: () => [
          isA<Exception>(),
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'calls delete use case but maintains state when not loaded',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => MissedTasksInitial(),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<MissedTasksCubit, MissedTasksState>(
        'handles deletion from empty list',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          return cubit;
        },
        seed: () => MissedTasksLoaded([]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [], // No state change since list is already empty
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );
    });

    group('state equality', () {
      test('MissedTasksLoaded states with same tasks are equal', () {
        final state1 = MissedTasksLoaded([testTask1, testTask2]);
        final state2 = MissedTasksLoaded([testTask1, testTask2]);
        expect(state1, equals(state2));
      });

      test('MissedTasksError states with same message are equal', () {
        final state1 = MissedTasksError('Error message');
        final state2 = MissedTasksError('Error message');
        expect(state1, equals(state2));
      });

      test('different MissedTasksLoaded states are not equal', () {
        final state1 = MissedTasksLoaded([testTask1]);
        final state2 = MissedTasksLoaded([testTask2]);
        expect(state1, isNot(equals(state2)));
      });
    });
  });
}
