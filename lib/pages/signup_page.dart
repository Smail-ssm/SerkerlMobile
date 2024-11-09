import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

// Import your home page or the next page after signing up

class SignUpPage extends StatefulWidget {
  final User? user; // Declare user variable to accept user info

  const SignUpPage({Key? key, this.user}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _emailOrPhoneController;
  late TextEditingController _passwordController;
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _addressController;
  late TextEditingController _roleController;
  late TextEditingController _otpController;

  bool _isLoading = false;
  bool _isPhoneNumber = false; // To check if the user is using phone number
  bool _isOtpSent = false; // To track if OTP is sent
  String _verificationId = ''; // Store the verification ID
  File? _profilePicture;

  @override
  void initState() {
    super.initState();
    _emailOrPhoneController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _addressController = TextEditingController();
    _roleController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
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
                      _emailOrPhoneController, 'Email or Phone Number', Icons.email, TextInputType.text),
                  const SizedBox(height: 20.0),
                  if (!_isPhoneNumber) ...[
                    _buildTextField(
                      _passwordController,
                      'Password',
                      Icons.lock,
                      TextInputType.visiblePassword,
                    ),
                    const SizedBox(height: 20.0),
                  ],
                  _buildTextField(_usernameController, 'Username', Icons.person),
                  const SizedBox(height: 20.0),
                  _buildTextField(_fullNameController, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 20.0),
                  _buildDateOfBirthField(),
                  const SizedBox(height: 20.0),
                  _buildTextField(_addressController, 'Address', Icons.location_on),
                  const SizedBox(height: 20.0),
                  _buildTextField(_roleController, 'Role/Permissions', Icons.security),
                  if (_isPhoneNumber && _isOtpSent) ...[
                    const SizedBox(height: 20.0),
                    _buildTextField(
                      _otpController,
                      'Enter OTP',
                      Icons.message,
                      TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 20.0),
                  ElevatedButton.icon(
                    onPressed: _selectProfilePicture,
                    icon: const Icon(Icons.photo),
                    label: const Text('Select Profile Picture'),
                  ),
                  if (_profilePicture != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Image.file(
                        _profilePicture!,
                        height: 100.0,
                      ),
                    ),
                  const SizedBox(height: 30.0),
                  _buildSignUpButton(),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
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
          onChanged: (value) {
            setState(() {
              _isPhoneNumber = _isPhone(value);
            });
          },
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
        onPressed: _isOtpSent ? _verifyOtp : _signUp,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Text(
          _isOtpSent ? 'Verify OTP' : 'SIGN UP',
          style: const TextStyle(
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

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isPhoneNumber) {
        // Send OTP to phone number
        await _auth.verifyPhoneNumber(
          phoneNumber: _emailOrPhoneController.text.trim(),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-sign-in on verification completion
            await _auth.signInWithCredential(credential);
            _createUserInFirestore(FirebaseAuth.instance.currentUser!);
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
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
      } else {
        // Email sign up
        if (!_validateForm(_emailOrPhoneController, _passwordController, _usernameController, _fullNameController, context)) {
          setState(() {
            _isLoading = false;
          });
          return;
        }

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailOrPhoneController.text.trim(),
          password: _passwordController.text.trim(),
        );

        _createUserInFirestore(userCredential.user!);
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

      _createUserInFirestore(userCredential.user!);
    } catch (e) {
      _showErrorDialog(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createUserInFirestore(User user) async {
    // Upload profile picture if present
    String? profilePictureUrl;
    if (_profilePicture != null) {
      String fileName = _profilePicture!.path.split('/').last;
      final storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user.uid}/$fileName');
      final uploadTask = storageRef.putFile(_profilePicture!);
      await uploadTask.whenComplete(() async {
        profilePictureUrl = await storageRef.getDownloadURL();
      });
    }

    final String env = getFirestoreDocument();

    final userDocRef = _firestore
        .collection(env)
        .doc('users')
        .collection('users')
        .doc(user.uid);

    await userDocRef.set({
      'userId': user.uid,
      'email': user.email ?? '',
      'username': _usernameController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'profilePictureUrl': profilePictureUrl ?? 'NO IMAGE',
      'dateOfBirth': _dateOfBirthController.text.isNotEmpty
          ? DateTime.parse(_dateOfBirthController.text)
          : null,
      'phoneNumber': user.phoneNumber ?? _emailOrPhoneController.text.trim(),
      'address': _addressController.text.trim(),
      'role': 'client',
      'creationDate': FieldValue.serverTimestamp(),
    });

    saveSP('userId', user.uid);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  bool _validateForm(
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController usernameController,
      TextEditingController fullNameController,
      BuildContext context,
      ) {
    if (!_isPhoneNumber && (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        fullNameController.text.isEmpty)) {
      showMessageDialog(
          context, 'Validation Error', 'Please fill in all required fields.');
      return false;
    }

    if (!_isPhoneNumber && !isValidEmail(emailController.text)) {
      showMessageDialog(
          context, 'Validation Error', 'Please enter a valid email address.');
      return false;
    }

    if (!_isPhoneNumber && passwordController.text.length < 6) {
      showMessageDialog(context, 'Validation Error',
          'Password must be at least 6 characters long.');
      return false;
    }

    return true;
  }

  bool _isPhone(String input) {
    final RegExp phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(input);
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Up Failed'),
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
