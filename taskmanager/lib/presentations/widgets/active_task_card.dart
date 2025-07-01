// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
// import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
// import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';
// import '../../models/task_model.dart';
// import 'countdown_timer_widget.dart';

// class AnimatedActiveTaskCard extends StatefulWidget {
//   final Task task;

//   const AnimatedActiveTaskCard({
//     super.key,
//     required this.task,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _AnimatedActiveTaskCardState createState() => _AnimatedActiveTaskCardState();
// }

// class _AnimatedActiveTaskCardState extends State<AnimatedActiveTaskCard> with TickerProviderStateMixin {
//   late AnimationController _slideController;
//   late AnimationController _fadeController;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _fadeAnimation;

//   bool _isCompleting = false;

//   @override
//   void initState() {
//     super.initState();

//     // Slide animation controller
//     _slideController = AnimationController(
//       duration: Duration(milliseconds: 800),
//       vsync: this,
//     );

//     // Fade animation controller
//     _fadeController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );

//     // Slide animation (moves card to the right)
//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: Offset(1.0, 0.0),
//     ).animate(CurvedAnimation(
//       parent: _slideController,
//       curve: Curves.easeInOut,
//     ));

//     // Fade animation
//     _fadeAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));

//     // IMPORTANT: Start with card visible - keep fade at 1.0
//     _fadeController.value = 1.0;
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }

//   void _completeTask() async {
//     if (_isCompleting) return;

//     setState(() {
//       _isCompleting = true;
//     });

//     // Start animations
//     _slideController.forward();
//     await Future.delayed(Duration(milliseconds: 400));
//     _fadeController.reverse();

//     // Check if widget is still mounted before using context
//     if (!mounted) return;

//     // Complete the task in backend
//     await context.read<ActiveTasksCubit>().completeTask(widget.task.id);

//     // Check again after async operation
//     if (!mounted) return;

//     // Refresh the completed tasks section
//     context.read<CompletedTasksCubit>().loadCompletedTasks();

//     // Show success feedback
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.check_circle, color: Colors.white, size: 20),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text('Task "${widget.task.title}" completed! 🎉'),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('🎨 Building AnimatedActiveTaskCard for: ${widget.task.title}'); // Debug

//     return SlideTransition(
//       position: _slideAnimation,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Container(
//           margin: EdgeInsets.only(bottom: 8),
//           child: Card(
//             elevation: _isCompleting ? 8 : 4,
//             // FORCE VISIBLE COLORS
//             color: Colors.white,
//             child: AnimatedContainer(
//               duration: Duration(milliseconds: 300),
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: _isCompleting ? Colors.green.withValues(alpha: 0.2) : Colors.white, // Force white background
//                 border: _isCompleting ? Border.all(color: Colors.green, width: 2) : Border.all(color: Colors.blue.withValues(alpha: 0.2), width: 1), // Always visible border
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Task Title and Timer
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           widget.task.title.isEmpty ? 'Untitled Task' : widget.task.title,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87, // Force visible text color
//                                 decoration: _isCompleting ? TextDecoration.lineThrough : null,
//                               ),
//                         ),
//                       ),
//                       if (!_isCompleting)
//                         CountdownTimerWidget(
//                           task: widget.task,
//                           onExpired: () {
//                             // Task expired, refresh to move to missed
//                             if (mounted) {
//                               context.read<ActiveTasksCubit>().loadActiveTasks();
//                               context.read<MissedTasksCubit>().loadMissedTasks();
//                             }
//                           },
//                         )
//                       else
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Colors.green.withValues(alpha: 0.2),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.green, width: 1),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.check_circle, size: 16, color: Colors.green),
//                               SizedBox(width: 4),
//                               Text(
//                                 'DONE!',
//                                 style: TextStyle(
//                                   color: Colors.green,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),

//                   SizedBox(height: 8),

//                   // Time limit info
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.timer,
//                         size: 16,
//                         color: Colors.grey.shade600,
//                       ),
//                       SizedBox(width: 4),
//                       Text(
//                         '${widget.task.timeLimitMinutes} min limit',
//                         style: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 12),

//                   // Mark as Done button with animation
//                   AnimatedSwitcher(
//                     duration: Duration(milliseconds: 300),
//                     child: _isCompleting
//                         ? SizedBox(
//                             key: Key('completing'),
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: null,
//                               icon: SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                                 ),
//                               ),
//                               label: Text('Completing...'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(vertical: 12),
//                               ),
//                             ),
//                           )
//                         : SizedBox(
//                             key: Key('complete'),
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: _completeTask,
//                               icon: Icon(Icons.check, size: 18),
//                               label: Text('Mark as Done'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green,
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(vertical: 12),
//                                 elevation: 2,
//                               ),
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
