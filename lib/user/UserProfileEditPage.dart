import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/userC.dart';
import '../util/util.dart';

class UserProfileEditPage extends StatefulWidget {
  final utilisateur user;

  UserProfileEditPage({required this.user});

  @override
  _UserProfileEditPageState createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  File? _profilePicture;
  bool _isLoading = false;
  bool _isUserInfoChanged = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneNumberController =
        TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveUserInfo,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            NetworkImage(widget.user.profilePictureUrl ?? ''),
                        child: _profilePicture == null &&
                                widget.user.profilePictureUrl == null
                            ? Text(widget.user.username[0].toUpperCase())
                            : null,
                      ),
                      IconButton(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                  _buildTextField('Username:', _usernameController),
                  _buildTextField('Full Name:', _fullNameController),
                  _buildTextField('Phone Number:', _phoneNumberController),
                  _buildTextField('Address:', _addressController),
                  // ElevatedButton(
                  //   child: const Text('Delete Account'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor:
                  //         Colors.red, // Visually indicate destructive action
                  //   ),
                  //   onPressed: () {
                  //     //_deleteUserAccount,
                  //   },
                  // ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                onChanged: (_) => _isUserInfoChanged = true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveUserInfo() async {
    if (!_isUserInfoChanged) {
      Navigator.pop(context);
      return;
    }

    final updatedUser = utilisateur(
      userId: widget.user.userId,
      email: widget.user.email,
      username: _usernameController.text.trim(),
      // password: widget.user.password,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      address: _addressController.text.trim(),
      profilePictureUrl: widget.user.profilePictureUrl,
      creationDate: widget.user.creationDate,
    );

    saveSP('edited', 'true');
    setState(() {
      _isLoading = true;
    });
    await _updateUserInFirestore(updatedUser);
    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  Future<void> _updateUserInFirestore(utilisateur updatedUser) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final usersCollection = _firestore.collection(getFirestoreDocument());
    Map<String, dynamic> updatedUserData = {
      'email': updatedUser.email,
      'username': _usernameController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'address': _addressController.text.trim(),
      'profilePictureUrl': updatedUser.profilePictureUrl,
    };

    await usersCollection
        .doc('users')
        .collection(updatedUser.userId)
        .doc('user')
        .update(updatedUserData);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  // Future<void> _deleteUserAccount() async {
  //   // 1. Confirmation Dialog:
  //   final confirmation = await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Delete Account'),
  //       content: const Text(
  //           'Are you sure you want to delete your account? This action is irreversible.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text('Delete'),
  //           style: TextButton.styleFrom(iconColor: Colors.red),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   // 2. Handle user confirmation:
  //   if (confirmation == true) {
  //     try {
  //       // 3. Delete user from Firebase Authentication:
  //       final user = FirebaseAuth.instance.currentUser;
  //       if (user != null) {
  //         final credential = EmailAuthProvider.credential(
  //             email: user.email!,
  //             password: await encryptDecryptText(
  //                 widget.user.password, EncryptionMode.decrypt));
  //         await user.reauthenticateWithCredential(credential);
  //         await FirebaseAuth.instance.currentUser!.delete();
  //       }
  //
  //       // 4. Delete profile picture from Firebase Storage:
  //       final profilePictureRef = FirebaseStorage.instance.ref().child(
  //           getFirestoreDocument() + '/profile_pictures/${widget.user.userId}');
  //       bool profilePictureExists = false;
  //       try {
  //         await profilePictureRef.getMetadata();
  //         profilePictureExists = true;
  //       } catch (e) {
  //         print('Profile picture not found: $e');
  //       }
  //
  //       if (profilePictureExists) {
  //         await profilePictureRef.delete();
  //         print('Profile picture deleted successfully');
  //       } else {
  //         print('No profile picture found');
  //       }
  //
  //       // 5. Delete user document from Firestore:
  //       final userDocRef = FirebaseFirestore.instance
  //           .collection(getFirestoreDocument())
  //           .doc('users')
  //           .collection(widget.user.userId)
  //           .doc('user');
  //       bool userDocExists = false;
  //       try {
  //         final userDoc = await userDocRef.get();
  //         if (userDoc.exists) {
  //           userDocExists = true;
  //         }
  //       } catch (e) {
  //         print('Error checking user document existence: $e');
  //       }
  //
  //       if (userDocExists) {
  //         await userDocRef.delete();
  //         print('User document deleted successfully');
  //       } else {
  //         print('No user document found');
  //       }
  //
  //       // Show success dialog
  //       await showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => WillPopScope(
  //           onWillPop: () => Future.value(false),
  //           child: AlertDialog(
  //             title: const Text('Account Deleted'),
  //             content: const Text(
  //                 'Your account data has been permanently deleted from all servers.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pushReplacement(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => SignInPage()),
  //                 ),
  //                 child: const Text('Go to Login'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     } catch (error) {
  //       // Show error dialog
  //       print('Error deleting account: $error');
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => WillPopScope(
  //           onWillPop: () => Future.value(false),
  //           child: AlertDialog(
  //             title: const Text('Error'),
  //             content: Text('Failed to delete account. Error: $error'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text('OK'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
