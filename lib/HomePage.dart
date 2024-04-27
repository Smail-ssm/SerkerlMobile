import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/model/userC.dart';
import 'package:ebike/user/UserProfilePage.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/signin_page.dart';
import 'model/DeviceInfo.dart';
import 'model/vehicule.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> markers = []; // List to store markers
  int _markerCount = 0; // Track marker count for key
  double tolerance = 0.099;

  List<Vehicle> vehicleList = [
    Vehicle(
      id: 'ebike-002',
      model: 'E-Bike X2',
      batteryLevel: 0.50,
      isAvailable: false, // Currently rented
      deviceInfo: DeviceInfo(
        id: 'device-002',
        uid: '987654321098765',
        mileage: 120.0, // In kilometers
        lastSignal: DateTime.now()
            .subtract(Duration(hours: 2)), // Simulate older signal
      ),
    ),
    Vehicle(
      id: 'ebike-003',
      model: 'E-Bike X3',
      batteryLevel: 0.90,
      isAvailable: true,
      deviceInfo: DeviceInfo(
        id: 'device-003',
        uid: '543210987654321',
        mileage: 25.0, // In kilometers
        lastSignal: DateTime.now(), // Simulate most recent signal
      ),
      speed: 15.0, // Current speed (e.g., km/h) (optional)
      temperature: 30.0, // Internal temperature (optional)
    ),
  ];
  bool isMarkerWithinTolerance(
      LatLng markerPoint, LatLng tapPosition, double tolerance) {
    return (markerPoint.latitude - tapPosition.latitude).abs() <= tolerance &&
        (markerPoint.longitude - tapPosition.longitude).abs() <= tolerance;
  }

  late LatLng _currentLocation =
      const LatLng(0.0, 0.0); // Initialize with a default value
  utilisateur? _userc; // User data extracted from Firestore
  void onMapEvent(MapEvent evt) {
    if (evt is MapEventTap) {
      final tapPosition = evt.tapPosition;
      bool markerTapped = false;

      // Check for markers within tolerance
      for (var marker in markers.toList()) {
        if (isMarkerWithinTolerance(marker.point, tapPosition, tolerance)) {
          markerTapped = true;
          showModalBottomSheet(
            context: context,
            builder: (context) =>
                buildMarkerInfoBottomSheet(marker), // Build info sheet
          );
          return; // Exit the function after showing info sheet
        }
      }

      // Handle case where no marker is tapped
      if (!markerTapped) {
        print("No marker found within tap tolerance");
      }
    } else if (evt is MapEventLongPress) {
      final newMarker = Marker(
        point: evt.tapPosition,
        child: const Icon(Icons.push_pin), // Customize marker icon
      );
      setState(() {
        _markerCount++;
        markers.add(newMarker);
      });
      print(
          "Marker added at ${evt.tapPosition.latitude}, ${evt.tapPosition.longitude}");
    }
  }

  // Initial location
  LatLng initialLocation = LatLng(0, 0);
  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the widget initializes
    _getCurrentLocation(); // Fetch current location when the widget initializes
    requestPermissions(context);
  }

  Future<void> _fetchUserData() async {
    // Call fetchUserData() to get user data from Firestore
    utilisateur userData = (await fetchUserData()) as utilisateur;
    setState(() {
      _userc = userData
          as utilisateur; // Update the _userData variable with the fetched data
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
            buildUserAccountsDrawerHeader(context),
            buildListTile('Home', Icons.home, () {
              showSnackBar(context, 'Home');
            }),
            buildListTile('About', Icons.account_box, () {
              showSnackBar(context, 'About');
            }),
            buildListTile('Products', Icons.grid_3x3_outlined, () {
              showSnackBar(context, 'Products');
            }),
            buildListTile('Contact', Icons.contact_mail, () {
              showSnackBar(context, 'Contact');
            }),
            buildListTile('add list ', Icons.add_alarm, () async {}),
          ],
        ),
      ),
      body: buildFlutterMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Move map to current location when FloatingActionButton is pressed
        },
        child: Icon(Icons.my_location),
      ), // Use extracted widget
    );
  }

  Widget buildFlutterMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter:
            LatLng(_currentLocation.latitude, _currentLocation.longitude),
        initialZoom: 11,
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.all),
        onMapEvent: onMapEvent,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleafleet.flutter_map.example',
        ),
        CurrentLocationLayer(
          alignPositionOnUpdate: AlignOnUpdate.once,
          alignDirectionOnUpdate: AlignOnUpdate.never,
          style: const LocationMarkerStyle(
            marker: DefaultLocationMarker(),
            markerSize: Size(20, 20),
            markerDirection: MarkerDirection.heading,
          ),
        ),
        MarkerLayer(
          key: ValueKey(_markerCount),
          markers: markers,
        )
      ],
    );
  }

  Widget buildListTile(String title, IconData icon, void Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget buildUserAccountsDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        _userc?.fullName ?? 'Guest',
        style: const TextStyle(color: Colors.black),
      ),
      accountEmail: Text(
        _userc?.email ?? 'No email',
        style: const TextStyle(color: Colors.black),
      ),
      currentAccountPicture: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(
              user: _userc,
            ),
          ),
        ),
        child: CircleAvatar(
          backgroundImage: NetworkImage(
            _userc?.profilePictureUrl ?? '',
          ),
        ),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue,
            Colors.green,
          ],
        ),
      ),
      otherAccountsPictures: [
        const CircleAvatar(child: Icon(Icons.settings)),
        GestureDetector(
          onTap: onLogout, // Call the logout function when tapped
          child: const CircleAvatar(child: Icon(Icons.logout)),
        ),
      ],
    );
  }

  Future<void> onLogout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false to indicate cancel
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Return true to indicate confirmation
              },
              child: const Text("Logout"),
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

  showSnackBar(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<Type> fetchUserData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

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
        utilisateur retrievedUserData =
            utilisateur.fromFirestore(userDoc.data() as Map<String, dynamic>);

        // Update the state with the retrieved user
        setState(() {
          _userc = retrievedUserData;
        });
      } catch (e) {
        // Handle any errors that occur during the process
        print('Error fetching user data: ' + e.toString());
      }
    } else {
      // Handle case when user ID is not available in SharedPreferences
      print('User ID not found in SharedPreferences');
    }

    return utilisateur;
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

  Widget buildMarkerInfoBottomSheet(Marker marker) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        borderRadius:
            BorderRadius.circular(20.0), // Add rounded corners with 20.0 radius
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Latitude: ' + marker.point.latitude.toString(),
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
            Text('Longitude: ' + marker.point.longitude.toString(),
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            // Add spacing
            ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Remove Marker'),
              onPressed: () {
                // Remove the marker here using the passed marker object
                setState(() {
                  markers
                      .remove(marker); // Replace i with the appropriate index
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
