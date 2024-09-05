import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/client.dart';
import '../model/vehicule.dart';

BitmapDescriptor getMarkerIconForVehicle(
  Vehicle vehicle,
  BitmapDescriptor scooterIcon,
  BitmapDescriptor ebikeIcon,
) {
  if (vehicle.model.toLowerCase().contains('scooter')) {
    return scooterIcon;
  } else if (vehicle.model.toLowerCase().contains('ebike')) {
    return ebikeIcon;
  } else {
    return BitmapDescriptor.defaultMarker; // Fallback if no model matches
  }
}

void showMessageDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Message'),
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

String getFirestoreDocument() {
  return kDebugMode ? 'preprod' : 'prod';
}

Future<void> saveSP(String variable, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(variable, value);
}

getSP(String variable) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(variable);
}

// Method to check if an email address is valid
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

enum EncryptionMode { encrypt, decrypt }

Future<String> encryptDecryptText(
  String text,
  EncryptionMode mode,
) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.fetchAndActivate(); // Fetch and activate latest values

  final key = remoteConfig.getString('encryption_key');

  if (key.isEmpty) {
    return Future.error('Encryption key not found in Remote Config');
  }

  try {
    final keyObject = encrypt.Key.fromUtf8('RAGGADAsmailssm50+');
    final randomBytes = keyObject.bytes.sublist(0, 16); // 128-bit random value

    final crypter = encrypt.Encrypter(
        encrypt.AES(encrypt.Key(randomBytes), mode: encrypt.AESMode.cbc));

    return mode == EncryptionMode.encrypt
        ? base64.encode(
            crypter.encrypt(text, iv: encrypt.IV.fromSecureRandom(16)).bytes)
        : crypter.decrypt64(text, iv: encrypt.IV.fromLength(16));
  } catch (e) {
    return Future.error(
        'Error during ${mode == EncryptionMode.encrypt ? 'encryption' : 'decryption'}: $e');
  }
}

Future<Client?> fetchClientDataByEmail(String email) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final usersCollection = firestore.collection(getFirestoreDocument());

  try {
    // Retrieve user document from Firestore using the user email
    QuerySnapshot querySnapshot = await usersCollection
        .doc('users')
        .collection('email')
        .where('email', isEqualTo: email)
        .get();

    // Check if any document matches the query
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      Client retrievedUserData =
          Client.fromFirestore(userDoc.data() as Map<String, dynamic>);
      return retrievedUserData;
    } else {
      print('User document does not exist for email');
      return null;
    }
  } catch (e) {
    // Handle any errors that occur during the process
    print('Error fetching user data by email: ' + e.toString());
    return null;
  }
}

Future<Client?> fetchClientData(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final usersCollection = firestore.collection(getFirestoreDocument());

  if (userId != null) {
    try {
      // Retrieve user document from Firestore using the user ID
      DocumentSnapshot userDoc = await usersCollection
          .doc('users')
          .collection(userId)
          .doc('user')
          .get();

      // Check if the user document exists
      if (userDoc.exists) {
        // Convert the Firestore document data to a Client object
        Client retrievedUserData =
            Client.fromFirestore(userDoc.data() as Map<String, dynamic>);
        return retrievedUserData;
      } else {
        print('User document does not exist');
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error fetching user data by user ID: ' + e.toString());
      return null;
    }
  } else {
    // Handle case when user ID is not available in SharedPreferences
    print('User ID not found in SharedPreferences');
    return null;
  }
}

Future<BitmapDescriptor> createCustomIcon(
    IconData iconData, Color color) async {
  final size = 150.0;
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(
      pictureRecorder,
      Rect.fromPoints(
        Offset(0.0, 0.0),
        Offset(size, size),
      ));

  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  final iconPainter = IconPainter(iconData, color, size);
  iconPainter.paint(canvas, Size(size, size));

  final picture = pictureRecorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(buffer);
}

class IconPainter extends CustomPainter {
  final IconData iconData;
  final Color color;
  final double size;

  IconPainter(this.iconData, this.color, this.size);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: this.size / 2,
          fontFamily: iconData.fontFamily,
          color: color,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
