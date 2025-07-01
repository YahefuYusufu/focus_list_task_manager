import 'package:taskmanager/models/task_response.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks(TasksResponse tasks);
  Future<TasksResponse?> getCachedTasks();
  Future<void> clearCache();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  // In a real app, you'd use SharedPreferences, Hive, or SQLite
  // For now, we'll use simple in-memory caching
  TasksResponse? _cachedTasks;

  @override
  Future<void> cacheTasks(TasksResponse tasks) async {
    _cachedTasks = tasks;
  }

  @override
  Future<TasksResponse?> getCachedTasks() async {
    return _cachedTasks;
  }

  @override
  Future<void> clearCache() async {
    _cachedTasks = null;
  }
}
