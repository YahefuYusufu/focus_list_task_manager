import 'package:taskmanager/models/task_response.dart';

import '../repositories/task_repository.dart';
import '../entities/result.dart';

class GetAllTasksUseCase {
  final TaskRepository repository;

  GetAllTasksUseCase(this.repository);

  Future<Result<TasksResponse>> call() async {
    return await repository.getAllTasks();
  }
}
