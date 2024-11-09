import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/LocationInfo.dart';
import '../model/client.dart';
import '../model/vehicule.dart';
import 'Config.dart';

BitmapDescriptor getMarkerIcon(
  Vehicle? vehicle, // Vehicle can be null
  BitmapDescriptor scooterIcon,
  BitmapDescriptor ebikeIcon,
  BitmapDescriptor parkingIcon, // Pass the custom parking icon
) {
  if (vehicle == null) {
    return parkingIcon; // Return parking icon if no vehicle is passed
  }

  // Check vehicle type and return the corresponding icon
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

  try {
    // Retrieve user document from Firestore using the user ID
    DocumentSnapshot userDoc = await usersCollection
        .doc('users')
        .collection('users')
        .doc(userId)
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
}

Future<BitmapDescriptor> createCustomIcon(
    IconData iconData, Color color) async {
  const size = 150.0;
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(
      pictureRecorder,
      Rect.fromPoints(
        const Offset(0.0, 0.0),
        const Offset(size, size),
      ));

  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  final iconPainter = IconPainter(iconData, color, size);
  iconPainter.paint(canvas, const Size(size, size));

  final picture = pictureRecorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(buffer);
}

void requestPermissions(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are denied')),
      );
    } else if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied')),
      );
    }
  }
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

Future<LocationInfo?> getAddressFromLatLng(double lat, double lng) async {
  String _host = 'https://maps.googleapis.com/maps/api/geocode/json';
  final url =
      '$_host?key=${Config.googleMapsApiKey}&language=en&latlng=$lat,$lng';

  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    Map data = jsonDecode(response.body);
    String _formattedAddress = data["results"][0]["formatted_address"];
    print("response ==== $_formattedAddress");
    return LocationInfo(address: _formattedAddress);
  } else {
    print('Failed to load address');
    return null;
  }
}

// Polyline decoder method
List<LatLng> decodePolyline(String polyline) {
  List<LatLng> points = [];
  int index = 0, len = polyline.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    points.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return points;
}

Widget buildListTile(
  String title,
  IconData icon,
  VoidCallback onTap, {
  String? value,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: value != null ? Text(value) : null,
    onTap: onTap,
  );
}

// Function to calculate distance between two LatLng points (Haversine Formula)
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371000; // Radius of the Earth in meters
  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c; // Distance in meters
}

double _degToRad(double deg) {
  return deg * (pi / 180);
}

// Format distance in kilometers
String formatDistance(double distanceInMeters) {
  double distanceInKm = distanceInMeters / 1000;
  return '${distanceInKm.toStringAsFixed(2)} km';
}

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}

// Format time to minutes and seconds
String formatTime(double timeInSeconds) {
  int minutes = (timeInSeconds / 60).floor();
  int seconds = (timeInSeconds % 60).floor();
  return '${minutes}m ${seconds}s';
}

String defaultImageUrl() {
  return 'https://placehold.co/300x200?text=No+Image'; // Default image placeholder
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}
