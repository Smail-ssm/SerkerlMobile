import 'package:cloud_firestore/cloud_firestore.dart';

class utilisateur {
  final String userId;
  final String email;
  final String username;
  final String fullName;
  final String profilePictureUrl;
  final DateTime? dateOfBirth;
  final String phoneNumber;
  final String address;
  final Timestamp creationDate;

  utilisateur({
    required this.userId,
    required this.email,
    required this.username,
    required this.fullName,
    required this.profilePictureUrl,
    this.dateOfBirth,
    required this.phoneNumber,
    required this.address,
    required this.creationDate,
  });
// Add a factory constructor to create Utilisateur from Firestore data
  factory utilisateur.fromFirestore(Map<String, dynamic> data) {
    return utilisateur(
      userId: data['userId'] as String,
      email: data['email'] as String,
      username: data['username'] as String,
      fullName: data['fullName'] as String,
      profilePictureUrl: data['profilePictureUrl'] as String,
      dateOfBirth: data['dateOfBirth'] != null
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      phoneNumber: data['phoneNumber'] as String,
      address: data['address'] as String,
      creationDate: data['creationDate'] as Timestamp,
    );
  }
  // Add a factory constructor to create a User object from a Map
  factory utilisateur.fromMap(Map<String, dynamic> userData) => utilisateur(
        userId: userData['userId'] as String,
        email: userData['email'] as String,
        username: userData['username'] as String,
        fullName: userData['fullName'] as String,
        profilePictureUrl: userData['profilePictureUrl'] as String,
        dateOfBirth: userData['dateOfBirth'] != null
            ? DateTime.parse(userData['dateOfBirth'] as String)
            : null,
        phoneNumber: userData['phoneNumber'] as String,
        address: userData['address'] as String,
        creationDate: userData['creationDate'] as Timestamp,
      );
}
