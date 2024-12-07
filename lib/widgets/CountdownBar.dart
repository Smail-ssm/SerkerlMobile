import 'package:flutter/material.dart';

class CountdownBar extends StatelessWidget {
  final int secondsRemaining;

  const CountdownBar({Key? key, required this.secondsRemaining}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        'Time Remaining: ${_formatTime(secondsRemaining)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }
}
