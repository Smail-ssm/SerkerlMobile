import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ebike/pages/FeedbackPage.dart';
import 'package:ebike/pages/Pricing.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/services/VhService.dart';
import 'package:ebike/pages/NotificationsList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/LocationInfo.dart';
import '../model/area.dart';
import '../model/client.dart';
import '../model/vehicule.dart';
import '../services/AreaService.dart';
import '../util/Config.dart';
import '../util/util.dart';
import '../widgets/CodeInputBottomSheet.dart';
import '../widgets/MarkerInfo.dart';
import '../widgets/bottomWidget.dart';
import '../widgets/infoBUtton.dart';
import '../widgets/menuButton.dart';
import '../widgets/share_bottom_sheet.dart';
import 'ClientProfilePage.dart';
import 'History.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final Client? client;

  final Position? position;

  const MapPage({Key? key, this.client, this.position}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool _isExpanded = true; // Track the expanded state of the tile
  final Map<MarkerId, MarkerInfo> _markerInfoMap = {};
  final _filterController = StreamController<List<String>>.broadcast();
  List<String> _selectedVehicleTypes = []; // Define the variable here
  final Set<Marker> _markers = {};
  List<MarkerId> _destinationMarkerIds = [];

  Client? client; // User data
  GoogleMapController? _mapController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
    late LatLng currentLocation; // Store current location
  bool isLoading = true; // Track loading state
  Set<Polygon> polygons = {}; // Set to store polygons
  final AreaService _areaService = AreaService();
  final Vehicleservice _vehicleService = Vehicleservice();
  bool isLoadingLocation = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchAreas(); // Fetch areas when the widget initializes
    _fetchVehiculs(); // Fetch areas when the widget initializes
    client = widget.client;
    requestPermissions(context); // Request location permissions
    _filterController.stream.listen((selectedVehicleTypes) {
      _applyFilters(selectedVehicleTypes);
    });
  }

  @override
  void dispose() {
    _filterController.close();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // double? storedLatitude = prefs.getDouble('latitude');
    // double? storedLongitude = prefs.getDouble('longitude');
    // currentLocation= LatLng(storedLatitude!, storedLongitude!);
    // if( currentLocation ==null){
    setState(() {
      isLoadingLocation = true; // Start showing loading spinner
    });
    try {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          isLoadingLocation = false; // Location fetched successfully
        });
        _moveCameraToCurrentLocation();
      } catch (e) {
        print('Error fetching location: $e');
        setState(() {
           isLoadingLocation = false; // Stop loading even if location fetch failed
        });
      }
    }

  // }

  void _moveCameraToCurrentLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
            currentLocation, 15.0), // Set zoom level to 15.0
      );
    }
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

  Future<void> _fetchVehiculs() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final scooterIcon =
        await createCustomIcon(Icons.electric_scooter, Colors.blue);
    final ebikeIcon = await createCustomIcon(Icons.pedal_bike, Colors.green);

    try {
      List<Vehicle> vehicles = await _vehicleService.fetchVehicles();
      final filteredVehicles = vehicles.where((vehicle) {
        if (_selectedVehicleTypes.isEmpty) return true; // No filter selected
        return _selectedVehicleTypes.any(
            (type) => vehicle.model.toLowerCase().contains(type.toLowerCase()));
      }).toList();

      final newMarkers = <Marker>{};
      final newMarkerInfo = <MarkerId, MarkerInfo>{};

      for (var vehicle in filteredVehicles) {
        if (vehicle.latitude == null || vehicle.longitude == null)
          continue; // Skip invalid data

        final markerIcon =
            getMarkerIconForVehicle(vehicle, scooterIcon, ebikeIcon);
        final markerId = MarkerId(vehicle.id);

        final marker = Marker(
          markerId: markerId,
          icon: markerIcon,
          position: LatLng(vehicle.latitude!, vehicle.longitude!),
          onTap: () => _onMarkerTapped(newMarkerInfo[markerId]!),
          infoWindow: InfoWindow(
            title: vehicle.model,
            snippet: vehicle.isAvailable ? 'Available' : 'Not Available',
          ),
        );

        newMarkers.add(marker);
        newMarkerInfo[markerId] = MarkerInfo(
            id: vehicle.id,
            model: vehicle.model,
            isAvailable: vehicle.isAvailable,
            vehicle: vehicle,
            isDestination: false);
      }

      setState(() {
        _markers.clear(); // Clear existing markers
        _markers.addAll(newMarkers); // Add new filtered markers
        _markerInfoMap.clear(); // Clear existing marker info
        _markerInfoMap.addAll(newMarkerInfo); // Add new filtered marker info
        isLoading = false; // Hide loading indicator
      });
    } catch (e) {
      print('Error fetching vehicles: $e');
      setState(() {
        isLoading = false; // Hide loading indicator on error
      });
    }
  }

  MapType _currentMapType = MapType.normal; // Default map type

  void _showMapTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Map Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Normal'),
                onTap: () {
                  _changeMapType(MapType.normal);
                },
              ),
              ListTile(
                title: const Text('Satellite'),
                onTap: () {
                  _changeMapType(MapType.satellite);
                },
              ),
              ListTile(
                title: const Text('Terrain'),
                onTap: () {
                  _changeMapType(MapType.terrain);
                },
              ),
              ListTile(
                title: const Text('Hybrid'),
                onTap: () {
                  _changeMapType(MapType.hybrid);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _buildLeftDrawer(),
      endDrawer: _buildRightDrawer(),
      body:   Stack(
              children: [
                currentLocation != null
                    ? _buildGoogleMap()
                    : Container(),
                menuButton(scaffoldKey: scaffoldKey),
                InfoButton(scaffoldKey: scaffoldKey),
                _buildCurrentLocationButton(),
                _buildMapGuidButton(),
                _buildScanCodeButton(),
                _buildMapStyleButton(),
                if (isLoadingLocation)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: _currentMapType,
      initialCameraPosition: CameraPosition(
        target: currentLocation ?? LatLng(0, 0), // Fallback to (0,0) if location is not available
        zoom: 15.0,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
      },
      polygons: polygons,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      // No my location button
      zoomControlsEnabled: false,
      // No zoom controls
      onLongPress: _onLongPress,
      mapToolbarEnabled: false,
    );
  }

  void _onLongPress(LatLng position) async {
    final markerId = MarkerId(DateTime.now().millisecondsSinceEpoch.toString());

    // Get location info
    final locationInfo =
        await getAddressFromLatLng(position.latitude, position.longitude);

    final marker = Marker(
      markerId: markerId,
      position: position,
      onTap: () => _onMarkerTap(markerId),
      infoWindow: InfoWindow(
        title: locationInfo!.address, // Display the address in the info window
        snippet: 'Tap to view details',
      ),
    );

    setState(() {
      // Add the new marker
      _markers.add(marker);

      // Add the marker info to the map
      _markerInfoMap[markerId] = MarkerInfo(
        id: 'Marker ${markerId.value}',
        model: locationInfo!.address,
        // Store the address as model info
        isAvailable: false,
        vehicle: null,
        isDestination: true,
      );

      // Remove the previous destination marker if it exists
      if (_destinationMarkerIds.isNotEmpty) {
        final previousMarkerId = _destinationMarkerIds.last;
        _removeMarker(previousMarkerId);
        _destinationMarkerIds.remove(previousMarkerId);
      }

      // Add the new marker ID to the destination markers list
      _destinationMarkerIds.add(markerId);
    });
  }

  void _removeMarker(MarkerId markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId == markerId);
      _markerInfoMap.remove(markerId);
    });
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

  void _onMarkerTap(MarkerId markerId) {
    final markerInfo = _markerInfoMap[markerId];
    if (markerInfo == null) return;
    _onMarkerTapped(markerInfo);
  }

  void _onMarkerTapped(MarkerInfo markerInfo) {
    if (markerInfo.isDestination) {
      // Handle destination marker tap
      _showDestinationDetails(markerInfo);
    } else {
      // Handle vehicle marker tap
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            vhBottomSheet(context: context, markerInfo: markerInfo),
      );
    }
  }

  void _showDestinationDetails(MarkerInfo markerId) {
    // Show destination details in a modal bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Destination Details',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 10),
              Text(
                'Details for ${markerId?.model ?? 'unknown'}',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVehicleDetails(Vehicle vehicle) {
    // Show vehicle details, e.g., in a dialog or bottom sheet
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vehicle Details'),
          content:
              Text('Model: ${vehicle.model}\nBattery ID: ${vehicle.batteryID}'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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

  bool _showMapGuide = false;

  Widget _buildRefreshButton() {
    return Builder(
      builder: (BuildContext context) {
        final buttonColor = Theme.of(context).colorScheme.primary;
        final iconColor = Theme.of(context).colorScheme.onPrimary;

        return FloatingActionButton.extended(
          onPressed: () {
            _fetchVehiculs();
            print("Refresh clicked");
          },
          backgroundColor: buttonColor,
          // Adaptable to light and dark mode
          icon: Icon(
            Icons.refresh, color: iconColor, // Adaptable to button background
          ),
          label: Text(
            'Refresh',
            style: TextStyle(
                color: iconColor), // Text color adaptable to button background
          ),
        );
      },
    );
  }

  Widget _buildFilterButton() {
    return Builder(
      builder: (BuildContext context) {
        final buttonColor = Theme.of(context).colorScheme.primary;
        final iconColor = Theme.of(context).colorScheme.onPrimary;

        return FloatingActionButton.extended(
          onPressed: () async {
            final selectedVehicleTypes =
                await showModalBottomSheet<List<String>>(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Vehicle types',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildVehicleTypeButton(
                              context, Icons.pedal_bike, 'ebike'),
                          _buildVehicleTypeButton(
                              context, Icons.electric_scooter, 'scooter'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );

            if (selectedVehicleTypes != null) {
              _filterController.sink.add(selectedVehicleTypes); // Add to stream
            }
          },
          backgroundColor: buttonColor,
          // Adaptable to light and dark mode
          icon: Icon(
            Icons.filter_list,
            color: iconColor, // Adaptable to button background
          ),
          label: Text(
            'Filter',
            style: TextStyle(
                color: iconColor), // Text color adaptable to button background
          ),
        );
      },
    );
  }

  Widget _buildVehicleTypeButton(
      BuildContext context, IconData icon, String label) {
    return Builder(
      builder: (BuildContext context) {
        final backgroundColor =
            Theme.of(context).colorScheme.secondaryContainer;
        final iconColor = Theme.of(context).colorScheme.onSecondaryContainer;
        final selectedColor = Theme.of(context).colorScheme.secondary;

        return InkWell(
          onTap: () {
            setState(() {
              if (_selectedVehicleTypes.contains(label)) {
                _selectedVehicleTypes.remove(label);
              } else {
                _selectedVehicleTypes.add(label);
              }
            });

            Navigator.pop(context,
                _selectedVehicleTypes); // Close bottom sheet and return selected types
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor, // Adaptable to light and dark mode
                ),
                child: Icon(icon,
                    size: 40.0,
                    color:
                        iconColor), // Icon color adaptable to button background
              ),
              if (_selectedVehicleTypes.contains(label))
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedColor, // Color for the selected indicator
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _applyFilters(List<String> selectedVehicleTypes) {
    setState(() {
      _selectedVehicleTypes = selectedVehicleTypes; // Update filter criteria
      _fetchVehiculs(); // Refetch vehicles with new filters
    });
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      bottom: 60,
      right: 20,
      child: Builder(
        builder: (BuildContext context) {
          final buttonColor = Theme.of(context).colorScheme.primary;
          final iconColor = Theme.of(context).colorScheme.onPrimary;

          return Tooltip(
            message: 'Current Location', // Tooltip message
            child: RawMaterialButton(
              onPressed: _initializeLocation,
              fillColor: buttonColor, // Adaptable to light and dark mode
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              constraints: const BoxConstraints.tightFor(
                width: 40.0, // Square button width
                height: 40.0, // Square button height
              ),
              child: Icon(
                Icons.my_location,
                size: 24.0, // Icon size
                color: iconColor, // Icon color adaptable to button background
              ),
            ),
          );
        },
      ),
    );
  }


  void _showMapGuideBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final backgroundColor = theme.colorScheme.background;
        final surfaceColor = theme.colorScheme.surface;
        final dividerColor = theme.dividerColor;

        return Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                color: surfaceColor, // Adaptable to light and dark mode
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: dividerColor, // Color for the drag handle
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    _buildItem(
                      Icons.stop_circle,
                      'No-go zone',
                      'Don\'t ride or park in red areas. We\'ll stop your vehicle and you risk a fine.',
                      Colors.red,
                    ),
                    _buildItem(
                      Icons.speed_sharp,
                      'Low-speed zone',
                      'We\'ll automatically slow your speed in yellow areas.',
                      Colors.yellow,
                    ),
                    _buildItem(
                      Icons.local_parking,
                      'No-park zone',
                      'To avoid a parking fine, end your ride outside of gray areas.',
                      Colors.grey,
                    ),
                    _buildItem(
                      Icons.electric_scooter,
                      'Scooter parking',
                      'Park scooters in circle spots, or diamond for all vehicles in blue areas.',
                      Colors.blue,
                    ),
                    _buildItem(
                      Icons.pedal_bike,
                      'Bike parking',
                      'Park bikes in square spots, or diamond for all vehicles in blue areas.',
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(
      IconData icon, String title, String description, Color color) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyText1?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyText2?.color ?? Colors.grey;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: textColor), // Adaptable to light and dark mode
      ),
      subtitle: Text(
        description,
        style:
            TextStyle(color: subtitleColor), // Adaptable to light and dark mode
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }

  Widget _buildMapGuidButton() {
    return Positioned(
      bottom: 120,
      right: 20,
      child: Builder(
        builder: (BuildContext context) {
          final buttonColor = Theme.of(context).colorScheme.primary;
          final iconColor = Theme.of(context).colorScheme.onPrimary;

          return Tooltip(
            message: _showMapGuide ? 'Close Map Guide' : 'Open Map Guide', // Tooltip message
            child: RawMaterialButton(
              onPressed: () {
                _showMapGuideBottomSheet(context);
              },
              fillColor: buttonColor, // Background color of the button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              constraints: const BoxConstraints.tightFor(
                width: 40.0, // Square button width
                height: 40.0, // Square button height
              ),
              child: Icon(
                _showMapGuide ? Icons.close : Icons.map,
                size: 24.0, // Icon size
                color: iconColor, // Icon color
              ),
            ),
          );
        },
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PricingWidget()),
              );
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
          buildListTile(
            'Share',
            Icons.share,
            () {
              showShareBottomSheet(
                  context, "HGH3YJJ"); // Use your dynamic promo code here
            },
          ),
          buildListTile(
            'FeedBack',
            Icons.feedback,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScanCodeButton() {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      bottom: 60,
      left: 20,
      child: Tooltip(
        message: 'Scan QR Code', // Tooltip message
        child: RawMaterialButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return CodeInputBottomSheet(); // Your custom bottom sheet widget
              },
            );
          },
          fillColor: buttonColor, // Adapt button color based on theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0, // Button width
            height: 40.0, // Button height
          ),
          child: Icon(
            Icons.qr_code,
            size: 20.0, // Icon size
            color: iconColor, // Adapt icon color based on theme
          ),
        ),
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
        ? [
            const Color(0xFF1A237E),
            const Color(0xFF0D47A1)
          ] // Dark theme gradient colors
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
        children: [
          // Top section with buttons in ExpansionTile
          ExpansionTile(
            title: const Text('Options'),
            leading: const Icon(Icons.settings),
            initiallyExpanded: _isExpanded,
            // Set the initial state to expanded
            onExpansionChanged: (bool expanding) {
              setState(() {
                _isExpanded = expanding; // Update state on expansion change
              });
            },
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(16.0), // Add padding around buttons
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child:
                          _buildRefreshButton(), // Refresh button with extended FAB
                    ),
                    const SizedBox(width: 16.0),
                    // Space between buttons
                    Expanded(
                      child:
                          _buildFilterButton(), // Filter button with extended FAB
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Other tiles and content
          ...buildRightDrawerTiles(context),
        ],
      ),
    );
  }

  List<Widget> buildRightDrawerTiles(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyText1?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyText2?.color ?? Colors.grey;

    return [
      Center(
        child: Text(
          'Tutorial',
          style: TextStyle(
            fontSize: 20.0,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ExpansionTile(
        title: Text('Find a Scooter', style: TextStyle(color: textColor)),
        leading: Icon(Icons.directions_walk, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Instructions', style: TextStyle(color: textColor)),
            subtitle: Text('Steps on finding a scooter near you.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Start Ride', style: TextStyle(color: textColor)),
        leading: Icon(Icons.qr_code_scanner, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Unlock Scooter', style: TextStyle(color: textColor)),
            subtitle: Text('Scan the QR code to start your ride.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('End Ride', style: TextStyle(color: textColor)),
        leading: Icon(Icons.location_off, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Parking', style: TextStyle(color: textColor)),
            subtitle: Text('Locate a designated parking spot.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Take Photo', style: TextStyle(color: textColor)),
            subtitle: Text('Take a photo of the parked scooter.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('End Ride Confirmation',
                style: TextStyle(color: textColor)),
            subtitle: Text('Confirm ride completion in the app.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Zones on the Map', style: TextStyle(color: textColor)),
        leading: Icon(Icons.map, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Green Zone', style: TextStyle(color: textColor)),
            subtitle:
                Text('Riding allowed.', style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Red Zone', style: TextStyle(color: textColor)),
            subtitle: Text('No riding allowed.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Yellow Zone', style: TextStyle(color: textColor)),
            subtitle: Text('Reduced speed zone.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Grey Zone', style: TextStyle(color: textColor)),
            subtitle: Text('Scooter unavailable in this area.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('FAQs', style: TextStyle(color: textColor)),
        leading: Icon(Icons.question_answer, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Common Questions', style: TextStyle(color: textColor)),
            subtitle: Text('Find answers to frequently asked questions.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // Add more ListTile widgets for other FAQs
        ],
      ),
      Divider(
        thickness: 1,
        indent: 16.0,
        endIndent: 16.0,
        color: theme.dividerColor,
      ),
      Center(
        child: Text(
          'Troubleshooting',
          style: TextStyle(
            fontSize: 20.0,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ExpansionTile(
        title: Text('Troubleshooting', style: TextStyle(color: textColor)),
        leading: Icon(Icons.build, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Payment Issues', style: TextStyle(color: textColor)),
            subtitle: Text('Steps to resolve payment problems.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title:
                Text('Scooter Unavailable', style: TextStyle(color: textColor)),
            subtitle: Text('What to do if a scooter is unavailable.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // Add more ListTile widgets for other troubleshooting topics
        ],
      ),
      ExpansionTile(
        title: Text('Contact Us', style: TextStyle(color: textColor)),
        leading: Icon(Icons.contact_emergency, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Email', style: TextStyle(color: textColor)),
            subtitle: Text('support@Ebike.com',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Phone Number', style: TextStyle(color: textColor)),
            subtitle: Text('phone', style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // Add more ListTile widgets for other contact methods (if applicable)
        ],
      ),
      ExpansionTile(
        title: Text('Help Center', style: TextStyle(color: textColor)),
        leading: Icon(Icons.help, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Visit our Help Center',
                style: TextStyle(color: textColor)),
            subtitle: Text('Detailed guides and tutorials.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Community Forum', style: TextStyle(color: textColor)),
        leading: Icon(Icons.forum, color: theme.iconTheme.color),
        children: [
          ListTile(
            title:
                Text('Join the Community', style: TextStyle(color: textColor)),
            subtitle: Text('Connect with other users and get help.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      // Add more ExpansionTiles for other support functionalities (if applicable)
    ];
  }

  void _changeMapType(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
    Navigator.of(context).pop(); // Close the dialog
  }

  Widget _buildMapStyleButton() {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      bottom: 120,
      left: 20,
      child: Tooltip(
        message: 'Change Map Style', // Tooltip message
        child: RawMaterialButton(
          onPressed: () {
            _showMapTypeDialog();
          },
          fillColor: buttonColor, // Adapt button color based on theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0, // Button width
            height: 40.0, // Button height
          ),
          child: Icon(
            Icons.style_outlined,
            size: 20.0, // Icon size
            color: iconColor, // Adapt icon color based on theme
          ),
        ),
      ),
    );
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
