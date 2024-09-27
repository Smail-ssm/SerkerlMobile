import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
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
  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController(); // Controller for OTP
  bool _isLoading = false;
  bool _isPhoneNumber = false; // Track if user is using phone number
  bool _isOtpSent = false; // Track if OTP is sent
  bool _canResendOtp = false; // Track if resend OTP button is enabled
  int _timer = 60; // Countdown timer
  String _verificationId = ''; // Store the verification ID
  Client? client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true, // This helps to resize the UI when the keyboard is opened
      body: Stack(
        children: [
          Container(
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
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.2, // Adjust this height as needed for top spacing
                  ),
                  Container(
                    width: screenWidth * 0.9, // Ensures form is responsive
                    decoration: BoxDecoration(
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
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: SizedBox(
                              height: screenHeight * 0.15, // Adjust logo size dynamically
                              width: screenHeight * 0.15,
                              child: Image.asset("assets/logo.png"),
                            ),
                          ),
                          _buildEmailOrPhoneTextField(),
                          const SizedBox(height: 12.0),
                          if (!_isPhoneNumber) _buildPasswordTextField(),
                          if (_isPhoneNumber && _isOtpSent) ...[
                            const SizedBox(height: 12.0),
                            _buildOtpTextField(),
                            const SizedBox(height: 16.0),
                            _buildResendOtpButton(), // New button for resending OTP
                          ],
                          const SizedBox(height: 16.0),
                          _buildSignInButton(),
                          const SizedBox(height: 8.0),
                          _buildSignUpTextButton(context),
                          const SizedBox(height: 8.0),
                          _buildForgotPasswordButton(context),
                          _buildGoogleSignInButton(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.2, // Adjust this height as needed for bottom spacing
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResendOtpButton() {
    return ElevatedButton(
      onPressed: _canResendOtp ? _resendOtp : null,
      child: _canResendOtp ? const Text('Resend OTP') : Text('Resend OTP in $_timer seconds'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }


  Widget _buildEmailOrPhoneTextField() {
    return TextField(
      controller: _emailOrPhoneController,
      decoration: InputDecoration(
        labelText: 'Email or Phone Number',
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _isPhoneNumber = _isPhone(value);
        });
      },
    );
  }

  bool _isPhone(String input) {
    final RegExp phoneRegExp = RegExp(r'^\d{8}$'); // Match 8-digit phone numbers
    return phoneRegExp.hasMatch(input);
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildOtpTextField() {
    return TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Enter OTP',
        labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _signIn),
      child: Text(_isOtpSent ? 'Verify OTP' : 'Sign In'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary, // Ensures the text is visible
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  Widget _buildSignUpTextButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const SignUpPage(),
        ));
      },
      child: const Text('Don\'t have an account? Sign up'),
    );
  }

  Widget _buildForgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => const ResetPasswordPage(),
        ));
      },
      child: const Text('Forgot password? Reset it'),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SignInButton(
      Buttons.Google,
      onPressed: _signInWithGoogle,
    );
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isPhoneNumber) {
        final String phoneNumber = _emailOrPhoneController.text.trim();
        await _sendOtp(phoneNumber);
      } else {
        // Email sign-in
        final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailOrPhoneController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final client = await fetchClientData(userCredential.user!.uid);

        saveSP('userId', userCredential.user!.uid);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => MapPage(client: client),
        ));
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOtp(String phoneNumber) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String env = getFirestoreDocument();

    // Check if a user with this phone number already exists in Firestore
    final QuerySnapshot querySnapshot = await _firestore
        .collection(env)
        .doc('users')
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // User exists, send OTP for verification
      _showToast('User exists. Sending OTP for verification...');
    } else {
      // New user, inform that an account will be created
      _showToast('Phone number not registered. A new account will be created after OTP verification.');
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+216' + phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign-in on verification completion
        await _auth.signInWithCredential(credential);
        _navigateToHome();
      },
      verificationFailed: (FirebaseAuthException e) {
        _showErrorDialog(context, e.message ?? 'OTP verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isOtpSent = true;
          _verificationId = verificationId;
        });
        _showToast('OTP sent to your phone number');
        _startOtpCountdown(); // Start countdown timer
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
  }
  Future<void> _resendOtp() async {
    final String phoneNumber = _emailOrPhoneController.text.trim();
    setState(() {
      _canResendOtp = false;
      _timer = 60;
    });
    await _sendOtp(phoneNumber);
  }

  void _startOtpCountdown() {
    setState(() {
      _canResendOtp = false;
      _timer = 60;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timer > 0) {
          _timer--;
        } else {
          _canResendOtp = true;
          timer.cancel();
        }
      });
    });
  }
  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Check if a user with this phone number already exists in Firestore
      final QuerySnapshot querySnapshot = await _firestore
          .collection(getFirestoreDocument()) // Replace with your environment
          .doc('users')
          .collection('users')
          .where('phoneNumber', isEqualTo: _emailOrPhoneController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final existingUserDoc = querySnapshot.docs.first;

        // Create a Client object from the Firestore document data
        final Client existingUser = Client(
          userId: existingUserDoc['userId'],
          email: existingUserDoc['email'],
          username: existingUserDoc['username'],
          fullName: existingUserDoc['fullName'],
          profilePictureUrl: existingUserDoc['profilePictureUrl'],
          dateOfBirth: existingUserDoc['dateOfBirth']?.toDate() ?? DateTime.now(),
          phoneNumber: existingUserDoc['phoneNumber'],
          address: existingUserDoc['address'],
          role: existingUserDoc['role'],
          password: '', // Password is not required in this case
          fcmToken: existingUserDoc['fcmToken'] ?? '',
          balance: (existingUserDoc['balance'] as num?)?.toDouble() ?? 0.0,
          creationDate: existingUserDoc['creationDate']?.toDate() ?? DateTime.now(),
        );

        // Navigate to the home page with the existing user object
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(client: existingUser),
          ),
        );
      } else {
        // No user found, create a new user entity
        final client = Client(
          userId: userCredential.user!.uid,
          email: '', // Email is not used in this case
          username: 'New User', // Default username
          fullName: '', // Full name to be collected later
          profilePictureUrl: '', // Optional
          dateOfBirth: DateTime.now(), // Optional or request later
          phoneNumber: _emailOrPhoneController.text.trim(),
          address: '', // Optional or request later
          role: 'user', // Default role
          password: '', // Password not needed for phone auth
          fcmToken: '', // Optional or request later
          balance: 0.0, // Default balance
          creationDate: DateTime.now(),
        );

        // Save the new client entity to Firestore
        await _createUserInFirestore(client);

        // Save userId locally if needed
        saveSP('userId', userCredential.user!.uid);

        // Navigate to the MapPage with the new client object
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(client: client),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          // Create a Client object from the Firebase User object
          final Client client = Client(
            userId: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            username: firebaseUser.displayName ?? 'Unknown User',
            fullName: firebaseUser.displayName ?? '',
            profilePictureUrl: firebaseUser.photoURL ?? '',
            dateOfBirth: DateTime.now(), // Use a placeholder or request this info
            phoneNumber: firebaseUser.phoneNumber ?? '',
            address: '', // Optional or request from user
            role: 'user', // Default role
            password: '', // Not stored, but needed for the model
            fcmToken: '', // Request from user or leave blank
            balance: 0.0, // Default balance
            creationDate: DateTime.now(), // Set current date as creation date
          );

          // Check if user is new and save to Firestore if needed
          if (userCredential.additionalUserInfo!.isNewUser) {
            await _createUserInFirestore(client);
          }

          // Navigate to the MapPage with the client object
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(client: client),
            ),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error signing in with Google: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _createUserInFirestore(Client user) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String env = getFirestoreDocument();

    final userDocRef = _firestore
        .collection(env)
        .doc('users')
        .collection('users')
        .doc(user.userId);

    await userDocRef.set({
      'userId': user.userId,
      'email': user.email ?? '',
      'username': user.fullName,
      'fullName': user.fullName,
      'profilePictureUrl': user.profilePictureUrl ?? 'NO IMAGE',
      'dateOfBirth': null,
      'phoneNumber': user.phoneNumber ?? _emailOrPhoneController.text.trim(),
      'address': ' ',
      'role': 'client',
      'creationDate': FieldValue.serverTimestamp(),
      'password': '', // Password not needed for phone auth
      'fcmToken': '', // Optional or request later
      'balance': 0.0,});

     saveSP('userId', user.userId);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  void _navigateToHome() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      saveSP('userId', currentUser.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(client: client),
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign In Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
