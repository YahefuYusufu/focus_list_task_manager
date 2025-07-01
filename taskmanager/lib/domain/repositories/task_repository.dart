import 'package:taskmanager/models/task_response.dart';

import '../entities/result.dart';
import '../../models/task_model.dart';

abstract class TaskRepository {
  Future<Result<bool>> checkHealth();
  Future<Result<TasksResponse>> getAllTasks();
  Future<Result<Task>> getTask(int taskId);
  Future<Result<Task>> createTask({
    required String title,
    required int timeLimitMinutes,
  });
  Future<Result<Task>> completeTask(int taskId);
  Future<Result<Task>> checkTaskExpiry(int taskId);
  Future<Result<void>> deleteTask(int taskId);
  Future<Result<TaskStatsResponse>> getTaskStats();
}
