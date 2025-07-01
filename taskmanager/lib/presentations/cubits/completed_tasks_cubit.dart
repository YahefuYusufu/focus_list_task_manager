import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import '../../../models/task_model.dart';
import '../../../domain/usecases/get_all_tasks_usecase.dart';

// States
abstract class CompletedTasksState extends Equatable {
  const CompletedTasksState();

  @override
  List<Object?> get props => [];
}

class CompletedTasksInitial extends CompletedTasksState {}

class CompletedTasksLoading extends CompletedTasksState {}

class CompletedTasksLoaded extends CompletedTasksState {
  final List<Task> tasks;

  const CompletedTasksLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class CompletedTasksError extends CompletedTasksState {
  final String message;

  const CompletedTasksError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class CompletedTasksCubit extends Cubit<CompletedTasksState> {
  final GetAllTasksUseCase _getAllTasksUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  CompletedTasksCubit({
    required GetAllTasksUseCase getAllTasksUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
  })  : _getAllTasksUseCase = getAllTasksUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        super(CompletedTasksInitial());

  Future<void> loadCompletedTasks() async {
    emit(CompletedTasksLoading());

    final result = await _getAllTasksUseCase();

    result.when(
      success: (tasksResponse) {
        emit(CompletedTasksLoaded(tasksResponse.completed));
      },
      failure: (error) {
        emit(CompletedTasksError(error));
      },
    );
  }

  void addCompletedTask(Task task) {
    if (state is CompletedTasksLoaded) {
      final currentTasks = (state as CompletedTasksLoaded).tasks;
      final updatedTasks = [...currentTasks, task];
      emit(CompletedTasksLoaded(updatedTasks));
    }
  }

  Future<void> deleteTask(int taskId) async {
    print('🗑️ CUBIT: Starting delete for task ID: $taskId');

    final result = await _deleteTaskUseCase(taskId);

    print('🗑️ CUBIT: Delete result: $result');

    result.when(
      success: (_) {
        print('✅ CUBIT: Delete successful, updating UI');

        if (state is CompletedTasksLoaded) {
          final currentTasks = (state as CompletedTasksLoaded).tasks;
          print('🔍 CUBIT: Current tasks count: ${currentTasks.length}');

          final updatedTasks = currentTasks.where((task) => task.id != taskId).toList();
          print('🔍 CUBIT: Updated tasks count: ${updatedTasks.length}');

          emit(CompletedTasksLoaded(updatedTasks));
          print('✅ CUBIT: UI updated successfully');
        } else {
          print('⚠️ CUBIT: State is not CompletedTasksLoaded: ${state.runtimeType}');
        }
      },
      failure: (error) {
        print('❌ CUBIT: Delete failed: $error');
        emit(CompletedTasksError(error));
      },
    );
  }
}
