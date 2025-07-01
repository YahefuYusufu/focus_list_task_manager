import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/domain/repositories/notification_repository.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';

// Core
import 'core/service_locator.dart';

// Presentation Layer
import 'presentations/screens/home_screen.dart';

// Theme
import 'package:taskmanager/theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependencies
  sl.setupDependencies();

  // Initialize notifications
  try {
    await sl.initializeNotifications();
    print('🔔 Notifications initialized successfully');

    // 🍎 FORCE iOS permission request
    if (Platform.isIOS) {
      print('🍎 Requesting iOS notification permissions...');
      final notificationRepo = sl.get<NotificationRepository>();
      final granted = await notificationRepo.requestPermissions();
      print('🍎 iOS notification permission granted: $granted');

      if (!granted) {
        print('⚠️ iOS notification permissions denied - notifications won\'t work');
      }
    }
  } catch (e) {
    print('⚠️ Failed to initialize notifications: $e');
    // Continue anyway - app should work without notifications
  }

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
                getAllTasksUseCase: sl.get(),
                createTaskUseCase: sl.get(),
                completeTaskUseCase: sl.get(),
                checkTaskExpiryUseCase: sl.get(),
                deleteTaskUseCase: sl.get(),
                // Notification use cases
                scheduleTaskReminderUseCase: sl.get(),
                cancelTaskNotificationsUseCase: sl.get(),
                showTaskCompletedUseCase: sl.get(),
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
                getAllTasksUseCase: sl.get(),
                deleteTaskUseCase: sl.get(),
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
                getAllTasksUseCase: sl.get(),
                deleteTaskUseCase: sl.get(),
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
