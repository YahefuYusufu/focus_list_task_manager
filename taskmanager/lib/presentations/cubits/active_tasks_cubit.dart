import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/domain/usecases/notification_usecases.dart';
import 'dart:async';
import '../../../models/task_model.dart';
import '../../../domain/usecases/get_all_tasks_usecase.dart';
import '../../../domain/usecases/create_task_usecase.dart';
import '../../../domain/usecases/complete_task_usecase.dart';
import '../../../domain/usecases/check_task_expiry_usecase.dart';

abstract class ActiveTasksState extends Equatable {
  const ActiveTasksState();

  @override
  List<Object?> get props => [];
}

class ActiveTasksInitial extends ActiveTasksState {}

class ActiveTasksLoading extends ActiveTasksState {}

class ActiveTasksLoaded extends ActiveTasksState {
  final List<Task> tasks;

  const ActiveTasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class ActiveTasksError extends ActiveTasksState {
  final String message;

  const ActiveTasksError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class ActiveTasksCubit extends Cubit<ActiveTasksState> {
  final GetAllTasksUseCase _getAllTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final CheckTaskExpiryUseCase _checkTaskExpiryUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  // Notification Use Cases
  final ScheduleTaskReminderUseCase _scheduleTaskReminderUseCase;
  final CancelTaskNotificationsUseCase _cancelTaskNotificationsUseCase;
  final ShowTaskCompletedUseCase _showTaskCompletedUseCase;

  Timer? _globalTimer;
  final Map<int, Timer> _taskTimers = {};

  ActiveTasksCubit({
    required GetAllTasksUseCase getAllTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required CompleteTaskUseCase completeTaskUseCase,
    required CheckTaskExpiryUseCase checkTaskExpiryUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    // Add notification use cases to constructor
    required ScheduleTaskReminderUseCase scheduleTaskReminderUseCase,
    required CancelTaskNotificationsUseCase cancelTaskNotificationsUseCase,
    required ShowTaskCompletedUseCase showTaskCompletedUseCase,
  })  : _getAllTasksUseCase = getAllTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _completeTaskUseCase = completeTaskUseCase,
        _checkTaskExpiryUseCase = checkTaskExpiryUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _scheduleTaskReminderUseCase = scheduleTaskReminderUseCase,
        _cancelTaskNotificationsUseCase = cancelTaskNotificationsUseCase,
        _showTaskCompletedUseCase = showTaskCompletedUseCase,
        super(ActiveTasksInitial());

  @override
  Future<void> close() {
    _globalTimer?.cancel();
    for (var timer in _taskTimers.values) {
      timer.cancel();
    }
    return super.close();
  }

  Future<void> loadActiveTasks() async {
    emit(ActiveTasksLoading());

    final result = await _getAllTasksUseCase();

    result.when(
      success: (tasksResponse) {
        final activeTasks = tasksResponse.active;
        emit(ActiveTasksLoaded(activeTasks));
        _startTimersForTasks(activeTasks);
      },
      failure: (error) {
        emit(ActiveTasksError(error));
      },
    );
  }

  Future<void> createTask({
    required String title,
    required int timeLimitMinutes,
  }) async {
    print('🚀 Starting task creation for: $title');

    final result = await _createTaskUseCase(
      title: title,
      timeLimitMinutes: timeLimitMinutes,
    );

    print('🔍 CreateTask result received');

    result.when(
      success: (newTask) async {
        print('🟢 DEBUG: createTask method called with title: $title'); // Add this line
        print('✅ SUCCESS CALLBACK REACHED!');
        print('🔍 New task data: ${newTask.toString()}');
        print('🔍 Task ID: ${newTask.id}');
        print('🔍 Task title: ${newTask.title}');

        // 🔔 Schedule notification for the new task
        try {
          print('🔔 About to schedule notification...');
          await _scheduleTaskReminderUseCase(newTask);
          print('🔔 Notification scheduled for task: $title');
        } catch (e) {
          print('⚠️ Failed to schedule notification: $e');
          print('⚠️ Error type: ${e.runtimeType}');
          print('⚠️ Full error: ${e.toString()}');
        }

        print('📱 About to reload active tasks...');
        // Reload active tasks to include the new one
        loadActiveTasks();
      },
      failure: (error) {
        print('❌ FAILURE CALLBACK REACHED!');
        print('❌ Error: $error');
        emit(ActiveTasksError(error));
      },
    );
  }

  // Support both String and int task IDs for backwards compatibility
  Future<void> completeTask(dynamic taskId) async {
    final id = taskId is String ? int.parse(taskId) : taskId as int;

    // Cancel timer for this task
    _taskTimers[id]?.cancel();
    _taskTimers.remove(id);

    final result = await _completeTaskUseCase(id);

    result.when(
      success: (completedTask) {
        // 🔔 Handle notifications for task completion
        try {
          _cancelTaskNotificationsUseCase(id);
          _showTaskCompletedUseCase(completedTask);
          print('🔔 Task completion notification sent');
        } catch (e) {
          print('⚠️ Failed to handle completion notifications: $e');
          // Don't fail task completion if notification fails
        }

        // Remove from active tasks immediately
        if (state is ActiveTasksLoaded) {
          final currentTasks = (state as ActiveTasksLoaded).tasks;
          final updatedTasks = currentTasks.where((task) => task.id != id).toList();
          emit(ActiveTasksLoaded(updatedTasks));
        }
      },
      failure: (error) {
        emit(ActiveTasksError(error));
      },
    );
  }

  void _startTimersForTasks(List<Task> tasks) {
    // Cancel existing timers
    for (var timer in _taskTimers.values) {
      timer.cancel();
    }
    _taskTimers.clear();

    // Start new timers for each active task
    for (final task in tasks) {
      final remainingSeconds = task.calculateRemainingSeconds();

      if (remainingSeconds > 0) {
        _taskTimers[task.id] = Timer.periodic(Duration(seconds: 1), (timer) {
          _updateTaskTimer(task.id);
        });
      } else {
        // Task already expired, move to missed
        _moveTaskToMissed(task.id);
      }
    }
  }

  void _updateTaskTimer(int taskId) async {
    if (state is ActiveTasksLoaded) {
      final currentTasks = (state as ActiveTasksLoaded).tasks;
      final taskIndex = currentTasks.indexWhere((task) => task.id == taskId);

      if (taskIndex != -1) {
        final task = currentTasks[taskIndex];
        final remainingSeconds = task.calculateRemainingSeconds();

        if (remainingSeconds <= 0) {
          // Timer expired, move to missed
          _moveTaskToMissed(taskId);
        } else {
          // Update remaining seconds
          final updatedTask = task.copyWithRemainingSeconds(remainingSeconds);
          final updatedTasks = List<Task>.from(currentTasks);
          updatedTasks[taskIndex] = updatedTask;
          emit(ActiveTasksLoaded(updatedTasks));
        }
      }
    }
  }

  void _moveTaskToMissed(int taskId) async {
    // Cancel timer
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);

    // 🔔 Cancel notifications for expired task
    try {
      _cancelTaskNotificationsUseCase(taskId);
      print('🔔 Notifications cancelled for expired task');
    } catch (e) {
      print('⚠️ Failed to cancel notifications for expired task: $e');
    }

    // Check expiry on backend (this will move it to missed status)
    await _checkTaskExpiryUseCase(taskId);

    // Remove from active tasks
    if (state is ActiveTasksLoaded) {
      final currentTasks = (state as ActiveTasksLoaded).tasks;
      final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
      emit(ActiveTasksLoaded(updatedTasks));
    }
  }

  // Support both String and int task IDs for backwards compatibility
  Future<void> deleteTask(dynamic taskId) async {
    final id = taskId is String ? int.parse(taskId) : taskId as int;

    // Cancel timer and notifications (active-specific cleanup)
    _taskTimers[id]?.cancel();
    _taskTimers.remove(id);
    await _cancelTaskNotificationsUseCase(id);

    // Use shared delete use case
    final result = await _deleteTaskUseCase(id);

    result.when(
      success: (_) {
        if (state is ActiveTasksLoaded) {
          final currentTasks = (state as ActiveTasksLoaded).tasks;
          final updatedTasks = currentTasks.where((task) => task.id != id).toList();
          emit(ActiveTasksLoaded(updatedTasks));
        }
      },
      failure: (error) => emit(ActiveTasksError(error)),
    );
  }
}
