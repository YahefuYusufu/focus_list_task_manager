import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final int timeLimitMinutes;
  final String createdAt;
  final String expiresAt;
  final String status;
  final int? remainingSeconds;

  const Task({
    required this.id,
    required this.title,
    required this.timeLimitMinutes,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.remainingSeconds,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      timeLimitMinutes: json['time_limit_minutes'] as int,
      createdAt: json['created_at'] as String,
      expiresAt: json['expires_at'] as String,
      status: json['status'] as String,
      remainingSeconds: json['remaining_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'time_limit_minutes': timeLimitMinutes,
      'created_at': createdAt,
      'expires_at': expiresAt,
      'status': status,
      'remaining_seconds': remainingSeconds,
    };
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isMissed => status == 'missed';

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
      final expiryTime = DateTime.parse(expiresAt);
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
}
