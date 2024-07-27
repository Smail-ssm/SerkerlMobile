import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Import the intl package

import '../HomePage.dart'; // Import your home page or the next page after signing up

class SignUpPage extends StatefulWidget {
  final User? user; // Declare user variable to accept user info

  const SignUpPage({Key? key, this.user}) : super(key: key);

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
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Existing form and button widgets
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _dateOfBirthController,
                    readOnly: true,
                    // Make the field read-only to prevent manual editing
                    decoration: InputDecoration(
                        labelText: 'Date of Birth (YYYY-MM-DD)',
                        suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(
                                context) // Call function to show date picker
                            )),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    keyboardType:
                        TextInputType.phone, // Set keyboard type to phone
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _selectProfilePicture,
                    child: const Text('Select Profile Picture'),
                  ),
                  const SizedBox(height: 12.0),
                  _profilePicture != null
                      ? Image.file(_profilePicture!)
                      : const SizedBox(),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
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
        _profilePicture = File(
          pickedFile.path,
        );
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirthController.text.isNotEmpty
          ? DateTime.parse(_dateOfBirthController.text)
          : DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Correctly format the date using DateFormat
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dateOfBirthController.text = formattedDate;
    }
  }

  _signUp() async {
    setState(() {});
    UserCredential?
        userCredential; // Declare userCredential outside the try-catch block

    try {
      setState(() {});

      if (!_validateForm(_emailController, _passwordController,
          _usernameController, _fullNameController, context)) {
        setState(() {});
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

        final storageRef =
            firebase_storage.FirebaseStorage.instance.ref().child(
                  getFirestoreDocument() +
                      '/profile_pictures/${userCredential.user!.uid}/$fileName',
                );

        final uploadTask = storageRef.putFile(_profilePicture!);
        await uploadTask.whenComplete(() async {
          profilePictureUrl = await storageRef.getDownloadURL();
        });
      }

      // Step 3: Create user credentials with email and password

      // Step 4: Add user details to Firestore
      final String collectionName = getFirestoreDocument();

// Check if the collection name is empty or contains '/'
      if (collectionName.isEmpty || collectionName.contains('/')) {
        throw Exception(
            'Invalid collection name returned by getFirestoreDocument()');
      }

// Get the users collection
      final usersCollection = _firestore.collection(collectionName);
      String passwordEncrypted = await encryptDecryptText(
          _passwordController.text.trim(), EncryptionMode.encrypt);
// Create or update user document
      await usersCollection
          .doc('users')
          .collection(userCredential.user!.uid)
          .doc('user')
          .set({
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
        'creationDate': FieldValue
            .serverTimestamp(), // Use server timestamp instead of Timestamp.now()
      });

      // Step 5: Create User object
      saveSP('userId', userCredential.user!.uid);

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
            title: const Text('Sign Up Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {});
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
            child: const Text('OK'),
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

  if (!isValidEmail(emailController.text)) {
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
          title: const Text('Validation Error'),
          content: const Text('Password must be at least 6 characters long.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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
