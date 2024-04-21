import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String userId;
  String email;
  String username;
  String fullName;
  String profilePictureUrl;
  DateTime? dateOfBirth;
  String phoneNumber;
  String address;
  String role;
  DateTime creationDate;

  User({
    required this.userId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.profilePictureUrl,
    this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.creationDate,
  });
}

Future<Map<String, dynamic>> fetchUserData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId');

  Map<String, dynamic> userData = {};

  if (userId != null) {
    try {
      // Retrieve user document from Firestore using the user ID
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      // Check if the user document exists
      if (userDoc.exists) {
        // Extract user data from the document
        userData = userDoc.data() as Map<String, dynamic>;
      } else {
        // Handle case when user document does not exist
        print('User document not found');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error fetching user data: $e');
    }
  } else {
    // Handle case when user ID is not available in SharedPreferences
    print('User ID not found in SharedPreferences');
  }

  return userData;
}

Future<void> requestPermissions(BuildContext context) async {
  // List of permissions to request
  List<Permission> permissions = [
    Permission.location,
    Permission.notification,
    Permission.manageExternalStorage,
    Permission.photos,
    Permission.videos,
    Permission.audio
  ];

  // Request permissions
  Map<Permission, PermissionStatus> permissionStatus =
      await permissions.request();

  // Check permission statuses
  permissionStatus.forEach((permission, status) async {
    if (status.isDenied) {
      // Handle case when permission is denied
      bool openSettings = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                '${permission.toString().split('.').last[0].toUpperCase()}${permission.toString().split('.').last.substring(1)} Permission'),
            content: Text(
              '${permission.toString().split('.').last} permission is required to use the app. Please grant the permission in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );

      if (openSettings) {
        await openAppSettings(); // Open app settings
      }
    }
  });
}
