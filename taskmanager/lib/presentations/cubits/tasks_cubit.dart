import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskmanager/core/service_locator.dart';
import '../../../models/task_model.dart';
import '../../../domain/usecases/get_all_tasks_usecase.dart';
import '../../../domain/usecases/create_task_usecase.dart';
import '../../../domain/usecases/complete_task_usecase.dart';
import '../../../domain/usecases/delete_task_usecase.dart';

// States
abstract class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoading extends TasksState {}

class TasksLoaded extends TasksState {
  final List<Task> activeTasks;
  final List<Task> completedTasks;
  final List<Task> missedTasks;

  const TasksLoaded({
    required this.activeTasks,
    required this.completedTasks,
    required this.missedTasks,
  });

  @override
  List<Object> get props => [activeTasks, completedTasks, missedTasks];

  TasksLoaded copyWith({
    List<Task>? activeTasks,
    List<Task>? completedTasks,
    List<Task>? missedTasks,
  }) {
    return TasksLoaded(
      activeTasks: activeTasks ?? this.activeTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      missedTasks: missedTasks ?? this.missedTasks,
    );
  }
}

class TasksError extends TasksState {
  final String message;

  const TasksError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class TasksCubit extends Cubit<TasksState> {
  final GetAllTasksUseCase _getAllTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  TasksCubit({
    GetAllTasksUseCase? getAllTasksUseCase,
    CreateTaskUseCase? createTaskUseCase,
    CompleteTaskUseCase? completeTaskUseCase,
    DeleteTaskUseCase? deleteTaskUseCase,
  })  : _getAllTasksUseCase = getAllTasksUseCase ?? ServiceLocator().get<GetAllTasksUseCase>(),
        _createTaskUseCase = createTaskUseCase ?? ServiceLocator().get<CreateTaskUseCase>(),
        _completeTaskUseCase = completeTaskUseCase ?? ServiceLocator().get<CompleteTaskUseCase>(),
        _deleteTaskUseCase = deleteTaskUseCase ?? ServiceLocator().get<DeleteTaskUseCase>(),
        super(TasksInitial());

  Future<void> loadTasks() async {
    emit(TasksLoading());

    final result = await _getAllTasksUseCase();

    result.when(
      success: (tasksResponse) {
        emit(TasksLoaded(
          activeTasks: tasksResponse.active,
          completedTasks: tasksResponse.completed,
          missedTasks: tasksResponse.missed,
        ));
      },
      failure: (error) {
        emit(TasksError(error));
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
        // Reload tasks to get updated state
        loadTasks();
      },
      failure: (error) {
        emit(TasksError(error));
      },
    );
  }

  Future<void> completeTask(int taskId) async {
    final result = await _completeTaskUseCase(taskId);

    result.when(
      success: (completedTask) {
        // Update local state immediately for better UX
        if (state is TasksLoaded) {
          final currentState = state as TasksLoaded;
          final updatedActiveTasks = currentState.activeTasks.where((task) => task.id != taskId).toList();
          final updatedCompletedTasks = [
            ...currentState.completedTasks,
            completedTask,
          ];

          emit(currentState.copyWith(
            activeTasks: updatedActiveTasks,
            completedTasks: updatedCompletedTasks,
          ));
        }
      },
      failure: (error) {
        emit(TasksError(error));
      },
    );
  }

  Future<void> deleteTask(int taskId) async {
    final result = await _deleteTaskUseCase(taskId);

    result.when(
      success: (_) {
        // Update local state immediately
        if (state is TasksLoaded) {
          final currentState = state as TasksLoaded;
          emit(currentState.copyWith(
            activeTasks: currentState.activeTasks.where((task) => task.id != taskId).toList(),
            completedTasks: currentState.completedTasks.where((task) => task.id != taskId).toList(),
            missedTasks: currentState.missedTasks.where((task) => task.id != taskId).toList(),
          ));
        }
      },
      failure: (error) {
        emit(TasksError(error));
      },
    );
  }

  void updateTaskTimer(int taskId, int remainingSeconds) {
    if (state is TasksLoaded) {
      final currentState = state as TasksLoaded;

      // If time expired, move to missed
      if (remainingSeconds <= 0) {
        final expiredTaskIndex = currentState.activeTasks.indexWhere((task) => task.id == taskId);

        if (expiredTaskIndex != -1) {
          final expiredTask = currentState.activeTasks[expiredTaskIndex];

          final updatedActiveTasks = currentState.activeTasks.where((task) => task.id != taskId).toList();

          final missedTask = expiredTask.copyWithRemainingSeconds(0);
          final updatedMissedTasks = [...currentState.missedTasks, missedTask];

          emit(currentState.copyWith(
            activeTasks: updatedActiveTasks,
            missedTasks: updatedMissedTasks,
          ));
        }
      } else {
        // Update remaining seconds
        final updatedActiveTasks = currentState.activeTasks.map((task) {
          if (task.id == taskId) {
            return task.copyWithRemainingSeconds(remainingSeconds);
          }
          return task;
        }).toList();

        emit(currentState.copyWith(activeTasks: updatedActiveTasks));
      }
    }
  }
}
