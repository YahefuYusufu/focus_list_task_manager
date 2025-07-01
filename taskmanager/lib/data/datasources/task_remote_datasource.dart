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
      print('🌐 SENDING TO API: ${request.toJson()}');

      final response = await client
          .post(
            Uri.parse('$_baseUrl/tasks'),
            headers: _headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);
      print('📡 API RESPONSE STATUS: ${response.statusCode}');
      print('📡 API RESPONSE BODY: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        print('📋 PARSED JSON: $json');

        return Task.fromJson(json);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw DataSourceException('Invalid input: ${error['error']}');
      } else {
        throw DataSourceException('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ DATA SOURCE ERROR: $e');

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
      print('🌐 DELETING TASK: Sending DELETE request for task ID: $taskId');
      print('🌐 DELETE URL: $_baseUrl/tasks/$taskId');

      final response = await client
          .delete(
            Uri.parse('$_baseUrl/tasks/$taskId'),
            headers: _headers,
          )
          .timeout(_timeout);

      print('📡 DELETE RESPONSE STATUS: ${response.statusCode}');
      print('📡 DELETE RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Task $taskId deleted successfully');
        return;
      } else if (response.statusCode == 404) {
        print('❌ Task $taskId not found');
        throw DataSourceException('Task not found');
      } else if (response.statusCode == 500) {
        print('❌ Server error (500) when deleting task $taskId');
        print('❌ Server response: ${response.body}');
        throw DataSourceException('Server error: ${response.body}');
      } else {
        print('❌ Unexpected status code: ${response.statusCode}');
        throw DataSourceException('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ DELETE ERROR: $e');
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
