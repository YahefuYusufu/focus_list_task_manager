// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:taskmanager/models/task_response.dart';
import '../models/task_model.dart';
import '../config/api_config.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 10);

  // Headers for JSON requests
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Base URL based on platform
  static String get _baseUrl {
    if (Platform.isAndroid) {
      return ApiConfig.androidBaseUrl;
    } else {
      return ApiConfig.iosBaseUrl;
    }
  }

  // Health check endpoint
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/health'),
            headers: _headers,
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // Get all tasks grouped by status
  static Future<TasksResponse> getAllTasks() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tasks'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return TasksResponse.fromJson(json);
      } else {
        throw ApiException('Failed to fetch tasks: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Get specific task by ID
  static Future<Task> getTask(int taskId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tasks/$taskId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else {
        throw ApiException('Failed to fetch task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Create new task
  static Future<Task> createTask({
    required String title,
    required int timeLimitMinutes,
  }) async {
    try {
      final request = CreateTaskRequest(
        title: title,
        timeLimitMinutes: timeLimitMinutes,
      );

      final response = await http
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
        throw ApiException('Invalid input: ${error['error']}');
      } else {
        throw ApiException('Failed to create task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Mark task as completed
  static Future<Task> completeTask(int taskId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/tasks/$taskId/complete'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw ApiException('Cannot complete task: ${error['error']}');
      } else {
        throw ApiException('Failed to complete task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Check if task has expired (and update status if needed)
  static Future<Task> checkTaskExpiry(int taskId) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/tasks/$taskId/check-expiry'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Task.fromJson(json);
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else {
        throw ApiException('Failed to check expiry: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Delete task
  static Future<void> deleteTask(int taskId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/tasks/$taskId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found');
      } else {
        throw ApiException('Failed to delete task: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Get task statistics
  static Future<TaskStatsResponse> getTaskStats() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/tasks/stats'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return TaskStatsResponse.fromJson(json);
      } else {
        throw ApiException('Failed to fetch stats: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
