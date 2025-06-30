import 'package:http/http.dart' as http;
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/get_all_tasks_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/check_task_expiry_usecase.dart';
import '../../domain/usecases/get_task_stats_usecase.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  // Register a service
  void register<T>(T service) {
    _services[T] = service;
  }

  // Register a factory function
  void registerFactory<T>(T Function() factory) {
    _services[T] = factory;
  }

  // Get a service
  T get<T>() {
    final service = _services[T];
    if (service is T Function()) {
      return service();
    } else if (service is T) {
      return service;
    } else {
      throw Exception('Service of type $T not found');
    }
  }

  // Initialize all dependencies
  void setupDependencies() {
    // External dependencies
    register<http.Client>(http.Client());

    // Data sources
    registerFactory<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(client: get<http.Client>()),
    );
    registerFactory<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl(),
    );

    // Repository
    registerFactory<TaskRepository>(
      () => TaskRepositoryImpl(
        remoteDataSource: get<TaskRemoteDataSource>(),
        localDataSource: get<TaskLocalDataSource>(),
      ),
    );

    // Use cases
    registerFactory<GetAllTasksUseCase>(
      () => GetAllTasksUseCase(get<TaskRepository>()),
    );
    registerFactory<CreateTaskUseCase>(
      () => CreateTaskUseCase(get<TaskRepository>()),
    );
    registerFactory<CompleteTaskUseCase>(
      () => CompleteTaskUseCase(get<TaskRepository>()),
    );
    registerFactory<DeleteTaskUseCase>(
      () => DeleteTaskUseCase(get<TaskRepository>()),
    );
    registerFactory<CheckTaskExpiryUseCase>(
      () => CheckTaskExpiryUseCase(get<TaskRepository>()),
    );
    registerFactory<GetTaskStatsUseCase>(
      () => GetTaskStatsUseCase(get<TaskRepository>()),
    );
  }

  // Clear all services (useful for testing)
  void reset() {
    _services.clear();
  }
}

// Convenience getters
final sl = ServiceLocator();
