import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:taskmanager/data/datasources/task_local_datasource.dart';
import 'package:taskmanager/data/datasources/task_remote_datasource.dart';
import 'package:taskmanager/data/repositories/task_repository_impl.dart';
import 'package:taskmanager/domain/usecases/complete_task_usecase.dart';
import 'package:taskmanager/domain/usecases/create_task_usecase.dart';
import 'package:taskmanager/domain/usecases/delete_task_usecase.dart';
import 'package:taskmanager/domain/usecases/get_all_tasks_usecase.dart';
import 'package:taskmanager/presentations/cubits/tasks_cubit.dart';
import '../widgets/task_sections.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<TasksCubit>().loadTasks();
            },
            tooltip: 'Refresh Tasks',
          ),
        ],
      ),
      body: BlocConsumer<TasksCubit, TasksState>(
        listener: (context, state) {
          if (state is TasksError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<TasksCubit>().loadTasks();
                  },
                ),
                duration: Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoading) {
            return LoadingWidget();
          } else if (state is TasksLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TasksCubit>().loadTasks();
              },
              child: TaskSections(
                activeTasks: state.activeTasks,
                completedTasks: state.completedTasks,
                missedTasks: state.missedTasks,
              ),
            );
          } else if (state is TasksError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<TasksCubit>().loadTasks();
              },
            );
          }

          return LoadingWidget();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Create a separate cubit instance for AddTaskScreen
          final httpClient = http.Client();
          final remoteDataSource = TaskRemoteDataSourceImpl(client: httpClient);
          final localDataSource = TaskLocalDataSourceImpl();
          final repository = TaskRepositoryImpl(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource,
          );
          final createTaskUseCase = CreateTaskUseCase(repository);
          final getAllTasksUseCase = GetAllTasksUseCase(repository);
          final completeTaskUseCase = CompleteTaskUseCase(repository);
          final deleteTaskUseCase = DeleteTaskUseCase(repository);

          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => TasksCubit(
                  getAllTasksUseCase: getAllTasksUseCase,
                  createTaskUseCase: createTaskUseCase,
                  completeTaskUseCase: completeTaskUseCase,
                  deleteTaskUseCase: deleteTaskUseCase,
                ),
                child: AddTaskScreen(),
              ),
            ),
          );

          // Refresh tasks if a task was created
          if (result == true) {
            // ignore: use_build_context_synchronously
            context.read<TasksCubit>().loadTasks();
          }
        },
        tooltip: 'Add New Task',
        child: Icon(Icons.add),
      ),
    );
  }
}
