// lib/main.dart - Simple version without Provider
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';

// Data Layer
import 'data/datasources/task_remote_datasource.dart';
import 'data/datasources/task_local_datasource.dart';
import 'data/repositories/task_repository_impl.dart';

// Domain Layer
import 'domain/usecases/get_all_tasks_usecase.dart';
import 'domain/usecases/create_task_usecase.dart';
import 'domain/usecases/complete_task_usecase.dart';
import 'domain/usecases/check_task_expiry_usecase.dart';

// Presentation Layer
import 'presentations/screens/home_screen.dart';

// Theme
import 'package:taskmanager/theme/app_themes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create dependencies
    final httpClient = http.Client();
    final remoteDataSource = TaskRemoteDataSourceImpl(client: httpClient);
    final localDataSource = TaskLocalDataSourceImpl();
    final repository = TaskRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Create use cases
    final getAllTasksUseCase = GetAllTasksUseCase(repository);
    final createTaskUseCase = CreateTaskUseCase(repository);
    final completeTaskUseCase = CompleteTaskUseCase(repository);
    final checkTaskExpiryUseCase = CheckTaskExpiryUseCase(repository);
    final deleteTaskUseCase = DeleteTaskUseCase(repository);

    return MaterialApp(
      title: 'Focus List',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,

      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              print('🚀 Creating ActiveTasksCubit'); // Debug
              final cubit = ActiveTasksCubit(
                getAllTasksUseCase: getAllTasksUseCase,
                createTaskUseCase: createTaskUseCase,
                completeTaskUseCase: completeTaskUseCase,
                checkTaskExpiryUseCase: checkTaskExpiryUseCase,
                deleteTaskUseCase: deleteTaskUseCase,
              );
              // Load tasks after a small delay to ensure everything is set up
              Future.delayed(Duration(milliseconds: 100), () {
                print('🚀 Loading active tasks'); // Debug
                cubit.loadActiveTasks();
              });
              return cubit;
            },
          ),
          BlocProvider(
            create: (context) {
              print('🚀 Creating CompletedTasksCubit'); // Debug
              final cubit = CompletedTasksCubit(
                getAllTasksUseCase: getAllTasksUseCase,
                deleteTaskUseCase: deleteTaskUseCase,
              );
              // Load tasks after a small delay
              Future.delayed(Duration(milliseconds: 150), () {
                print('🚀 Loading completed tasks'); // Debug
                cubit.loadCompletedTasks();
              });
              return cubit;
            },
          ),
          BlocProvider(
            create: (context) {
              print('🚀 Creating MissedTasksCubit'); // Debug
              final cubit = MissedTasksCubit(
                getAllTasksUseCase: getAllTasksUseCase,
                deleteTaskUseCase: deleteTaskUseCase,
              );
              // Load tasks after a small delay
              Future.delayed(Duration(milliseconds: 200), () {
                print('🚀 Loading missed tasks'); // Debug
                cubit.loadMissedTasks();
              });
              return cubit;
            },
          ),
        ],
        child: AppInitializer(
          toggleTheme: toggleTheme,
          isDarkMode: _themeMode == ThemeMode.dark,
        ),
      ),
    );
  }
}

// App Initializer Widget
class AppInitializer extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AppInitializer({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 App initialized, triggering data load'); // Debug
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    print('🚀 Loading initial data from all cubits'); // Debug

    // Trigger load for all cubits
    context.read<ActiveTasksCubit>().loadActiveTasks();
    context.read<CompletedTasksCubit>().loadCompletedTasks();
    context.read<MissedTasksCubit>().loadMissedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      toggleTheme: widget.toggleTheme,
      isDarkMode: widget.isDarkMode,
    );
  }
}
