// lib/presentations/screens/home_screen.dart - Updated with Theme Toggle
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';

import 'package:taskmanager/presentations/widgets/task_sections_separate.dart';

// Data Layer
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';

// Domain Layer
import '../../domain/usecases/create_task_usecase.dart';

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
    // Create dependencies for AddTaskScreen
    final httpClient = http.Client();
    final remoteDataSource = TaskRemoteDataSourceImpl(client: httpClient);
    final localDataSource = TaskLocalDataSourceImpl();
    final repository = TaskRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
    final createTaskUseCase = CreateTaskUseCase(repository);

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(
          createTaskUseCase: createTaskUseCase,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
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
