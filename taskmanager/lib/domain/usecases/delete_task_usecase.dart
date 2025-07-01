import '../repositories/task_repository.dart';
import '../entities/result.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Result<void>> call(int taskId) async {
    if (taskId <= 0) {
      return Result.failure('Invalid task ID');
    }

    return await repository.deleteTask(taskId);
  }
}
