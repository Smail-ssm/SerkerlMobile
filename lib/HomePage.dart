import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/signin_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LatLng _currentLocation =
      const LatLng(0.0, 0.0); // Initialize with a default value
  late Map<String, dynamic> _userData =
      {}; // User data extracted from Firestore

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the widget initializes
    _getCurrentLocation(); // Fetch current location when the widget initializes
    requestPermissions(context);
  }

  Future<void> _fetchUserData() async {
    // Call fetchUserData() to get user data from Firestore
    Map<String, dynamic> userData = await fetchUserData();
    setState(() {
      _userData =
          userData; // Update the _userData variable with the fetched data
    });
  }

  Future<void> _getCurrentLocation() async {
    // Fetch current position using Geolocator
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    print("Current position: " + _currentLocation.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _userData['fullName'] ?? 'Guest',
                // Display user's display name, or 'Guest' if not available
                style: TextStyle(color: Colors.black),
              ),
              accountEmail: Text(
                _userData['email'] ?? 'No email',
                // Display user's email, or 'No email' if not available
                style: TextStyle(color: Colors.black),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  _userData['profilePictureUrl'] ??
                      '', // Display user's photo, if available
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://appmaking.co/wp-content/uploads/2021/08/android-drawer-bg.jpeg',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              otherAccountsPictures: [
                CircleAvatar(child: Icon(Icons.settings)),
                GestureDetector(
                  onTap: onLogout, // Call the logout function when tapped
                  child: CircleAvatar(child: Icon(Icons.logout)),
                ),
              ],
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.account_box),
              title: Text('About'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.grid_3x3_outlined),
              title: Text('Products'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact'),
              onTap: () {},
            )
          ],
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter:
              _currentLocation, // Use your current location as the center
          initialZoom: 13.0, // Set initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }

  Future<void> onLogout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to indicate cancel
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to indicate confirmation
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SignInPage()));
    }
  }
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
