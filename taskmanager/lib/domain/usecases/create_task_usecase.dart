import '../repositories/task_repository.dart';
import '../entities/result.dart';
import '../../models/task_model.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Result<Task>> call({
    required String title,
    required int timeLimitMinutes,
  }) async {
    // Validation logic
    if (title.trim().isEmpty) {
      return Result.failure('Task title cannot be empty');
    }

    if (timeLimitMinutes < 1 || timeLimitMinutes > 120) {
      return Result.failure('Time limit must be between 1 and 120 minutes');
    }

    return await repository.createTask(
      title: title.trim(),
      timeLimitMinutes: timeLimitMinutes,
    );
  }
}
