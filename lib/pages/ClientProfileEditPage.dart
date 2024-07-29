import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/client.dart';
import '../util/util.dart';

class UserProfileEditPage extends StatefulWidget {
  final Client? client;

  const UserProfileEditPage({Key? key, required this.client}) : super(key: key);

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
    _usernameController = TextEditingController(text: widget.client!.username);
    _fullNameController = TextEditingController(text: widget.client!.fullName);
    _phoneNumberController =
        TextEditingController(text: widget.client!.phoneNumber);
    _addressController = TextEditingController(text: widget.client!.address);
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
                        backgroundImage: NetworkImage(
                            widget.client!.profilePictureUrl ?? ''),
                        child: Text(widget.client!.username[0].toUpperCase())
                            ,
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

    final updatedUser = Client(
      userId: widget.client!.userId,
      email: widget.client!.email,
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      address: _addressController.text.trim(),
      role: widget.client!.role,
      profilePictureUrl: widget.client!.profilePictureUrl,
      creationDate: widget.client!.creationDate,
      password: '',
      dateOfBirth: widget.client!.dateOfBirth,
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

  Future<void> _updateUserInFirestore(Client updatedUser) async {
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
        .doc('client')
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

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
