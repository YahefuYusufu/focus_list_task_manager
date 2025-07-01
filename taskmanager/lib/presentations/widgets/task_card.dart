// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:taskmanager/presentations/cubits/tasks_cubit.dart';
// import '../../models/task_model.dart';
// import 'countdown_timer_widget.dart';

// enum TaskType { active, completed, missed }

// class TaskCard extends StatelessWidget {
//   final Task task;
//   final TaskType taskType;

//   const TaskCard({
//     super.key,
//     required this.task,
//     required this.taskType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     task.title,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           decoration: taskType == TaskType.completed ? TextDecoration.lineThrough : null,
//                         ),
//                   ),
//                 ),
//                 _buildStatusIndicator(context),
//               ],
//             ),
//             SizedBox(height: 8),
//             Row(
//               children: [
//                 Icon(
//                   Icons.timer,
//                   size: 16,
//                   color: Colors.grey.shade600,
//                 ),
//                 SizedBox(width: 4),
//                 Text(
//                   '${task.timeLimitMinutes} min limit',
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 Spacer(),
//                 if (taskType == TaskType.active) _buildTimer(context),
//                 if (taskType != TaskType.active) _buildStatusText(),
//               ],
//             ),
//             if (taskType == TaskType.active) ...[
//               SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         context.read<TasksCubit>().completeTask(task.id);
//                       },
//                       icon: Icon(Icons.check, size: 18),
//                       label: Text('Mark as Done'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   IconButton(
//                     onPressed: () {
//                       _showDeleteDialog(context);
//                     },
//                     icon: Icon(Icons.delete_outline),
//                     color: Colors.red,
//                   ),
//                 ],
//               ),
//             ],
//             if (taskType != TaskType.active) ...[
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   TextButton.icon(
//                     onPressed: () {
//                       _showDeleteDialog(context);
//                     },
//                     icon: Icon(Icons.delete_outline, size: 16),
//                     label: Text('Delete'),
//                     style: TextButton.styleFrom(
//                       foregroundColor: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusIndicator(BuildContext context) {
//     IconData icon;
//     Color color;

//     switch (taskType) {
//       case TaskType.active:
//         icon = Icons.play_circle;
//         color = Colors.green;
//         break;
//       case TaskType.completed:
//         icon = Icons.check_circle;
//         color = Colors.blue;
//         break;
//       case TaskType.missed:
//         icon = Icons.cancel;
//         color = Colors.red;
//         break;
//     }

//     return Icon(icon, color: color, size: 24);
//   }

//   Widget _buildTimer(BuildContext context) {
//     return CountdownTimer(
//       task: task,
//       onExpired: () {
//         context.read<TasksCubit>().updateTaskTimer(task.id, 0);
//       },
//       onTick: (remainingSeconds) {
//         context.read<TasksCubit>().updateTaskTimer(task.id, remainingSeconds);
//       },
//     );
//   }

//   Widget _buildStatusText() {
//     String text;
//     Color color;

//     switch (taskType) {
//       case TaskType.completed:
//         text = 'COMPLETED';
//         color = Colors.blue;
//         break;
//       case TaskType.missed:
//         text = 'EXPIRED';
//         color = Colors.red;
//         break;
//       default:
//         text = '';
//         color = Colors.grey;
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text('Delete Task'),
//           content: Text('Are you sure you want to delete "${task.title}"?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 context.read<TasksCubit>().deleteTask(task.id);
//               },
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
