import 'package:taskmanager/models/task_response.dart';

import '../repositories/task_repository.dart';
import '../entities/result.dart';

class GetTaskStatsUseCase {
  final TaskRepository repository;

  GetTaskStatsUseCase(this.repository);

  Future<Result<TaskStatsResponse>> call() async {
    return await repository.getTaskStats();
  }
}
