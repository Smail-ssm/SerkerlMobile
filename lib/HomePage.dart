import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/model/userC.dart';
import 'package:ebike/user/UserProfilePage.dart';
import 'package:ebike/util/SlideRightRoute.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/signin_page.dart';
import 'history/History.dart';
import 'notifications/NotificationsList.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> markers = []; // List to store markers

  int _markerCount = 0; // Track marker count for key
  double tolerance = 0.099;
  MapController mapController = MapController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

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
  LatLng initialLocation = const LatLng(0, 0);

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
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          children: [
            buildUserAccountsDrawerHeader(context),
            buildListTile(
              'Balance',
              Icons.account_balance,
              () {
                showSnackBar(context, 'Balance');
              },
              value: "0",
            ),
            buildListTile(
              'Subscriptions',
              Icons.subscriptions,
              () {
                showSnackBar(context, 'Subscriptions');
              },
            ),
            buildListTile(
              'Ride history',
              Icons.history,
              () {
                Navigator.push(
                  context,
                  SlideRightRoute(page: HistoryPage(user: _userc)),
                );
              },
            ),
            buildListTile(
              'Notifications',
              Icons.notifications,
              () {
                Navigator.push(
                  context,
                  SlideRightRoute(page: NotificationsPage(user: _userc)),
                );
              },
            ),
            buildListTile(
              'Support',
              Icons.support,
              () {
                showSnackBar(context, 'Support');
              },
            ),
            buildListTile(
              'Language',
              Icons.language,
              () {
                showSnackBar(context, 'Language');
              },
            ),
            buildListTile(
              'Profile',
              Icons.person,
              () {
                Navigator.push(
                  context,
                  SlideRightRoute(page: UserProfilePage(user: _userc)),
                );
              },
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          children: buildRightDrawerTiles(),
        ),
      ),
      body: Stack(
        children: [
          buildFlutterMap(),
          Positioned(
            top: 40.0, // Adjust top padding as needed
            left: 20.0, // Adjust left padding as needed
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust corner radius as desired
              ),
              elevation: 2.0, // Adjust elevation as desired
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Adjust padding as desired
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40.0, // Adjust top padding as needed
            right: 20.0, // Adjust right padding as needed
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust corner radius as desired
              ),
              elevation: 2.0, // Adjust elevation as desired
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Adjust padding as desired
                child: IconButton(
                  icon:
                      const Icon(Icons.info), // You can customize the icon here
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40.0, // Adjust top padding as needed
            right: 20.0, // Adjust right padding as needed
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Adjust corner radius as desired
              ),
              elevation: 2.0, // Adjust elevation as desired
              child: Padding(
                padding: const EdgeInsets.all(0.0), // Adjust padding as desired
                child: IconButton(
                  icon: const Icon(Icons.location_on),
                  // You can customize the icon here
                  onPressed: () {
                    _zoom();
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40.0,
            // Adjust bottom padding as needed
            left: 0,
            // Set left to 0 to align to the left side of the screen
            right: 0,
            // Set right to 0 to align to the right side of the screen, effectively centering
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20.0), // Set a large radius for a rounded button
                ),
                elevation: 2.0, // Adjust elevation as desired
                color:
                    Colors.red, // Set the button color to red as in the image
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 0),

                  // Adjust padding as desired for larger button
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CodeInputDialog();
                        },
                      );
                    },
                    child: const Text(
                      'Scan or Enter Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _zoom() {
    _getCurrentLocation();

    mapController.move(_currentLocation, 17);
  }

  List<Widget> buildRightDrawerTiles() {
    return [
      const Center(
        child: Text(
          'Tutorial',
          style: TextStyle(
            fontSize: 20.0,
            // Set a larger font size (adjust as needed)
            color: Colors.black,
            fontWeight: FontWeight.bold, // Optional: make the text bold
          ),
        ),
      ),
      const ExpansionTile(
        title: Text('Find a Scooter'), // Replace with actual title from image
        leading: Icon(Icons.directions_walk), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Instructions'),
            // Replace with actual instructions
            subtitle: Text('Steps on finding a scooter near you.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
        ],
      ),
      const ExpansionTile(
        title: Text('Start Ride'), // Replace with actual title from image
        leading: Icon(Icons.qr_code_scanner), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Unlock Scooter'),
            // Replace with actual instructions
            subtitle: Text('Scan the QR code to start your ride.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
        ],
      ),
      const ExpansionTile(
        title: Text('End Ride'), // Replace with actual title from image
        leading: Icon(Icons.location_off), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Parking'),
            // Replace with actual instructions
            subtitle: Text('Locate a designated parking spot.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('Take Photo'),
            // Replace with actual instructions
            subtitle: Text('Take a photo of the parked scooter.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('End Ride Confirmation'),
            // Replace with actual instructions
            subtitle: Text('Confirm ride completion in the app.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
        ],
      ),
      const ExpansionTile(
        title: Text('Zones on the Map'), // Replace with actual title from image
        leading: Icon(Icons.map), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Green Zone'),
            // Replace with actual zone description
            subtitle: Text('Riding allowed.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('Red Zone'),
            // Replace with actual zone description
            subtitle: Text('No riding allowed.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('Yellow Zone'),
            // Replace with actual zone description
            subtitle: Text('Reduced speed zone.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('Grey Zone'),
            // Replace with actual zone description
            subtitle: Text('Scooter unavailable in this area.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
        ],
      ),
      const ExpansionTile(
        title: Text('FAQs'), // Replace with actual title
        leading: Icon(Icons.question_answer), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Common Questions'),
            // Replace with actual question
            subtitle: Text('Find answers to frequently asked questions.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          // ... Add more ListTile widgets for other FAQs
        ],
      ),
      const Divider(
        // Add a separator with text
        thickness: 1, indent: 16.0, endIndent: 16.0, color: Colors.grey,
      ),
      const Center(
        child: Text(
          'Troubleshooting',
          style: TextStyle(
            fontSize: 20.0,
            // Set a larger font size (adjust as needed)
            color: Colors.black,
            fontWeight: FontWeight.bold, // Optional: make the text bold
          ),
        ),
      ),
      const ExpansionTile(
        title: Text('Troubleshooting'), // Replace with actual title
        leading: Icon(Icons.build), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Payment Issues'),
            // Replace with specific issue
            subtitle: Text('Steps to resolve payment problems.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('Scooter Unavailable'),
            // Replace with specific issue
            subtitle: Text('What to do if a scooter is unavailable.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          // ... Add more ListTile widgets for other troubleshooting topics
        ],
      ),
      const ExpansionTile(
        title: Text('Contact Us'), // Replace with actual title
        leading: Icon(Icons.contact_emergency), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Email'),
            // Replace with actual contact method
            subtitle: Text('support@Ebike.com'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          ListTile(
            title: Text('Phone Number'),
            // Replace with actual contact method
            subtitle: Text(' phone'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
          // Add more ListTile widgets for other contact methods (if applicable)
        ],
      ),
      const ExpansionTile(
        title: Text('Help Center'), // Replace with actual title
        leading: Icon(Icons.help), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Visit our Help Center'),
            // Replace with actual text
            subtitle: Text('Detailed guides and tutorials.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
            // Replace with actual URL
          ),
        ],
      ),
      const ExpansionTile(
        title: Text('Community Forum'), // Replace with actual title
        leading: Icon(Icons.forum), // Replace with appropriate icon
        children: [
          ListTile(
            title: Text('Join the Community'),
            // Replace with actual text
            subtitle: Text('Connect with other users and get help.'),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0), // Add padding
          ),
        ],
      ),
      // Add more ExpansionTiles for other support functionalities (if applicable)
    ];
  }

  Widget buildFlutterMap() {
    return FlutterMap(
      mapController: mapController,
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

  Widget buildListTile(String title, IconData icon, void Function() onTap,
      {String? value}) {
    return ListTile(
      leading: Icon(icon),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          if (value?.isNotEmpty ?? false)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                value!, // Use ! for non-null assertion
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10.0,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget buildUserAccountsDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Text(
        _userc!.fullName ?? 'Guest',
        style: const TextStyle(color: Colors.black),
      ),
      accountEmail: Text(
        _userc!.email ?? 'No email',
        style: const TextStyle(color: Colors.black),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: NetworkImage(
          _userc!.profilePictureUrl ?? '',
        ),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        color: Colors.white,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue,
            Colors.white,
          ],
        ),
      ),
      otherAccountsPictures: [
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

class CodeInputDialog extends StatefulWidget {
  @override
  _CodeInputDialogState createState() => _CodeInputDialogState();
}

class _CodeInputDialogState extends State<CodeInputDialog> {
  TextEditingController _textEditingController = TextEditingController();
  late QRViewController _qrViewController;
  GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  String _scannedCode = '';

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan or Enter Code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200,
            width: 200,
            child: QRView(
              key: _qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              labelText: 'Enter Code Manually',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Set the variable with the scanned or manually entered code
            String code = _scannedCode.isNotEmpty
                ? _scannedCode
                : _textEditingController.text;
            // Use the code variable as needed
            // For example, you can pass it to a function or save it in a variable
            print('Code: $code');
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _qrViewController = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        _textEditingController.text = scanData.code!;
      });
    });
  }
}
