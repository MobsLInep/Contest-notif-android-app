import 'package:flutter/material.dart';
import 'dart:async';

enum CountdownTimerSize { small, medium, large }

class CountdownTimer extends StatefulWidget {
  final int startTimeSeconds;
  final CountdownTimerSize size;
  final Color? textColor;
  const CountdownTimer({super.key, required this.startTimeSeconds, this.size = CountdownTimerSize.medium, this.textColor});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  String _timeLeft = '';

  @override
  void initState() {
    super.initState();
    _updateTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTimer() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final diff = widget.startTimeSeconds - now;
    if (diff <= 0) {
      setState(() => _timeLeft = 'Contest Started!');
      return;
    }
    final days = diff ~/ 86400;
    final hours = (diff % 86400) ~/ 3600;
    final minutes = (diff % 3600) ~/ 60;
    final seconds = diff % 60;
    if (days > 0) {
      setState(() => _timeLeft = '${days}d ${hours}h ${minutes}m');
    } else if (hours > 0) {
      setState(() => _timeLeft = '${hours}h ${minutes}m ${seconds}s');
    } else {
      setState(() => _timeLeft = '${minutes}m ${seconds}s');
    }
  }

  double getFontSize() {
    switch (widget.size) {
      case CountdownTimerSize.small:
        return 12;
      case CountdownTimerSize.medium:
        return 14;
      case CountdownTimerSize.large:
        return 18;
    }
  }

  FontWeight getFontWeight() {
    return widget.size == CountdownTimerSize.large ? FontWeight.bold : FontWeight.w600;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.size == CountdownTimerSize.large ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        if (widget.size == CountdownTimerSize.large)
          Text('Starts in', style: TextStyle(fontSize: 12, color: widget.textColor?.withValues(alpha: 0.5) ?? Colors.grey)),
        Text(
          _timeLeft,
          style: TextStyle(
            fontSize: getFontSize(),
            fontWeight: getFontWeight(),
            color: widget.textColor ?? (widget.size == CountdownTimerSize.large ? Colors.white : Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
} 