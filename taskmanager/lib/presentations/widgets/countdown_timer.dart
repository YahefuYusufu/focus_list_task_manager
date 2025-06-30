import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/task_model.dart';
import '../../utils/time_utils.dart';

class CountdownTimer extends StatefulWidget {
  final Task task;
  final VoidCallback onExpired;
  final Function(int) onTick;

  const CountdownTimer({
    super.key,
    required this.task,
    required this.onExpired,
    required this.onTick,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimer() {
    _remainingSeconds = widget.task.calculateRemainingSeconds();

    if (_remainingSeconds > 0) {
      _startTimer();
    } else {
      widget.onExpired();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds = widget.task.calculateRemainingSeconds();
      });

      widget.onTick(_remainingSeconds);

      if (_remainingSeconds <= 0) {
        timer.cancel();
        widget.onExpired();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds <= 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Text(
          'EXPIRED',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final timeColor = _getTimeColor(_remainingSeconds);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: timeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: timeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: timeColor,
          ),
          SizedBox(width: 4),
          Text(
            TimeUtils.formatDuration(_remainingSeconds),
            style: TextStyle(
              color: timeColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimeColor(int seconds) {
    if (TimeUtils.isInUrgentState(seconds)) {
      return Colors.red;
    } else if (TimeUtils.isInWarningState(seconds)) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
