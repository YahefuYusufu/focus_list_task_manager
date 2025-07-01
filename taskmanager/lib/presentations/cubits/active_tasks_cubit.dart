import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
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

  Timer? _globalTimer;
  final Map<int, Timer> _taskTimers = {};

  ActiveTasksCubit({
    required GetAllTasksUseCase getAllTasksUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required CompleteTaskUseCase completeTaskUseCase,
    required CheckTaskExpiryUseCase checkTaskExpiryUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getAllTasksUseCase = getAllTasksUseCase,
        _createTaskUseCase = createTaskUseCase,
        _completeTaskUseCase = completeTaskUseCase,
        _checkTaskExpiryUseCase = checkTaskExpiryUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
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
    final result = await _createTaskUseCase(
      title: title,
      timeLimitMinutes: timeLimitMinutes,
    );

    result.when(
      success: (newTask) {
        // Reload active tasks to include the new one
        loadActiveTasks();
      },
      failure: (error) {
        emit(ActiveTasksError(error));
      },
    );
  }

  Future<void> completeTask(int taskId) async {
    // Cancel timer for this task
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);

    final result = await _completeTaskUseCase(taskId);

    result.when(
      success: (completedTask) {
        // Remove from active tasks immediately
        if (state is ActiveTasksLoaded) {
          final currentTasks = (state as ActiveTasksLoaded).tasks;
          final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
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

    // Check expiry on backend (this will move it to missed status)
    await _checkTaskExpiryUseCase(taskId);

    // Remove from active tasks
    if (state is ActiveTasksLoaded) {
      final currentTasks = (state as ActiveTasksLoaded).tasks;
      final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
      emit(ActiveTasksLoaded(updatedTasks));
    }
  }

  Future<void> deleteTask(int taskId) async {
    // Cancel timer for this task
    _taskTimers[taskId]?.cancel();
    _taskTimers.remove(taskId);

    final result = await _deleteTaskUseCase(taskId);

    result.when(
      success: (_) {
        // Remove from active tasks immediately
        if (state is ActiveTasksLoaded) {
          final currentTasks = (state as ActiveTasksLoaded).tasks;
          final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
          emit(ActiveTasksLoaded(updatedTasks));
        }
      },
      failure: (error) {
        emit(ActiveTasksError(error));
      },
    );
  }
}
