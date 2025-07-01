import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanager/presentations/cubits/active_tasks_cubit.dart';
import 'package:taskmanager/presentations/cubits/completed_tasks_cubit.dart';
import '../../models/task_model.dart';

class SimpleActiveTaskCard extends StatefulWidget {
  final Task task;

  const SimpleActiveTaskCard({
    super.key,
    required this.task,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SimpleActiveTaskCardState createState() => _SimpleActiveTaskCardState();
}

class _SimpleActiveTaskCardState extends State<SimpleActiveTaskCard> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _deleteFadeAnimation;

  bool _isCompleting = false;
  bool _isDeleting = false;

  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.task.calculateRemainingSeconds();
    _startTimer();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _entranceController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

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

    _entranceController.forward();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final seconds = widget.task.calculateRemainingSeconds();
      if (seconds > 0) {
        setState(() {
          _remainingSeconds = seconds;
        });
      } else {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
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
                'Delete Active Task',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${widget.task.title}"?\n\nThis will permanently remove it from your active tasks and cancel any scheduled notifications.',
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

  Future<void> _deleteTask() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      print('🗑️ Deleting active task: ${widget.task.title}');

      // Start delete animation
      await _slideController.forward();

      if (!mounted) return;

      // Delete the task using the cubit (notifications handled automatically in cubit)
      await context.read<ActiveTasksCubit>().deleteTask(widget.task.id);

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Active task "${widget.task.title}" deleted'),
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
      print('Error deleting active task: $e');
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

  Future<void> _completeTask() async {
    if (_isCompleting || _isDeleting) return;

    setState(() {
      _isCompleting = true;
    });

    try {
      print('🎯 Completing task: ${widget.task.title}');

      // Start slide animation
      await _slideController.forward();

      if (!mounted) return;

      // Complete the task (notifications handled automatically in cubit)
      await context.read<ActiveTasksCubit>().completeTask(widget.task.id);

      if (!mounted) return;

      // Refresh completed tasks
      context.read<CompletedTasksCubit>().loadCompletedTasks();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Task "${widget.task.title}" completed! 🎉'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error completing task: $e');
      if (!mounted) return;

      // Reset animation on error
      _slideController.reset();
      setState(() {
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: (_isDeleting || _isCompleting) ? 0 : null,
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: (_isDeleting || _isCompleting) ? 0 : 8,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: (_isDeleting || _isCompleting) ? _deleteFadeAnimation : _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              transform: Matrix4.identity()..scale((_isDeleting || _isCompleting) ? 0.95 : 1.0),
              child: Card(
                elevation: (_isDeleting || _isCompleting) ? 8 : 2,
                color: Colors.blue[50], // Light blue background for active tasks
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: _isDeleting
                        ? Border.all(color: Colors.red, width: 2)
                        : _isCompleting
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(color: Colors.blue[200]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Row with Status Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.task.title.isEmpty ? 'NO TITLE' : widget.task.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isCompleting ? Colors.grey[600] : Colors.blue[800],
                                decoration: _isCompleting ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),

                          // Status Badge with notification indicator
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isCompleting ? Colors.green[100] : Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isCompleting ? Colors.green : Colors.blue,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCompleting ? Icons.check_circle : Icons.play_circle_filled,
                                  size: 16,
                                  color: _isCompleting ? Colors.green : Colors.blue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _isCompleting ? 'COMPLETING' : 'ACTIVE',
                                  style: TextStyle(
                                    color: _isCompleting ? Colors.green : Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Add notification indicator for active tasks
                                if (!_isCompleting && !_isDeleting) ...[
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.notifications_active,
                                    size: 12,
                                    color: Colors.blue[600],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      // Timer Display
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: _remainingSeconds / (widget.task.timeLimitMinutes * 60),
                                strokeWidth: 6,
                                backgroundColor: Colors.blue[100],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTime(_remainingSeconds),
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 8),

                      // Task Info
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.blue[600],
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Time limit: ${widget.task.timeLimitMinutes} minutes',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Add notification info
                      if (!_isCompleting && !_isDeleting)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                size: 16,
                                color: Colors.blue[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Notification 10s before expiry',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 16),

                      // Action Buttons Row
                      Row(
                        children: [
                          // Complete Button
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 300),
                                child: _isCompleting
                                    ? ElevatedButton.icon(
                                        key: Key('completing'),
                                        onPressed: null,
                                        icon: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        label: Text('Completing...'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        key: Key('complete'),
                                        onPressed: (_isDeleting || _isCompleting) ? null : _completeTask,
                                        icon: Icon(Icons.check, size: 18),
                                        label: Text('Mark as Done'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (_isDeleting || _isCompleting) ? Colors.grey[400] : Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          // Delete Button
                          GestureDetector(
                            onTap: (_isDeleting || _isCompleting) ? null : () => _showDeleteDialog(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (_isDeleting || _isCompleting) ? Colors.grey[300] : Colors.red[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (_isDeleting || _isCompleting) ? Colors.grey[400]! : Colors.red,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: (_isDeleting || _isCompleting) ? Colors.grey[600] : Colors.red,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: (_isDeleting || _isCompleting) ? Colors.grey[600] : Colors.red,
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
