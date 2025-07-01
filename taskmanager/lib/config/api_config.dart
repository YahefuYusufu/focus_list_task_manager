class ApiConfig {
  // Backend URLs
  static const String androidBaseUrl = 'http://10.0.2.2:5007';
  static const String iosBaseUrl = 'http://localhost:5007';

  // API endpoints
  static const String healthEndpoint = '/health';
  static const String tasksEndpoint = '/tasks';
  static const String statsEndpoint = '/tasks/stats';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration retryDelay = Duration(seconds: 2);

  // Timer settings
  static const Duration timerUpdateInterval = Duration(seconds: 1);
  static const int warningThresholdSeconds = 300; // 5 minutes
  static const int urgentThresholdSeconds = 60; // 1 minute
}
