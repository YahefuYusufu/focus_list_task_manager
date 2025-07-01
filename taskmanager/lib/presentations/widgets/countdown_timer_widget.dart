import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/task_model.dart';
import '../../utils/time_utils.dart';

class CountdownTimerWidget extends StatefulWidget {
  final Task task;
  final VoidCallback onExpired;

  const CountdownTimerWidget({
    super.key,
    required this.task,
    required this.onExpired,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
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
      if (mounted) {
        setState(() {
          _remainingSeconds = widget.task.calculateRemainingSeconds();
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          widget.onExpired();
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_remainingSeconds <= 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 16,
              color: colorScheme.error,
            ),
            SizedBox(width: 4),
            Text(
              'EXPIRED',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final timeColor = _getTimeColor(_remainingSeconds, colorScheme);
    final containerColor = _getContainerColor(_remainingSeconds, colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: timeColor.withValues(alpha: 0.5)),
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

  Color _getTimeColor(int seconds, ColorScheme colorScheme) {
    if (TimeUtils.isInUrgentState(seconds)) {
      return colorScheme.error;
    } else if (TimeUtils.isInWarningState(seconds)) {
      return colorScheme.tertiary;
    } else {
      return colorScheme.secondary;
    }
  }

  Color _getContainerColor(int seconds, ColorScheme colorScheme) {
    if (TimeUtils.isInUrgentState(seconds)) {
      return colorScheme.errorContainer;
    } else if (TimeUtils.isInWarningState(seconds)) {
      return colorScheme.tertiaryContainer; // Orange container for warning
    } else {
      return colorScheme.primaryContainer; // Green container for safe
    }
  }
}
