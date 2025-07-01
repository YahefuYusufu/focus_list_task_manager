import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import '../../../models/task_model.dart';
import '../../../domain/usecases/get_all_tasks_usecase.dart';

// States
abstract class MissedTasksState extends Equatable {
  const MissedTasksState();

  @override
  List<Object?> get props => [];
}

class MissedTasksInitial extends MissedTasksState {}

class MissedTasksLoading extends MissedTasksState {}

class MissedTasksLoaded extends MissedTasksState {
  final List<Task> tasks;

  const MissedTasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class MissedTasksError extends MissedTasksState {
  final String message;

  const MissedTasksError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class MissedTasksCubit extends Cubit<MissedTasksState> {
  final GetAllTasksUseCase _getAllTasksUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  MissedTasksCubit({
    required GetAllTasksUseCase getAllTasksUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getAllTasksUseCase = getAllTasksUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(MissedTasksInitial());

  Future<void> loadMissedTasks() async {
    emit(MissedTasksLoading());

    final result = await _getAllTasksUseCase();

    result.when(
      success: (tasksResponse) {
        emit(MissedTasksLoaded(tasksResponse.missed));
      },
      failure: (error) {
        emit(MissedTasksError(error));
      },
    );
  }

  void addMissedTask(Task task) {
    if (state is MissedTasksLoaded) {
      final currentTasks = (state as MissedTasksLoaded).tasks;
      final updatedTasks = [...currentTasks, task];
      emit(MissedTasksLoaded(updatedTasks));
    }
  }

  Future<void> deleteTask(int taskId) async {
    final result = await _deleteTaskUseCase(taskId);

    result.when(
      success: (_) {
        if (state is MissedTasksLoaded) {
          final currentTasks = (state as MissedTasksLoaded).tasks;
          final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
          emit(MissedTasksLoaded(updatedTasks));
        }
      },
      failure: (error) => emit(MissedTasksError(error)),
    );
  }
}
