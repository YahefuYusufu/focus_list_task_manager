import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';
import 'package:taskmanager/presentations/widgets/completed_task_card.dart';
import 'package:taskmanager/presentations/widgets/simple_active_task_card.dart';

// Use the animated version
import 'missed_task_card.dart';
import 'error_widget.dart';

class TaskSectionsSeparate extends StatelessWidget {
  const TaskSectionsSeparate({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Tasks Section
          _buildActiveTasksSection(context),

          SizedBox(height: 24),

          // Completed Tasks Section
          _buildCompletedTasksSection(context),

          SizedBox(height: 24),

          // Missed Tasks Section
          _buildMissedTasksSection(context),
        ],
      ),
    );
  }

  Widget _buildActiveTasksSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.play_circle_outline, color: colorScheme.primary, size: 24),
            SizedBox(width: 8),
            Text(
              'Active Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
        SizedBox(height: 12),
        BlocBuilder<ActiveTasksCubit, ActiveTasksState>(
          builder: (context, state) {
            print('🔍 ActiveTasksState: $state'); // Debug line

            if (state is ActiveTasksLoading) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                ),
              );
            } else if (state is ActiveTasksLoaded) {
              print('🔍 Active tasks count: ${state.tasks.length}'); // Debug line

              if (state.tasks.isEmpty) {
                return _buildEmptySection(
                  context,
                  'No active tasks. Tap + to create one!',
                  colorScheme.primary,
                  Icons.add_task,
                );
              }

              return Column(
                children: state.tasks.map((task) {
                  print('🔍 Rendering task: ${task.title}'); // Debug line
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: SimpleActiveTaskCard(task: task),
                  );
                }).toList(),
              );
            } else if (state is ActiveTasksError) {
              print('🔍 ActiveTasksError: ${state.message}'); // Debug line
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<ActiveTasksCubit>().loadActiveTasks();
                },
              );
            }

            print('🔍 ActiveTasks: Unknown state'); // Debug line
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildCompletedTasksSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: colorScheme.secondary, size: 24),
            SizedBox(width: 8),
            Text(
              'Completed Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
            ),
          ],
        ),
        SizedBox(height: 12),
        BlocBuilder<CompletedTasksCubit, CompletedTasksState>(
          builder: (context, state) {
            print('🔍 CompletedTasksState: $state'); // Debug line

            if (state is CompletedTasksLoading) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.secondary,
                  ),
                ),
              );
            } else if (state is CompletedTasksLoaded) {
              print('🔍 Completed tasks count: ${state.tasks.length}'); // Debug line

              if (state.tasks.isEmpty) {
                return _buildEmptySection(
                  context,
                  'No completed tasks yet.',
                  colorScheme.secondary,
                  Icons.task_alt,
                );
              }

              return Column(
                children: state.tasks
                    .map((task) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: AnimatedCompletedTaskCard(task: task),
                        ))
                    .toList(),
              );
            } else if (state is CompletedTasksError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<CompletedTasksCubit>().loadCompletedTasks();
                },
              );
            }

            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMissedTasksSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cancel_outlined, color: colorScheme.error, size: 24),
            SizedBox(width: 8),
            Text(
              'Missed Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
            ),
          ],
        ),
        SizedBox(height: 12),
        BlocBuilder<MissedTasksCubit, MissedTasksState>(
          builder: (context, state) {
            print('🔍 MissedTasksState: $state'); // Debug line

            if (state is MissedTasksLoading) {
              return SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.error,
                  ),
                ),
              );
            } else if (state is MissedTasksLoaded) {
              print('🔍 Missed tasks count: ${state.tasks.length}'); // Debug line

              if (state.tasks.isEmpty) {
                return _buildEmptySection(
                  context,
                  'No missed tasks. Keep it up!',
                  colorScheme.secondary, // Green for positive message
                  Icons.emoji_events,
                );
              }

              return Column(
                children: state.tasks
                    .map((task) => Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: MissedTaskCard(task: task),
                        ))
                    .toList(),
              );
            } else if (state is MissedTasksError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () {
                  context.read<MissedTasksCubit>().loadMissedTasks();
                },
              );
            }

            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildEmptySection(BuildContext context, String message, Color color, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine which container color to use based on the section
    Color containerColor;
    Color textColor;

    if (color == colorScheme.primary) {
      // Active tasks - use primary container
      containerColor = colorScheme.primary.withValues(alpha: 0.1);
      textColor = colorScheme.primary;
    } else if (color == colorScheme.secondary) {
      // Completed tasks or positive messages - use secondary container
      containerColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    } else if (color == colorScheme.error) {
      // Error states - use error container
      containerColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
    } else {
      // Fallback
      containerColor = color.withValues(alpha: 0.1);
      textColor = color;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: color.withValues(alpha: 0.7),
          ),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
