import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class Client {
  String userId; // Unique identifier for the user
  String email; // Email address of the user
  String username; // Username of the user
  String fullName; // Full name of the user
  String profilePictureUrl; // URL of the profile picture (optional)
  DateTime dateOfBirth; // Date of birth of the user (optional)
  String phoneNumber; // Phone number of the user
  String address; // Address of the user
  String role; // Role of the user (e.g., admin, user)
  String password; // Password for the user account
  DateTime creationDate; // Account creation date

  Client({
    required this.userId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.profilePictureUrl,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.password,
    required this.creationDate,
  });

// Add a factory constructor to create Utilisateur from Firestore data
  factory Client.fromFirestore(Map<String, dynamic> data) {
    return Client(
      userId: data['userId'] as String,
      email: data['email'] as String,
      username: data['username'] as String,
      fullName: data['fullName'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String,
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      phoneNumber: data['phoneNumber'] as String,
      address: data['address'] as String,
      role: data['role'] as String,
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      password: data['password'] as String,
    );
  }

  // Factory constructor for creating a User from a JSON object
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      profilePictureUrl: json['profilePictureUrl'],
      dateOfBirth: (json['dateOfBirth'] as Timestamp).toDate(),
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      role: json['role'],
      password: json['password'],
      creationDate: DateTime.parse(json['creationDate']),
    );
  }

  // Method for converting a User instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'fullName': fullName,
      'profilePictureUrl': profilePictureUrl,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'password': password,
      'creationDate': creationDate.toIso8601String(),
    };
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
}
