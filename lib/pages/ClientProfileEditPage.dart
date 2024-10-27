import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../model/client.dart';
import '../util/util.dart';
import 'package:path/path.dart' as path;

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
                _buildEditableUserInfoRow(
                    'Phone Number', _phoneNumberController),
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
            backgroundColor: Colors.grey[200], // Set a background color
            child: _profilePicture != null
                ? ClipOval(
              child: Image.file(
                _profilePicture!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            )
                : Icon(
              profilePictureUrl != null && profilePictureUrl.isNotEmpty
                  ? Icons.account_circle // Use a user icon if there is no image
                  : Icons.person, // Default icon for no profile picture
              size: 80,
              color: Colors.grey[700], // You can adjust the color if necessary
            ),
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

    setState(() {
      _isLoading = true;
    });

    String? profilePictureUrl = widget.client!.profilePictureUrl;

    // If the user selected a new profile picture, upload it
    if (_profilePicture != null) {
      profilePictureUrl =
          await _uploadProfilePicture(_profilePicture!, widget.client!.userId);
    }

    final updatedUser = Client(
      userId: widget.client!.userId,
      email: widget.client!.email,
      username: _usernameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      address: _addressController.text.trim(),
      role: widget.client!.role,
      profilePictureUrl: profilePictureUrl,
      // Use the new or existing URL
      creationDate: widget.client!.creationDate,
      referralCode: widget.client!.referralCode,
      password: '',
      lat:0,
      lng: 0,
      balance: widget.client!.balance,
      fcmToken: await  getSP("fcmToken"),
      dateOfBirth: widget.client!.dateOfBirth,
    );

    await _updateUserInFirestore(updatedUser);

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  Future<void> _updateUserInFirestore(Client updatedUser) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String env = getFirestoreDocument(); // Get environment (e.g., 'preprod')

    final userDocRef = _firestore
        .collection(env)
        .doc('users')  // This refers to the 'users' collection
        .collection('users')  // This is where individual users' documents are stored
        .doc(updatedUser.userId);  // Referencing the specific user by their ID

    // Prepare the updated data
    Map<String, dynamic> updatedUserData = {
      'email': updatedUser.email,
      'username': _usernameController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'address': _addressController.text.trim(),
      'profilePictureUrl': updatedUser.profilePictureUrl ?? 'NO IMAGE',
    };

    // Update the user's document in Firestore
    await userDocRef.update(updatedUserData);

    // Optionally, handle any success or error feedback for the update operation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User updated successfully')),
    );
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

  Future<String> _uploadProfilePicture(File profilePicture, String userId) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;
    String documentPath = kDebugMode ? 'preprod' : 'prod';

    // Extract the file extension from the original file
    String fileExtension = path.extension(profilePicture.path);

    // Create a reference to the location with the correct file extension
    final storageRef = _storage.ref().child('$documentPath/profilePictures/$userId$fileExtension');

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageRef.putFile(profilePicture);

    // Wait until the upload is complete
    TaskSnapshot snapshot = await uploadTask;

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
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
