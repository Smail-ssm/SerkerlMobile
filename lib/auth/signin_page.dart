import 'package:ebike/auth/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../HomePage.dart';
import 'ResetPassword.dart';
 // Import your reset password page

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _signIn,
                    child: Text('Sign In'),
                  ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUpPage()), // Navigate to sign-up page
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
            SizedBox(height: 8.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ResetPasswordPage()), // Navigate to reset password page
                );
              },
              child: Text('Forgot password? Reset it'),
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseUser userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If sign-in is successful, navigate to the home page or next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage()), // Replace HomePage() with your actual home page
      );
    } catch (e) {
      // Show an error message if sign-in fails
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sign In Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
