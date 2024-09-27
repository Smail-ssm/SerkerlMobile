import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'Map.dart'; // Import your home page or the next page after signing up

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
    // Get theme data
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Background color from theme
            Container(
              height: double.infinity,
              width: double.infinity,
              color: theme.scaffoldBackgroundColor,
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Create Account',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 30.0),
                  _buildTextField(
                      _emailController, 'Email', Icons.email, TextInputType.emailAddress),
                  const SizedBox(height: 20.0),
                  _buildTextField(
                    _passwordController,
                    'Password',
                    Icons.lock,
                    TextInputType.visiblePassword,
                   ),
                  const SizedBox(height: 20.0),
                  _buildTextField(_usernameController, 'Username', Icons.person),
                  const SizedBox(height: 20.0),
                  _buildTextField(_fullNameController, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 20.0),
                  _buildDateOfBirthField(),
                  const SizedBox(height: 20.0),
                  _buildTextField(_phoneNumberController, 'Phone Number', Icons.phone,
                      TextInputType.phone),
                  const SizedBox(height: 20.0),
                  _buildTextField(_addressController, 'Address', Icons.location_on),
                  const SizedBox(height: 20.0),
                  _buildTextField(_roleController, 'Role/Permissions', Icons.security),
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: _selectProfilePicture,
                    icon: const Icon(Icons.photo),
                    label: const Text('Select Profile Picture'),
                  ),
                  _profilePicture != null
                      ? Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Image.file(
                      _profilePicture!,
                      height: 100.0,
                    ),
                  )
                      : const SizedBox(),
                  const SizedBox(height: 30.0),
                  _buildSignUpButton(),
                ],
              ),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
      ]) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.iconTheme.color),
            hintText: 'Enter your $label',
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: _buildTextField(
          _dateOfBirthController,
          'Date of Birth (YYYY-MM-DD)',
          Icons.calendar_today,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signUp,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
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
        _profilePicture = File(pickedFile.path);
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
      final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      _dateOfBirthController.text = formattedDate;
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    UserCredential? userCredential;

    try {
      // Validate the form
      if (!_validateForm(
          _emailController,
          _passwordController,
          _usernameController,
          _fullNameController,
          context)) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create the user with Firebase Authentication
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Upload profile picture if present
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

      // Get the environment collection name (e.g., 'preprod')
      final String env = getFirestoreDocument();

      // Reference to the user document under the path /{env}/users/users/{userId}
      final userDocRef = _firestore
          .collection(env) // Environment collection
          .doc('users') // 'users' document
          .collection('users') // 'users' collection under 'users' document
          .doc(userCredential.user!.uid); // User's document with userId

      // Set the user data directly in the user's document
      await userDocRef.set({
        'userId': userCredential.user!.uid,
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'profilePictureUrl': profilePictureUrl ?? 'NO IMAGE',
        'dateOfBirth': _dateOfBirthController.text.isNotEmpty
            ? DateTime.parse(_dateOfBirthController.text)
            : null,
        'phoneNumber': _phoneNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'role': _roleController.text.trim(),
        'creationDate': FieldValue.serverTimestamp(),
      });

      // Save userId locally if needed
      saveSP('userId', userCredential.user!.uid);

      // Navigate to the SignInPage or any other page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    } catch (e) {
      // If user creation failed, delete the user from Firebase Auth
      if (userCredential != null) {
        await userCredential.user?.delete();
      }
      // Show an error dialog
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _validateForm(
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController usernameController,
      TextEditingController fullNameController,
      BuildContext context,
      ) {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        fullNameController.text.isEmpty) {
      showMessageDialog(
          context, 'Validation Error', 'Please fill in all required fields.');
      return false;
    }

    if (!isValidEmail(emailController.text)) {
      showMessageDialog(
          context, 'Validation Error', 'Please enter a valid email address.');
      return false;
    }

    if (passwordController.text.length < 6) {
      showMessageDialog(context, 'Validation Error',
          'Password must be at least 6 characters long.');
      return false;
    }

    return true;
  }

  void showMessageDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(title, style: theme.textTheme.headlineMedium),
          content: Text(message, style: theme.textTheme.bodyMedium),
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
}
