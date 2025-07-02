import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskmanager/domain/usecases/get_all_tasks_usecase.dart';
import 'package:taskmanager/domain/usecases/create_task_usecase.dart';
import 'package:taskmanager/domain/usecases/complete_task_usecase.dart';
import 'package:taskmanager/domain/usecases/check_task_expiry_usecase.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/domain/usecases/notification_usecases.dart';
import 'package:taskmanager/domain/entities/result.dart';
import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/models/task_response.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';

// Mock classes
class MockGetAllTasksUseCase extends Mock implements GetAllTasksUseCase {}

class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}

class MockCompleteTaskUseCase extends Mock implements CompleteTaskUseCase {}

class MockCheckTaskExpiryUseCase extends Mock implements CheckTaskExpiryUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

class MockScheduleTaskReminderUseCase extends Mock implements ScheduleTaskReminderUseCase {}

class MockCancelTaskNotificationsUseCase extends Mock implements CancelTaskNotificationsUseCase {}

class MockShowTaskCompletedUseCase extends Mock implements ShowTaskCompletedUseCase {}

// Fake classes for mocktail
class FakeTask extends Fake implements Task {}

void main() {
  late ActiveTasksCubit cubit;
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockCompleteTaskUseCase mockCompleteTaskUseCase;
  late MockCheckTaskExpiryUseCase mockCheckTaskExpiryUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late MockScheduleTaskReminderUseCase mockScheduleTaskReminderUseCase;
  late MockCancelTaskNotificationsUseCase mockCancelTaskNotificationsUseCase;
  late MockShowTaskCompletedUseCase mockShowTaskCompletedUseCase;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockCompleteTaskUseCase = MockCompleteTaskUseCase();
    mockCheckTaskExpiryUseCase = MockCheckTaskExpiryUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    mockScheduleTaskReminderUseCase = MockScheduleTaskReminderUseCase();
    mockCancelTaskNotificationsUseCase = MockCancelTaskNotificationsUseCase();
    mockShowTaskCompletedUseCase = MockShowTaskCompletedUseCase();

    cubit = ActiveTasksCubit(
      getAllTasksUseCase: mockGetAllTasksUseCase,
      createTaskUseCase: mockCreateTaskUseCase,
      completeTaskUseCase: mockCompleteTaskUseCase,
      checkTaskExpiryUseCase: mockCheckTaskExpiryUseCase,
      deleteTaskUseCase: mockDeleteTaskUseCase,
      scheduleTaskReminderUseCase: mockScheduleTaskReminderUseCase,
      cancelTaskNotificationsUseCase: mockCancelTaskNotificationsUseCase,
      showTaskCompletedUseCase: mockShowTaskCompletedUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ActiveTasksCubit', () {
    final testTask1 = Task(
      id: 1,
      title: 'Active Task 1',
      timeLimitMinutes: 30,
      status: TaskStatus.active,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:30:00Z',
      remainingSeconds: 1800,
    );

    final testTask2 = Task(
      id: 2,
      title: 'Active Task 2',
      timeLimitMinutes: 45,
      status: TaskStatus.active,
      createdAt: '2025-07-02T10:00:00Z',
      expiresAt: '2025-07-02T10:45:00Z',
      remainingSeconds: 2700,
    );

    final testTasksResponse = TasksResponse(
      active: [testTask1, testTask2],
      completed: [],
      missed: [],
    );

    test('initial state is ActiveTasksInitial', () {
      expect(cubit.state, isA<ActiveTasksInitial>());
    });

    group('loadActiveTasks', () {
      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'emits [loading, loaded] when loadActiveTasks succeeds',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.success(testTasksResponse));
          return cubit;
        },
        act: (cubit) => cubit.loadActiveTasks(),
        expect: () => [
          ActiveTasksLoading(),
          ActiveTasksLoaded([testTask1, testTask2]),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'emits [loading, error] when loadActiveTasks fails',
        build: () {
          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.failure('Network error'));
          return cubit;
        },
        act: (cubit) => cubit.loadActiveTasks(),
        expect: () => [
          ActiveTasksLoading(),
          ActiveTasksError('Network error'),
        ],
        verify: (_) {
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );
    });

    group('createTask', () {
      final newTask = Task(
        id: 3,
        title: 'New Task',
        timeLimitMinutes: 60,
        status: TaskStatus.active,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T11:00:00Z',
        remainingSeconds: 3600,
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'creates task and schedules notification when successful',
        build: () {
          when(() => mockCreateTaskUseCase.call(
                title: any(named: 'title'),
                timeLimitMinutes: any(named: 'timeLimitMinutes'),
              )).thenAnswer((_) async => Result.success(newTask));

          when(() => mockScheduleTaskReminderUseCase.call(any())).thenAnswer((_) async {});

          when(() => mockGetAllTasksUseCase.call()).thenAnswer((_) async => Result.success(testTasksResponse));
          return cubit;
        },
        act: (cubit) => cubit.createTask(
          title: 'New Task',
          timeLimitMinutes: 60,
        ),
        expect: () => [
          ActiveTasksLoading(),
          ActiveTasksLoaded([testTask1, testTask2]),
        ],
        verify: (_) {
          verify(() => mockCreateTaskUseCase.call(
                title: 'New Task',
                timeLimitMinutes: 60,
              )).called(1);
          verify(() => mockScheduleTaskReminderUseCase.call(newTask)).called(1);
          verify(() => mockGetAllTasksUseCase.call()).called(1);
        },
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'emits error when createTask fails',
        build: () {
          when(() => mockCreateTaskUseCase.call(
                title: any(named: 'title'),
                timeLimitMinutes: any(named: 'timeLimitMinutes'),
              )).thenAnswer((_) async => Result.failure('Failed to create task'));
          return cubit;
        },
        act: (cubit) => cubit.createTask(
          title: 'New Task',
          timeLimitMinutes: 60,
        ),
        expect: () => [
          ActiveTasksError('Failed to create task'),
        ],
        verify: (_) {
          verify(() => mockCreateTaskUseCase.call(
                title: 'New Task',
                timeLimitMinutes: 60,
              )).called(1);
          verifyNever(() => mockScheduleTaskReminderUseCase.call(any()));
        },
      );
    });

    group('completeTask', () {
      final completedTask = Task(
        id: 1,
        title: 'Completed Task',
        timeLimitMinutes: 30,
        status: TaskStatus.completed,
        createdAt: '2025-07-02T10:00:00Z',
        expiresAt: '2025-07-02T10:30:00Z',
        remainingSeconds: 0,
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'completes task and handles notifications when successful',
        build: () {
          when(() => mockCompleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(completedTask));
          when(() => mockCancelTaskNotificationsUseCase.call(1)).thenAnswer((_) async {});
          when(() => mockShowTaskCompletedUseCase.call(any())).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => ActiveTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.completeTask(1),
        expect: () => [
          ActiveTasksLoaded([testTask2]), // Task 1 removed
        ],
        verify: (_) {
          verify(() => mockCompleteTaskUseCase.call(1)).called(1);
          verify(() => mockCancelTaskNotificationsUseCase.call(1)).called(1);
          verify(() => mockShowTaskCompletedUseCase.call(completedTask)).called(1);
        },
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'handles String taskId correctly',
        build: () {
          when(() => mockCompleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(completedTask));
          when(() => mockCancelTaskNotificationsUseCase.call(1)).thenAnswer((_) async {});
          when(() => mockShowTaskCompletedUseCase.call(any())).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => ActiveTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.completeTask('1'), // String ID
        expect: () => [
          ActiveTasksLoaded([testTask2]),
        ],
        verify: (_) {
          verify(() => mockCompleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'emits error when completeTask fails',
        build: () {
          when(() => mockCompleteTaskUseCase.call(1)).thenAnswer((_) async => Result.failure('Task already completed'));
          return cubit;
        },
        seed: () => ActiveTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.completeTask(1),
        expect: () => [
          ActiveTasksError('Task already completed'),
        ],
        verify: (_) {
          verify(() => mockCompleteTaskUseCase.call(1)).called(1);
        },
      );
    });

    group('deleteTask', () {
      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'deletes task and cancels notifications when successful',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          when(() => mockCancelTaskNotificationsUseCase.call(1)).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => ActiveTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [
          ActiveTasksLoaded([testTask2]), // Task 1 removed
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
          verify(() => mockCancelTaskNotificationsUseCase.call(1)).called(1);
        },
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'handles String taskId correctly',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.success(null));
          when(() => mockCancelTaskNotificationsUseCase.call(1)).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => ActiveTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask('1'), // String ID
        expect: () => [
          ActiveTasksLoaded([testTask2]),
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
        },
      );

      blocTest<ActiveTasksCubit, ActiveTasksState>(
        'emits error when deleteTask fails',
        build: () {
          when(() => mockDeleteTaskUseCase.call(1)).thenAnswer((_) async => Result.failure('Task not found'));
          when(() => mockCancelTaskNotificationsUseCase.call(1)).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => ActiveTasksLoaded([testTask1, testTask2]),
        act: (cubit) => cubit.deleteTask(1),
        expect: () => [
          ActiveTasksError('Task not found'),
        ],
        verify: (_) {
          verify(() => mockDeleteTaskUseCase.call(1)).called(1);
          verify(() => mockCancelTaskNotificationsUseCase.call(1)).called(1);
        },
      );
    });
  });
}
