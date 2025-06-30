import 'package:equatable/equatable.dart';
import 'package:taskmanager/models/task_model.dart';

class TasksResponse extends Equatable {
  final List<Task> active;
  final List<Task> completed;
  final List<Task> missed;

  const TasksResponse({
    required this.active,
    required this.completed,
    required this.missed,
  });

  factory TasksResponse.fromJson(Map<String, dynamic> json) {
    return TasksResponse(
      active: (json['active'] as List<dynamic>).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList(),
      completed: (json['completed'] as List<dynamic>).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList(),
      missed: (json['missed'] as List<dynamic>).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active.map((e) => e.toJson()).toList(),
      'completed': completed.map((e) => e.toJson()).toList(),
      'missed': missed.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object> get props => [active, completed, missed];
}

class CreateTaskRequest extends Equatable {
  final String title;
  final int timeLimitMinutes;

  const CreateTaskRequest({
    required this.title,
    required this.timeLimitMinutes,
  });

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) {
    return CreateTaskRequest(
      title: json['title'] as String,
      timeLimitMinutes: json['time_limit_minutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'time_limit_minutes': timeLimitMinutes,
    };
  }

  @override
  List<Object> get props => [title, timeLimitMinutes];
}

class TaskStatsResponse extends Equatable {
  final int totalTasks;
  final int activeTasks;
  final int completedTasks;
  final int missedTasks;

  const TaskStatsResponse({
    required this.totalTasks,
    required this.activeTasks,
    required this.completedTasks,
    required this.missedTasks,
  });

  factory TaskStatsResponse.fromJson(Map<String, dynamic> json) {
    return TaskStatsResponse(
      totalTasks: json['total_tasks'] as int,
      activeTasks: json['active_tasks'] as int,
      completedTasks: json['completed_tasks'] as int,
      missedTasks: json['missed_tasks'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tasks': totalTasks,
      'active_tasks': activeTasks,
      'completed_tasks': completedTasks,
      'missed_tasks': missedTasks,
    };
  }

  @override
  List<Object> get props => [totalTasks, activeTasks, completedTasks, missedTasks];
}
