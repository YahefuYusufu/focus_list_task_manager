import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/core/service_locator.dart';
import 'package:taskmanager/domain/repositories/notification_repository.dart';
import 'package:taskmanager/models/notification_model.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';

import 'package:taskmanager/presentations/widgets/task_sections_separate.dart';

import 'add_task_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? toggleTheme;
  final bool? isDarkMode;

  const HomeScreen({
    super.key,
    this.toggleTheme,
    this.isDarkMode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus List'),
        actions: [
          IconButton(
            icon: Icon(Icons.notification_add),
            onPressed: () async {
              print('🧪 Testing immediate iOS notification...');
              try {
                final notificationRepo = sl.get<NotificationRepository>();
                await notificationRepo.scheduleNotification(
                  NotificationModel(
                    id: 99999,
                    title: '🧪 Test Notification',
                    body: 'If you see this, iOS notifications are working!',
                    scheduledTime: DateTime.now(),
                    payload: 'test',
                    type: NotificationType.taskReminder,
                  ),
                );
                print('✅ Test notification sent');
              } catch (e) {
                print('❌ Test notification failed: $e');
              }
            },
            tooltip: 'Test Notification',
          ),
          // Theme Toggle Button (if provided)
          if (widget.toggleTheme != null && widget.isDarkMode != null)
            IconButton(
              icon: Icon(
                widget.isDarkMode! ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: widget.toggleTheme,
              tooltip: widget.isDarkMode! ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          // Statistics Button
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () => _navigateToStatistics(),
            tooltip: 'View Statistics',
          ),
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh all three sections
              context.read<ActiveTasksCubit>().loadActiveTasks();
              context.read<CompletedTasksCubit>().loadCompletedTasks();
              context.read<MissedTasksCubit>().loadMissedTasks();
            },
            tooltip: 'Refresh Tasks',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all three sections
          context.read<ActiveTasksCubit>().loadActiveTasks();
          context.read<CompletedTasksCubit>().loadCompletedTasks();
          context.read<MissedTasksCubit>().loadMissedTasks();
        },
        child: TaskSectionsSeparate(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(),
        tooltip: 'Add New Task',
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToStatistics() {
    // Get the cubits from the current context before navigation
    final completedTasksCubit = context.read<CompletedTasksCubit>();
    final missedTasksCubit = context.read<MissedTasksCubit>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: completedTasksCubit,
            ),
            BlocProvider.value(
              value: missedTasksCubit,
            ),
          ],
          child: StatisticsScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      ),
    );
  }

  void _navigateToAddTask() async {
    // Get the active tasks cubit to pass to AddTaskScreen
    final activeTasksCubit = context.read<ActiveTasksCubit>();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: activeTasksCubit,
          child: AddTaskScreen(
            toggleTheme: widget.toggleTheme,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      ),
    );

    // Refresh all sections if a task was created
    if (result == true && mounted) {
      context.read<ActiveTasksCubit>().loadActiveTasks();
      context.read<CompletedTasksCubit>().loadCompletedTasks();
      context.read<MissedTasksCubit>().loadMissedTasks();
    }
  }
}
