import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/task_model.dart';
import '../../../domain/usecases/create_task_usecase.dart';

// States
abstract class AddTaskState extends Equatable {
  const AddTaskState();

  @override
  List<Object?> get props => [];
}

class AddTaskInitial extends AddTaskState {}

class AddTaskLoading extends AddTaskState {}

class AddTaskSuccess extends AddTaskState {
  final Task createdTask;

  const AddTaskSuccess(this.createdTask);

  @override
  List<Object> get props => [createdTask];
}

class AddTaskError extends AddTaskState {
  final String message;

  const AddTaskError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class AddTaskCubit extends Cubit<AddTaskState> {
  final CreateTaskUseCase _createTaskUseCase;

  AddTaskCubit({required CreateTaskUseCase createTaskUseCase})
      : _createTaskUseCase = createTaskUseCase,
        super(AddTaskInitial());

  Future<void> createTask({
    required String title,
    required int timeLimitMinutes,
  }) async {
    emit(AddTaskLoading());

    final result = await _createTaskUseCase(
      title: title,
      timeLimitMinutes: timeLimitMinutes,
    );

    result.when(
      success: (task) => emit(AddTaskSuccess(task)),
      failure: (error) => emit(AddTaskError(error)),
    );
  }
}
