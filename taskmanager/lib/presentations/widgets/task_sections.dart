import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import 'task_card.dart';

class TaskSections extends StatelessWidget {
  final List<Task> activeTasks;
  final List<Task> completedTasks;
  final List<Task> missedTasks;

  const TaskSections({
    super.key,
    required this.activeTasks,
    required this.completedTasks,
    required this.missedTasks,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTasks.isEmpty && completedTasks.isEmpty && missedTasks.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Tasks Section
          _buildSection(
            context: context,
            title: 'Active Tasks',
            count: activeTasks.length,
            color: Colors.green,
            icon: Icons.play_circle_outline,
            tasks: activeTasks,
            taskType: TaskType.active,
          ),

          SizedBox(height: 20),

          // Completed Tasks Section
          _buildSection(
            context: context,
            title: 'Completed Tasks',
            count: completedTasks.length,
            color: Colors.blue,
            icon: Icons.check_circle_outline,
            tasks: completedTasks,
            taskType: TaskType.completed,
          ),

          SizedBox(height: 20),

          // Missed Tasks Section
          _buildSection(
            context: context,
            title: 'Missed Tasks',
            count: missedTasks.length,
            color: Colors.red,
            icon: Icons.cancel_outlined,
            tasks: missedTasks,
            taskType: TaskType.missed,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required List<Task> tasks,
    required TaskType taskType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: 8),
            Text(
              '$title ($count)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (tasks.isEmpty)
          _buildEmptySection(context, title, color)
        else
          ...tasks.map((task) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TaskCard(task: task, taskType: taskType),
              )),
      ],
    );
  }

  Widget _buildEmptySection(BuildContext context, String title, Color color) {
    String message;
    IconData emptyIcon;

    switch (title) {
      case 'Active Tasks':
        message = 'No active tasks. Tap + to create one!';
        emptyIcon = Icons.add_task;
        break;
      case 'Completed Tasks':
        message = 'No completed tasks yet.';
        emptyIcon = Icons.task_alt;
        break;
      default:
        message = 'No missed tasks. Keep it up!';
        emptyIcon = Icons.emoji_events;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(emptyIcon, size: 48, color: color.withValues(alpha: 0.6)),
          SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 100,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 24),
            Text(
              'Welcome to Focus List!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
            ),
            SizedBox(height: 12),
            Text(
              'Create your first task to start\nmanaging your time effectively.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // This would typically navigate to add task screen
                // But the FAB already handles this
              },
              icon: Icon(Icons.add),
              label: Text('Create Your First Task'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
