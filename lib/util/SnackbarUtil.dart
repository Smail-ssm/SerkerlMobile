import 'package:flutter/material.dart';

class SnackbarUtil {
  // Function to show a SnackBar
  static void showSnackbar({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
}
