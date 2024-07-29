import 'dart:async';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/widgets/NotificationsList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/area.dart';
import '../model/client.dart';
import '../services/AreaService.dart';
import 'ClientProfilePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'History.dart';

class MapPage extends StatefulWidget {
  final Client? client;

  const MapPage({Key? key, this.client })
      : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> markers = {}; // Set to store markers
   Client? client; // User data
  GoogleMapController? _mapController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late LatLng currentLocation; // Store current location
  Set<Polygon> polygons = {}; // Set to store polygons
  final AreaService _areaService = AreaService();
  @override
  void initState() {
    super.initState();
    _fetchAreas(); // Fetch areas when the widget initializes
    client = widget.client;

      _getCurrentLocation(); // Fetch current location if not provided

    requestPermissions(context); // Request location permissions
  }
  Future<void> _fetchAreas() async {
    try {
      List<Area> areas = await _areaService.fetchAreas();
      setState(() {
        polygons = areas.map((area) => area.polygon).toSet();
        print('  fetching areas: $areas');

      });
    } catch (e) {
      print('Error fetching areas: $e');
    }
  }

  Future<void> _getCurrentLocation() async {

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _buildLeftDrawer(),
      endDrawer: _buildRightDrawer(),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          _buildGoogleMap(),
          _buildMenuButton(),
          _buildInfoButton(),
          _buildCurrentLocationButton(),
          _buildScanCodeButton(),
        ],
      ),
    );
  }  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: currentLocation,
        zoom: 15.0,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      polygons: polygons,
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onLongPress: _onMapLongPress,
    );
  }

  void _onMapLongPress(LatLng position) {
    setState(() {
      markers.add(_createMarker(position));
    });
  }

  Marker _createMarker(LatLng position) {
    return Marker(
      markerId: MarkerId('marker_${markers.length}'),
      position: position,
      infoWindow: const InfoWindow(),
      onTap: () {
        _onMarkerTapped('marker_${markers.length}');
      },
    );
  }

  void _onMarkerTapped(String markerId) {
    final marker = markers.firstWhere((m) => m.markerId.value == markerId);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _buildMarkerInfoBottomSheet(marker);
      },
    );
  }

  Widget _buildMarkerInfoBottomSheet(Marker marker) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Latitude: ${marker.position.latitude}',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
            Text('Longitude: ${marker.position.longitude}',
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10.0),
            ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Remove Marker'),
              onPressed: () {
                setState(() {
                  markers.remove(marker);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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

  Widget _buildMenuButton() {
    return Positioned(
      top: 50,
      left: 20,
      child: FloatingActionButton(
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
        child: const Icon(Icons.menu),
      ),
    );
  }

  Widget _buildInfoButton() {
    return Positioned(
      top: 50,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
        child: const Icon(Icons.info),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      bottom: 80,
      right: 20,
      child: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Drawer _buildLeftDrawer() {
    return Drawer(
      child: ListView(
        children: [
          buildUserAccountsDrawerHeader(context),

          // buildUserAccountsDrawerHeader(context),
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
                MaterialPageRoute(
                    builder: (context) => HistoryPage(client: widget.client)),
              );
            },
          ),
          buildListTile(
            'Notifications',
            Icons.notifications,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        NotificationsPage(client: widget.client)),
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
                MaterialPageRoute(
                    builder: (context) =>
                        ClientProfilePage(client: widget.client)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanCodeButton() {
    return Positioned(
      bottom: 80,
      left: 20,
      child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CodeInputDialog();
            },
          );
        },
        child: const Icon(Icons.qr_code),
      ),
    );
  }

  Widget buildUserAccountsDrawerHeader(BuildContext context) {
    // Determine if the current theme is dark or light
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Set text color based on the theme
    Color textColor = isDarkTheme ? Colors.white : Colors.black;

    // Set the gradient colors based on the theme
    List<Color> gradientColors = isDarkTheme
        ? [Color(0xFF1A237E), Color(0xFF0D47A1)] // Dark theme gradient colors
        : [Colors.blue, Colors.green]; // Light theme gradient colors

    // Set the icon colors based on the theme
    Color iconColor = isDarkTheme ? Colors.white : Colors.black;

    return UserAccountsDrawerHeader(
      accountName: Text(
        client?.fullName ?? 'Guest',
        style: TextStyle(color: textColor),
      ),
      accountEmail: Text(
        client?.email ?? 'No email',
        style: TextStyle(color: textColor),
      ),
      currentAccountPicture: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientProfilePage(
              client: client,
            ),
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          child: client?.profilePictureUrl != null &&
                  client!.profilePictureUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    client!.profilePictureUrl,
                    fit: BoxFit.cover,
                    width: 90.0,
                    height: 90.0,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      size: 50.0,
                      color: iconColor,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 50.0,
                  color: iconColor,
                ),
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      otherAccountsPictures: [
        CircleAvatar(child: Icon(Icons.settings, color: iconColor)),
        GestureDetector(
          onTap: onLogout, // Call the logout function when tapped
          child: CircleAvatar(child: Icon(Icons.logout, color: iconColor)),
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
          MaterialPageRoute(builder: (context) => const SignInPage()));
    }
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Drawer _buildRightDrawer() {
    return Drawer(
      child: ListView(
        children: buildRightDrawerTiles(),
      ),
    );
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
