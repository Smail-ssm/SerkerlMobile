import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/util/AppRouter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LatLng _currentLocation =
      const LatLng(0.0, 0.0); // Initialize with a default value

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch current location when the widget initializes
  }

  Future<void> _getCurrentLocation() async {
    // Fetch current position using Geolocator
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    requestPermissions(context);
    fetchUserData();
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                'AppMaking.co',
                style:
                    TextStyle(color: Colors.black), // Set text color to black
              ),
              accountEmail: Text(
                'sundar@appmaking.co',
                style:
                    TextStyle(color: Colors.black), // Set text color to black
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://appmaking.co/wp-content/uploads/2021/08/appmaking-logo-colored.png'),
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
    );
  }

  Future<void> onLogout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    AppRouter.navigateTo(context, '/signin');
  }
}

Future<void> requestPermissions(BuildContext context) async {
  // List of permissions to request
  List<Permission> permissions = [
    Permission.location,
    Permission.notification,
    Permission.storage,
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
            title: Text('${permission.toString().split('.').last} Permission'),
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

Future<Map<String, dynamic>> fetchUserData() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Get the current user
  User? user = auth.currentUser;

  // Initialize an empty map to store user data
  Map<String, dynamic> userData = {};

  if (user != null) {
    try {
      // Retrieve user document from Firestore using the user UID
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();

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
    // Handle case when user is not authenticated
    print('User not authenticated');
  }

  return userData;
}
