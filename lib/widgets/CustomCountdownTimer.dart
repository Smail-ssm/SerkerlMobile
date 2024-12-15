import 'package:flutter/material.dart';

class CustomCountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onEnd;

  const CustomCountdownTimer({required this.duration, required this.onEnd});

  @override
  _CustomCountdownTimerState createState() => _CustomCountdownTimerState();
}

class _CustomCountdownTimerState extends State<CustomCountdownTimer> {
  late Duration _remainingDuration;

  @override
  void initState() {
    super.initState();
    _remainingDuration = widget.duration;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_remainingDuration.inSeconds > 0) {
        setState(() {
          _remainingDuration -= const Duration(seconds: 1);
        });
      } else {
        widget.onEnd();
        return false; // stop loop when timer reaches 0
      }
      return true; // keep looping
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_remainingDuration.inMinutes}:${_remainingDuration.inSeconds % 60}',
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
