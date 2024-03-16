import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../HomePage.dart'; // Import your home page or the next page after signing up

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _roleController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
              decoration: InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
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
              decoration: InputDecoration(labelText: 'Role/Permissions'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _selectProfilePicture,
              child: Text('Select Profile Picture'),
            ),
            SizedBox(height: 12.0),
            SizedBox(height: 12.0),
            _profilePicture != null
                ? Image.file(_profilePicture!)
                : SizedBox(), // Display selected profile picture if available
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
    );
  }

  void _selectProfilePicture() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path,);
      });
    }
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseUser userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Upload profile picture to Firebase Storage
      // Upload profile picture to Firebase Storage
      String? profilePictureUrl;
      if (_profilePicture != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('profile_pictures/${userCredential.uid}');
        await storageRef.putFile(_profilePicture!); // Use ! operator to assert non-nullability
        profilePictureUrl = await storageRef.getDownloadURL();
      }

      // Create the user in Firestore
      await _firestore.collection('users').doc(userCredential.uid).set({
        'userId': userCredential.uid,
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'profilePictureUrl': profilePictureUrl ?? '', // If profile picture was not uploaded, store an empty string
        'dateOfBirth': _dateOfBirthController.text.isNotEmpty ? DateTime.parse(_dateOfBirthController.text) : null,
        'phoneNumber': _phoneNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'role': _roleController.text.trim(),
        'creationDate': Timestamp.now(),
      });

      // Navigate to the home page after successful sign-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Show an error message if sign-up fails
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
