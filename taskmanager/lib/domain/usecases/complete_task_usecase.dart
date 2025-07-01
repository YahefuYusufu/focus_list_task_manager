import '../repositories/task_repository.dart';
import '../entities/result.dart';
import '../../models/task_model.dart';

class CompleteTaskUseCase {
  final TaskRepository repository;

  CompleteTaskUseCase(this.repository);

  Future<Result<Task>> call(int taskId) async {
    if (taskId <= 0) {
      return Result.failure('Invalid task ID');
    }

    return await repository.completeTask(taskId);
  }
}
