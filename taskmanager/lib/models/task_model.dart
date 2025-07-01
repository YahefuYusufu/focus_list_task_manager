import 'package:equatable/equatable.dart';

// Task Status Enum
enum TaskStatus {
  active,
  completed,
  missed,
}

class Task extends Equatable {
  final int id;
  final String title;
  final int timeLimitMinutes;
  final String? createdAt;
  final String? expiresAt;
  final TaskStatus status;
  final int? remainingSeconds;

  const Task({
    required this.id,
    required this.title,
    required this.timeLimitMinutes,
    this.createdAt,
    this.expiresAt,
    required this.status,
    this.remainingSeconds,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Handle nested structure where task data is under "task" key
    final taskData = json.containsKey('task') ? json['task'] : json;

    // Parse status string to enum
    TaskStatus parseStatus(String? statusString) {
      switch (statusString?.toLowerCase()) {
        case 'active':
          return TaskStatus.active;
        case 'completed':
          return TaskStatus.completed;
        case 'missed':
          return TaskStatus.missed;
        default:
          return TaskStatus.active;
      }
    }

    return Task(
      id: taskData['id'] ?? 0,
      title: taskData['title'] ?? '',
      timeLimitMinutes: taskData['time_limit_minutes'] ?? 0,
      createdAt: taskData['created_at'],
      expiresAt: taskData['expires_at'],
      status: parseStatus(taskData['status']),
      remainingSeconds: taskData['remaining_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time_limit_minutes': timeLimitMinutes,
      'created_at': createdAt,
      'expires_at': expiresAt,
      'status': status.toString().split('.').last,
      'remaining_seconds': remainingSeconds,
    };
  }

  // Helper methods
  bool get isActive => status == TaskStatus.active;
  bool get isCompleted => status == TaskStatus.completed;
  bool get isMissed => status == TaskStatus.missed;

  // Get remaining time in minutes and seconds
  String get formattedTimeRemaining {
    if (remainingSeconds == null || remainingSeconds! <= 0) {
      return "00:00";
    }

    final minutes = remainingSeconds! ~/ 60;
    final seconds = remainingSeconds! % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Calculate remaining seconds from current time
  int calculateRemainingSeconds() {
    try {
      if (expiresAt == null) return 0;
      final expiryTime = DateTime.parse(expiresAt!);
      final now = DateTime.now();
      final difference = expiryTime.difference(now).inSeconds;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  // Create a copy with updated remaining seconds
  Task copyWithRemainingSeconds(int newRemainingSeconds) {
    return Task(
      id: id,
      title: title,
      timeLimitMinutes: timeLimitMinutes,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: status,
      remainingSeconds: newRemainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        timeLimitMinutes,
        createdAt,
        expiresAt,
        status,
        remainingSeconds,
      ];

  @override
  String toString() {
    return 'Task(id: $id, title: "$title", timeLimitMinutes: $timeLimitMinutes, createdAt: $createdAt, expiresAt: $expiresAt, status: $status, remainingSeconds: $remainingSeconds)';
  }
}
