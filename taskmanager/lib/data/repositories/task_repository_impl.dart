import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/models/task_response.dart';

import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/result.dart';
import '../datasources/task_remote_datasource.dart';
import '../datasources/task_local_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<bool>> checkHealth() async {
    try {
      final result = await remoteDataSource.checkHealth();
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<TasksResponse>> getAllTasks() async {
    try {
      final result = await remoteDataSource.getAllTasks();
      await localDataSource.cacheTasks(result);
      return Result.success(result);
    } catch (e) {
      // Try to return cached data if available
      final cached = await localDataSource.getCachedTasks();
      if (cached != null) {
        return Result.success(cached);
      }
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Task>> getTask(int taskId) async {
    try {
      final result = await remoteDataSource.getTask(taskId);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Task>> createTask({
    required String title,
    required int timeLimitMinutes,
  }) async {
    try {
      final request = CreateTaskRequest(
        title: title,
        timeLimitMinutes: timeLimitMinutes,
      );
      final result = await remoteDataSource.createTask(request);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Task>> completeTask(int taskId) async {
    try {
      final result = await remoteDataSource.completeTask(taskId);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Task>> checkTaskExpiry(int taskId) async {
    try {
      final result = await remoteDataSource.checkTaskExpiry(taskId);
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> deleteTask(int taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<TaskStatsResponse>> getTaskStats() async {
    try {
      final result = await remoteDataSource.getTaskStats();
      return Result.success(result);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
