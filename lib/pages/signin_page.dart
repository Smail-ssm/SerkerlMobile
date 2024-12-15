import 'dart:async';
import 'package:ebike/util/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/client.dart';
import '../util/util.dart';
import 'Map.dart';
import 'ResetPassword.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool _isPhoneNumber = false;
  bool _isOtpSent = false;
  String _verificationId = '';

  Client? client;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _buildBackground(screenHeight, context),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _buildSignInForm(screenHeight, screenWidth),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // Background decoration
  Widget _buildBackground(double screenHeight, BuildContext context) {
    return Container(
      height: screenHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
    );
  }

  // Main form UI
  Widget _buildSignInForm(double screenHeight, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.2),
        _buildFormContainer(screenWidth),
        SizedBox(height: screenHeight * 0.2),
      ],
    );
  }

  // Container for the form
  Widget _buildFormContainer(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      decoration: _boxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(),
            _buildEmailOrPhoneTextField(),
            const SizedBox(height: 12.0),
            if (!_isPhoneNumber) _buildPasswordTextField(),
            if (_isPhoneNumber && _isOtpSent) _buildOtpSection(),
            const SizedBox(height: 16.0),
            _buildSignInButton(),
            const SizedBox(height: 8.0),
            _buildSignUpTextButton(),
            const SizedBox(height: 8.0),
            _buildForgotPasswordButton(),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  // Decoration for the form container
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).scaffoldBackgroundColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 3,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Logo widget
  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Image.asset("assets/logo.png"),
      ),
    );
  }

  // Email/Phone input field
  Widget _buildEmailOrPhoneTextField() {
    return TextField(
      controller: _emailOrPhoneController,
      decoration: _inputDecoration('Email or Phone Number'),
      onChanged: (value) => setState(() => _isPhoneNumber = _isPhone(value)),
    );
  }
  bool _isPhone(String input) {
    final RegExp phoneRegExp = RegExp(r'^\d{8}$'); // Match 8-digit phone numbers
    return phoneRegExp.hasMatch(input);
  }
  Future<void> _resendOtp() async {
    final String phoneNumber = _emailOrPhoneController.text.trim();

    await _sendOtp(phoneNumber);
  }

  // Password input field
  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: _inputDecoration('Password'),
    );
  }

  // OTP input field and resend button
  Widget _buildOtpSection() {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Enter OTP'),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _resendOtp,
          child: const Text('Resend OTP'),
          style: _elevatedButtonStyle(),
        ),
      ],
    );
  }

  // Input decoration helper function
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  // Helper function to style buttons
  ButtonStyle _elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }

  // Sign-in button
  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _signIn),
      child: Text(_isOtpSent ? 'Verify OTP' : 'Sign In'),
      style: _elevatedButtonStyle(),
    );
  }

  // Sign up button
  Widget _buildSignUpTextButton() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUpPage()),
      ),
      child: const Text('Don\'t have an account? Sign up'),
    );
  }

  // Forgot password button
  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
      ),
      child: const Text('Forgot password? Reset it'),
    );
  }

  // Google sign-in button
  Widget _buildGoogleSignInButton() {
    return ElevatedButton.icon(
      onPressed: _signInWithGoogle,
      icon: const Icon(Icons.account_circle),
      label: const Text('Sign Up with Google'),
      style: _elevatedButtonStyle(),
    );
  }

  // Loading overlay
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // Helper methods for authentication
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      _isPhoneNumber ? await _sendOtp(_emailOrPhoneController.text.trim()) : await _emailSignIn();
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _emailSignIn() async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailOrPhoneController.text.trim(),
      password: _passwordController.text.trim(),
    );
    final client = await fetchClientData(userCredential.user!.uid);
    _navigateToHome(client!);
  }

  Future<void> _sendOtp(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+216$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCredential = await _auth.signInWithCredential(credential);
        final client = await fetchClientData(userCredential.user!.uid);
        _navigateToHome(client!);
      },
      verificationFailed: (e) => _showErrorDialog(context, e.message ?? 'Verification failed'),
      codeSent: (verificationId, _) => setState(() {
        _isOtpSent = true;
        _verificationId = verificationId;
      }),
      timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
    );
  }

  Future<void> _verifyOtp() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _otpController.text.trim(),
    );
    final userCredential = await _auth.signInWithCredential(credential);
    final client = await fetchClientData(userCredential.user!.uid);
    _navigateToHome(client!);
  }

  Future<void> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);

        // Try to fetch client data
        final client = await fetchClientData(userCredential.user!.uid);

        if (client != null) {
          // Navigate to Home if client exists
          _navigateToHome(client);
        } else {
          // Redirect to Signup if client does not exist
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SignUpPage(userCredential: userCredential)
              ));

        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error signing in with Google: $e',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }
  }

  // Helper methods for UI feedback and navigation
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign In Failed'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _navigateToHome(Client client) {
    saveSP('userId', _auth.currentUser!.uid);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MapPage(client: client)),
    );
  }
}
