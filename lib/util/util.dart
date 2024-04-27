import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showMessageDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Message'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

String getFirestoreDocument() {
  return kDebugMode ? 'preprod' : 'prod';
}

Future<void> saveSP(String variable, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(variable, value);
}

// Method to check if an email address is valid
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}
