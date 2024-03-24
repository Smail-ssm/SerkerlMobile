import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../HomePage.dart'; // Import your home page or the next page after signing up

class SignUpPage extends StatefulWidget {
  final User? user; // Declare user variable to accept user info

  SignUpPage({Key? key, this.user}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>(); // Declare and initialize _formKey

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  late TextEditingController _roleController;

  bool _isLoading = false;
  File? _profilePicture;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _roleController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
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
                      SizedBox(height: 12.0),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                      SizedBox(height: 12.0),
                      TextField(
                        controller: _fullNameController,
                        decoration: InputDecoration(labelText: 'Full Name'),
                      ),
                      SizedBox(height: 12.0),
                      TextField(
                        controller: _dateOfBirthController,
                        decoration: InputDecoration(
                            labelText: 'Date of Birth (YYYY-MM-DD)'),
                      ),
                      SizedBox(height: 12.0),
                      TextField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                      ),
                      SizedBox(height: 12.0),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                      ),
                      SizedBox(height: 12.0),
                      TextField(
                        controller: _roleController,
                        decoration:
                            InputDecoration(labelText: 'Role/Permissions'),
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _selectProfilePicture,
                        child: Text('Select Profile Picture'),
                      ),
                      SizedBox(height: 12.0),
                      _profilePicture != null
                          ? Image.file(_profilePicture!)
                          : SizedBox(),
                      SizedBox(height: 16.0),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _signUp,
                              child: Text('Sign Up'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectProfilePicture() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(
          pickedFile.path,
        );
      });
    }
  }

  _signUp() async {
    setState(() {
      _isLoading = true;
    });
    UserCredential?
        userCredential; // Declare userCredential outside the try-catch block

    try {
      setState(() {
        _isLoading = true;
      });

      // Step 1: Validate the form
      if (!_validateForm(_emailController, _passwordController,
          _usernameController, _fullNameController, context)) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Step 2: Check if a profile picture was uploaded and get its URL
      String? profilePictureUrl;
      if (_profilePicture != null) {
        // Get the file name with extension
        String fileName = _profilePicture!.path.split('/').last;

        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${userCredential.user!.uid}/$fileName');

        final uploadTask = storageRef.putFile(_profilePicture!);
        await uploadTask.whenComplete(() async {
          profilePictureUrl = await storageRef.getDownloadURL();
        });
      }

      // Step 3: Create user credentials with email and password

      // Step 4: Add user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'profilePictureUrl': profilePictureUrl ?? '',
        'dateOfBirth': _dateOfBirthController.text.isNotEmpty
            ? DateTime.parse(_dateOfBirthController.text)
            : null,
        'phoneNumber': _phoneNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'role': _roleController.text.trim(),
        'creationDate': Timestamp.now(),
      });

      // Step 5: Create User object

      // Step 6: Navigate to the home page
      Navigator.pushReplacement(
        context as BuildContext,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Delete the user account if an error occurs
      if (userCredential != null) {
        await userCredential.user?.delete();
      } // Show an error message if sign-up fails
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sign Up Failed'),
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

void showMessageDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
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

// Method to validate the form fields
// Method to validate the form fields
bool _validateForm(
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController usernameController,
    TextEditingController fullNameController,
    BuildContext context) {
  if (emailController.text.isEmpty ||
      passwordController.text.isEmpty ||
      usernameController.text.isEmpty ||
      fullNameController.text.isEmpty) {
    return false;
  }

  if (!_isValidEmail(emailController.text)) {
    // Show error message if email is not valid
    showMessageDialog(
        context, 'Validation Error', 'Please enter a valid email address');

    return false;
  }

  if (passwordController.text.length < 6) {
    // Show error message if password is too short
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text('Password must be at least 6 characters long.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    return false;
  }

  // All validations passed
  return true;
}

// Method to check if an email address is valid
bool _isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}
