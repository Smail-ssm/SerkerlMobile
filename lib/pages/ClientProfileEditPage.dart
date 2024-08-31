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
    _phoneNumberController = TextEditingController(text: widget.client!.phoneNumber);
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(widget.client?.profilePictureUrl),
                const SizedBox(height: 16),
                _buildSectionHeader('Personal Information'),
                const Divider(),
                _buildEditableUserInfoRow('Username', _usernameController),
                _buildEditableUserInfoRow('Full Name', _fullNameController),
                _buildEditableUserInfoRow('Phone Number', _phoneNumberController),
                _buildEditableUserInfoRow('Address', _addressController),
              ],
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

  Widget _buildUserAvatar(String? profilePictureUrl) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _profilePicture != null
                ? FileImage(_profilePicture!)
                : (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                ? NetworkImage(profilePictureUrl) as ImageProvider
                : const AssetImage('assets/default_avatar.png'),
            child: _profilePicture == null && (profilePictureUrl == null || profilePictureUrl.isEmpty)
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              padding: const EdgeInsets.all(5.0),
              constraints: const BoxConstraints(),
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEditableUserInfoRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            onChanged: (_) => _isUserInfoChanged = true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
        _isUserInfoChanged = true; // Mark as changed after picking a new image
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
