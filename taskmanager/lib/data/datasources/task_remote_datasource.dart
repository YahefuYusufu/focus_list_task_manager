import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:taskmanager/models/task_response.dart';
import '../../models/task_model.dart';
import '../../config/api_config.dart';

abstract class TaskRemoteDataSource {
  Future<bool> checkHealth();
  Future<TasksResponse> getAllTasks();
  Future<Task> getTask(int taskId);
  Future<Task> createTask(CreateTaskRequest request);
  Future<Task> completeTask(int taskId);
  Future<Task> checkTaskExpiry(int taskId);
  Future<void> deleteTask(int taskId);
  Future<TaskStatsResponse> getTaskStats();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final http.Client client;
  static const Duration _timeout = Duration(seconds: 10);

  TaskRemoteDataSourceImpl({required this.client});

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String get _baseUrl {
    if (Platform.isAndroid) {
      return ApiConfig.androidBaseUrl;
    } else {
      return ApiConfig.iosBaseUrl;
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: _headers,
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw DataSourceException('Health check failed: $e');
    }
  }

  @override
  Future<TasksResponse> getAllTasks() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/tasks'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return TasksResponse.fromJson(json);
      } else {
        throw DataSourceException('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }

  @override
  Future<Task> getTask(int taskId) async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/tasks/$taskId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 404) {
        throw DataSourceException('Task not found');
      } else {
        throw DataSourceException('Failed to fetch task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }

  @override
  Future<Task> createTask(CreateTaskRequest request) async {
    try {
      final response = await client
          .post(
            Uri.parse('$_baseUrl/tasks'),
            headers: _headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw DataSourceException('Invalid input: ${error['error']}');
      } else {
        throw DataSourceException('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }

  @override
  Future<Task> completeTask(int taskId) async {
    try {
      final response = await client
          .put(
            Uri.parse('$_baseUrl/tasks/$taskId/complete'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 404) {
        throw DataSourceException('Task not found');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw DataSourceException('Cannot complete task: ${error['error']}');
      } else {
        throw DataSourceException('Failed to complete task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }

  @override
  Future<Task> checkTaskExpiry(int taskId) async {
    try {
      final response = await client
          .put(
            Uri.parse('$_baseUrl/tasks/$taskId/check-expiry'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 404) {
        throw DataSourceException('Task not found');
      } else {
        throw DataSourceException('Failed to check expiry: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      final response = await client
          .delete(
            Uri.parse('$_baseUrl/tasks/$taskId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw DataSourceException('Task not found');
      } else {
        throw DataSourceException('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }

  @override
  Future<TaskStatsResponse> getTaskStats() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/tasks/stats'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return TaskStatsResponse.fromJson(json);
      } else {
        throw DataSourceException('Failed to fetch stats: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DataSourceException) rethrow;
      throw DataSourceException('Network error: $e');
    }
  }
}

class DataSourceException implements Exception {
  final String message;

  const DataSourceException(this.message);

  @override
  String toString() => 'DataSourceException: $message';
}
