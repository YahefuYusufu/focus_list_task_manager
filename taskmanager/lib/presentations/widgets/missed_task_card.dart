import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/missed_tasks_cubit.dart';

import '../../models/task_model.dart';
import '../../utils/time_utils.dart';

class MissedTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onDeleted;
  final VoidCallback? onRescheduled;

  const MissedTaskCard({
    super.key,
    required this.task,
    this.onDeleted,
    this.onRescheduled,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MissedTaskCardState createState() => _MissedTaskCardState();
}

class _MissedTaskCardState extends State<MissedTaskCard> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _deleteFadeAnimation;

  bool _isDeleting = false;
  bool _isRescheduling = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _entranceController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Entrance animations
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeInOut,
    ));

    // Exit animations
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _deleteFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Delete Missed Task',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${widget.task.title}"?\n\nThis will permanently remove it from your missed tasks.',
            style: TextStyle(
              height: 1.4,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteTask();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    int selectedMinutes = widget.task.timeLimitMinutes;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Text(
                    'Reschedule Task',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Give "${widget.task.title}" another chance!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select new time limit:',
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedMinutes,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: TextStyle(color: Colors.black87),
                        items: TimeUtils.getTimePickerOptions().map((minutes) {
                          return DropdownMenuItem<int>(
                            value: minutes,
                            child: Text(TimeUtils.formatMinutes(minutes)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMinutes = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _rescheduleTask(selectedMinutes);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Reschedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      print('🗑️ Deleting missed task: ${widget.task.title}');

      // Start delete animation
      await _slideController.forward();

      if (!mounted) return;

      // Delete the task using the cubit
      await context.read<MissedTasksCubit>().deleteTask(widget.task.id);

      // Notify parent to remove this widget
      widget.onDeleted?.call();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Missed task "${widget.task.title}" deleted'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting missed task: $e');
      if (!mounted) return;

      // Reset animation on error
      _slideController.reset();
      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rescheduleTask(int newTimeLimit) async {
    if (_isRescheduling) return;

    setState(() {
      _isRescheduling = true;
    });

    try {
      print('🔄 Rescheduling task: ${widget.task.title} for $newTimeLimit minutes');

      // Start slide animation
      await _slideController.forward();

      if (!mounted) return;

      // Create new task with same title but new time limit
      await context.read<ActiveTasksCubit>().createTask(
            title: widget.task.title,
            timeLimitMinutes: newTimeLimit,
          );

      // Delete the missed task
      // ignore: use_build_context_synchronously
      await context.read<MissedTasksCubit>().deleteTask(widget.task.id);

      // Notify parent to remove this widget
      widget.onRescheduled?.call();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.schedule, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Task "${widget.task.title}" rescheduled for ${TimeUtils.formatMinutes(newTimeLimit)}! 🚀'),
                ),
              ],
            ),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error rescheduling task: $e');
      if (!mounted) return;

      // Reset animation on error
      _slideController.reset();
      setState(() {
        _isRescheduling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reschedule task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: (_isDeleting || _isRescheduling) ? 0 : null,
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: (_isDeleting || _isRescheduling) ? 0 : 8,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: (_isDeleting || _isRescheduling) ? _deleteFadeAnimation : _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              transform: Matrix4.identity()..scale((_isDeleting || _isRescheduling) ? 0.95 : 1.0),
              child: Card(
                elevation: (_isDeleting || _isRescheduling) ? 8 : 2,
                color: Colors.orange[50], // Light orange background for missed tasks
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: _isDeleting
                        ? Border.all(color: Colors.red, width: 2)
                        : _isRescheduling
                            ? Border.all(color: Colors.orange[700]!, width: 2)
                            : Border.all(color: Colors.orange[300]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row with Action Icons
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[800],
                              ),
                            ),
                          ),
                          // Reschedule Icon
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: GestureDetector(
                              onTap: (_isDeleting || _isRescheduling) ? null : () => _showRescheduleDialog(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (_isDeleting || _isRescheduling) ? Colors.grey[300] : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (_isDeleting || _isRescheduling) ? Colors.grey[400]! : Colors.orange[700]!,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: (_isDeleting || _isRescheduling) ? Colors.grey[600] : Colors.orange[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Reschedule',
                                      style: TextStyle(
                                        color: (_isDeleting || _isRescheduling) ? Colors.grey[600] : Colors.orange[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Add spacing between reschedule button and status badge
                          SizedBox(width: 12),

                          // Status Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cancel,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'MISSED',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Timer Info
                      Row(
                        children: [
                          Icon(
                            Icons.timer_off,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Time expired (${widget.task.timeLimitMinutes} min limit)',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // Bottom row with action hint and delete button
                      if (!_isDeleting && !_isRescheduling)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Tap 🔄 to reschedule',
                                  style: TextStyle(
                                    color: Colors.orange[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              // Delete button in bottom right
                              GestureDetector(
                                onTap: () => _showDeleteDialog(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
