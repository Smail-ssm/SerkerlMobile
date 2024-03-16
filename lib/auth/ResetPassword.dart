import 'package:flutter/material.dart';

class ResetPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Email or Mobile Number'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Perform password reset logic here
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
