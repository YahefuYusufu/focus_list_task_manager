// lib/presentations/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/models/task_model.dart';
import '../cubits/completed_tasks_cubit.dart';
import '../cubits/missed_tasks_cubit.dart';

class StatisticsScreen extends StatelessWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const StatisticsScreen({
    super.key,
    this.toggleTheme,
    this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Statistics'),
        actions: [
          // Theme Toggle Button (if provided)
          if (toggleTheme != null && isDarkMode != null)
            IconButton(
              icon: Icon(
                isDarkMode! ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: toggleTheme,
              tooltip: isDarkMode! ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              context.read<CompletedTasksCubit>().loadCompletedTasks();
              context.read<MissedTasksCubit>().loadMissedTasks();
            },
            tooltip: 'Refresh Statistics',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CompletedTasksCubit>().loadCompletedTasks();
          context.read<MissedTasksCubit>().loadMissedTasks();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Summary
              _buildTodaysSummary(context),
              SizedBox(height: 24),

              // Daily Performance Chart
              _buildDailyPerformanceChart(context),
              SizedBox(height: 24),

              // Weekly Overview
              _buildWeeklyOverview(context),
              SizedBox(height: 24),

              // Performance Trends
              _buildPerformanceTrends(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysSummary(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Performance',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16),
        BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
          builder: (context, completedState) {
            return BlocBuilder<MissedTasksCubit, MissedTasksState>(
              builder: (context, missedState) {
                final today = DateTime.now();
                final todayCompleted = _getTasksForDate(
                  completedState is CompletedTasksLoaded ? completedState.tasks : [],
                  today,
                );
                final todayMissed = _getTasksForDate(
                  missedState is MissedTasksLoaded ? missedState.tasks : [],
                  today,
                );
                final todayTotal = todayCompleted + todayMissed;
                final completionRate = todayTotal > 0 ? (todayCompleted / todayTotal * 100).round() : 0;

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTodayMetric(
                                context,
                                'Completed',
                                todayCompleted.toString(),
                                Icons.check_circle,
                                colorScheme.secondary,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTodayMetric(
                                context,
                                'Missed',
                                todayMissed.toString(),
                                Icons.error,
                                colorScheme.error,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTodayMetric(
                                context,
                                'Success Rate',
                                '$completionRate%',
                                Icons.trending_up,
                                _getSuccessRateColor(context, completionRate),
                              ),
                            ),
                          ],
                        ),
                        if (todayTotal > 0) ...[
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Progress',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: completionRate / 100,
                                backgroundColor: colorScheme.outlineVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getSuccessRateColor(context, completionRate),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$todayCompleted completed out of $todayTotal total tasks',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyPerformanceChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 7 Days Performance',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16),
        BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
          builder: (context, completedState) {
            return BlocBuilder<MissedTasksCubit, MissedTasksState>(
              builder: (context, missedState) {
                final completedTasks = completedState is CompletedTasksLoaded ? completedState.tasks : <Task>[];
                final missedTasks = missedState is MissedTasksLoaded ? missedState.tasks : <Task>[];

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ...List.generate(7, (index) {
                          final date = DateTime.now().subtract(Duration(days: 6 - index));
                          final completed = _getTasksForDate(completedTasks, date);
                          final missed = _getTasksForDate(missedTasks, date);
                          final total = completed + missed;

                          return Padding(
                            padding: EdgeInsets.only(bottom: index == 6 ? 0 : 12),
                            child: _buildDayPerformanceRow(context, date, completed, missed, total),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeeklyOverview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16),
        BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
          builder: (context, completedState) {
            return BlocBuilder<MissedTasksCubit, MissedTasksState>(
              builder: (context, missedState) {
                final completedTasks = completedState is CompletedTasksLoaded ? completedState.tasks : <Task>[];
                final missedTasks = missedState is MissedTasksLoaded ? missedState.tasks : <Task>[];

                final weekData = _getWeeklyData(completedTasks, missedTasks);

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeeklyMetric(
                              context,
                              'Total Completed',
                              weekData['completed'].toString(),
                              colorScheme.secondary,
                            ),
                            _buildWeeklyMetric(
                              context,
                              'Total Missed',
                              weekData['missed'].toString(),
                              colorScheme.error,
                            ),
                            _buildWeeklyMetric(
                              context,
                              'Average Daily',
                              (weekData['total']! / 7).toStringAsFixed(1),
                              colorScheme.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (weekData['total']! > 0) ...[
                          Text(
                            'Weekly Success Rate',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: weekData['completed']! / weekData['total']!,
                            backgroundColor: colorScheme.outlineVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getSuccessRateColor(context, (weekData['completed']! / weekData['total']! * 100).round()),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${(weekData['completed']! / weekData['total']! * 100).round()}% success rate this week',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceTrends(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Insights',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 16),
        BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
          builder: (context, completedState) {
            return BlocBuilder<MissedTasksCubit, MissedTasksState>(
              builder: (context, missedState) {
                final completedTasks = completedState is CompletedTasksLoaded ? completedState.tasks : <Task>[];
                final missedTasks = missedState is MissedTasksLoaded ? missedState.tasks : <Task>[];

                final insights = _generateInsights(context, completedTasks, missedTasks);

                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: insights
                          .map((insight) => Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      insight['icon'],
                                      color: insight['color'],
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        insight['text'],
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodayMetric(BuildContext context, String label, String value, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDayPerformanceRow(BuildContext context, DateTime date, int completed, int missed, int total) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = _isSameDay(date, DateTime.now());
    final completionRate = total > 0 ? (completed / total) : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isToday ? colorScheme.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateLabel(date),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? colorScheme.primary : colorScheme.onSurface,
                      ),
                ),
                Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: total > 0
                ? Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: completionRate,
                          backgroundColor: colorScheme.errorContainer,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${(completionRate * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ],
                  )
                : Text(
                    'No tasks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
          ),
          SizedBox(width: 16),
          Text(
            '$completed/$total',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: _getSuccessRateColor(context, (completionRate * 100).round()),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyMetric(BuildContext context, String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Helper methods
  int _getTasksForDate(List<Task> tasks, DateTime date) {
    return tasks.where((task) {
      try {
        // For completed tasks, use createdAt as completion date
        // For missed tasks, use expiresAt as the date they were missed
        final taskDate = task.isCompleted ? DateTime.parse(task.createdAt) : DateTime.parse(task.expiresAt);
        return _isSameDay(taskDate, date);
      } catch (e) {
        // If date parsing fails, exclude the task
        return false;
      }
    }).length;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _formatDateLabel(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    if (_isSameDay(date, today)) return 'Today';
    if (_isSameDay(date, yesterday)) return 'Yesterday';

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  Color _getSuccessRateColor(BuildContext context, int rate) {
    final colorScheme = Theme.of(context).colorScheme;
    if (rate >= 80) return colorScheme.secondary; // Green for excellent
    if (rate >= 60) return colorScheme.tertiary; // Orange for good
    return colorScheme.error; // Red for needs improvement
  }

  Map<String, int> _getWeeklyData(List<Task> completedTasks, List<Task> missedTasks) {
    int completed = 0;
    int missed = 0;

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      completed += _getTasksForDate(completedTasks, date);
      missed += _getTasksForDate(missedTasks, date);
    }

    return {
      'completed': completed,
      'missed': missed,
      'total': completed + missed,
    };
  }

  List<Map<String, dynamic>> _generateInsights(BuildContext context, List<Task> completedTasks, List<Task> missedTasks) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekData = _getWeeklyData(completedTasks, missedTasks);
    final insights = <Map<String, dynamic>>[];

    // Performance insight
    if (weekData['total']! > 0) {
      final rate = (weekData['completed']! / weekData['total']! * 100).round();
      if (rate >= 80) {
        insights.add({
          'text': 'Excellent performance! You\'re completing $rate% of your tasks this week.',
          'icon': Icons.star,
          'color': colorScheme.secondary,
        });
      } else if (rate >= 60) {
        insights.add({
          'text': 'Good progress with $rate% completion rate. Keep pushing for higher success!',
          'icon': Icons.trending_up,
          'color': colorScheme.tertiary,
        });
      } else {
        insights.add({
          'text': 'Focus needed - $rate% completion rate. Consider reviewing your task planning.',
          'icon': Icons.flag,
          'color': colorScheme.error,
        });
      }
    }

    // Activity insight
    final avgDaily = weekData['total']! / 7;
    if (avgDaily < 1) {
      insights.add({
        'text': 'Low activity level. Try setting 2-3 daily goals to build momentum.',
        'icon': Icons.lightbulb,
        'color': colorScheme.primary,
      });
    } else if (avgDaily > 5) {
      insights.add({
        'text': 'High activity level! Make sure you\'re not overcommitting.',
        'icon': Icons.warning,
        'color': colorScheme.tertiary,
      });
    }

    // Today's insight
    final today = DateTime.now();
    final todayCompleted = _getTasksForDate(completedTasks, today);
    final todayMissed = _getTasksForDate(missedTasks, today);

    if (todayCompleted > 0 && todayMissed == 0) {
      insights.add({
        'text': 'Perfect day! You\'ve completed all of today\'s tasks.',
        'icon': Icons.celebration,
        'color': colorScheme.secondary,
      });
    }

    if (insights.isEmpty) {
      insights.add({
        'text': 'Start adding tasks to see your performance insights!',
        'icon': Icons.info,
        'color': colorScheme.outline,
      });
    }

    return insights;
  }
}
