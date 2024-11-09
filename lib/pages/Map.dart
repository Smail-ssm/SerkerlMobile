import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/services/Vehicleservice.dart';
import 'package:ebike/widgets/JuicerOperationsBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/area.dart';
import '../model/client.dart';
import '../model/parking.dart';
import '../model/vehicule.dart';
import '../services/AreaService.dart';
import '../services/AuthService.dart';
import '../services/map_service.dart';
import '../services/parkingService.dart';
import '../util/VehicleUtils.dart';
import '../util/util.dart';
import '../widgets/CodeInputBottomSheet.dart';
import '../widgets/CustomGoogleMap.dart';
import '../widgets/JuicerLeftDrawer.dart';
import '../widgets/LeftDrawer.dart';
import '../widgets/MapGuideBottomSheet.dart';
import '../widgets/MarkerInfo.dart';
import '../widgets/ParkingImages.dart';
import '../widgets/PositionedButton.dart';
import '../widgets/RightDrawer.dart';
import '../widgets/ScanCodeButton.dart';
import '../widgets/TechLeftDrawer.dart';
import '../widgets/bottomWidget.dart';
import '../widgets/infoBUtton.dart';
import '../widgets/menuButton.dart';

class MapPage extends StatefulWidget {
  final Client? client;

  final Position? position;

  const MapPage({Key? key, this.client, this.position}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final Map<MarkerId, MarkerInfo> _markerInfoMap = {};
  final _filterController = StreamController<List<String>>.broadcast();
  List<String> _selectedVehicleTypes = []; // Define the variable here
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<MarkerId> _destinationMarkerIds = [];
  final MapService _mapService =
      MapService(ParkingService(), Vehicleservice()); // Initialize the service
  final AuthService _authService = AuthService();
  String? _selectedMapStyle; // Selected map style
  List<Vehicle> _vehicleList = []; // Add this at the class level
  Timer? _locationUpdateTimer;

  Client? client; // User data
  GoogleMapController? _mapController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentLocation; // Store current location
  bool isLoading = true; // Track loading state
  Set<Polygon> polygons = {}; // Set to store polygons
  final AreaService _areaService = AreaService();
  final Vehicleservice _vehicleService = Vehicleservice();
  final ParkingService _parkingService = ParkingService();
  bool isLoadingLocation = true;
  bool isJuicer = false;
  final bool _showMapGuide = false;

  late LatLng _destination; // Track loading state
  final MapType _currentMapType = MapType.normal; // Default map type

  @override
  void initState() {
    super.initState();

    _initializeLocation();
    _loadMapStyle();
    WidgetsBinding.instance.addObserver(this);
    showroledialog();
    _fetchAreas(); // Fetch areas when the widget initializes
    _fetchVehiculs(); // Fetch areas when the widget initializes
    _mapService.updateUserLocation(widget.client);
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _mapService.updateUserLocation(widget.client);
    });

    client = widget.client;
    requestPermissions(context); // Request location permissions
    _filterController.stream.listen((selectedVehicleTypes) {
      VehicleUtils.applyFilters(
        selectedVehicleTypes: selectedVehicleTypes,
        updateVehicleTypes: (types) {
          setState(() {
            _selectedVehicleTypes = types; // Update filter criteria in state
          });
        },
        fetchVehicles: _fetchVehiculs,
      );
    });
  }

  // Called when the system theme changes
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Reapply the map theme when the system theme changes
    if (_mapController != null) {
      _applyMapTheme();
    }
  }

  void _applyMapTheme() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Load the appropriate style based on system theme using a ternary operator
    final mapStyleJson = isDarkMode
        ? await rootBundle.loadString('assets/mapStyles/dark.json')
        : await rootBundle.loadString('assets/mapStyles/standard.json');

    // Apply the selected map style (dark or standard)
    _mapController?.setMapStyle(mapStyleJson);
  }

  static const String defaultMapStyleName = 'default';

  Future<void> _loadMapStyle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mapStyleName = prefs.getString('mapStyle') ?? defaultMapStyleName;

    if (mapStyleName == defaultMapStyleName) {
      setState(() {
        _selectedMapStyle = null;
      });
      return;
    }

    try {
      String mapStyleJson =
          await rootBundle.loadString('assets/mapStyles/$mapStyleName.json');
      setState(() {
        _selectedMapStyle = mapStyleJson;
      });
    } catch (e) {
      // Handle error, e.g., log it or show a message to the user
      print('Error loading map style: $e');
      // Optionally, set a default style or show an error message
      setState(() {
        _selectedMapStyle = null;
      });
    }
  }

  @override
  void dispose() {
    _filterController.close();
    WidgetsBinding.instance.removeObserver(this);
    _locationUpdateTimer?.cancel();

    super.dispose();
  }

  void _showMapThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Map Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildThemeTiles(),
          ),
        );
      },
    );
  }

  List<Widget> _buildThemeTiles() {
    const List<String> themes = ['standard', 'aubergine', 'dark', 'night'];
    return themes.map((theme) {
      return ListTile(
        title: Text(theme), // Capitalize the first letter
        onTap: () {
          _changeMapTheme(theme);
          Navigator.of(context).pop();
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _getDrawerForRole(client!),
      endDrawer: RightDrawer(
        isExpanded: true, // or false based on the initial state you want
        onRefresh: () {
          _initializeLocation();
          _fetchAreas(); // Fetch areas when the widget initializes
          _fetchVehiculs(); // Fetch areas when the widget initializes
        },
        onFilter: () async {
          final selectedVehicleTypes = await showModalBottomSheet<List<String>>(
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
      ),
      body: Stack(
        children: [
          if (currentLocation != null)
            CustomGoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              currentLocation: currentLocation,
              markers: _markers,
              polygons: polygons,
              polylines: _polylines,
              mapType: _currentMapType,
              applyMapTheme: _applyMapTheme,
              onLongPress: _onLongPress,
            )
          else
            const Center(child: CircularProgressIndicator()),
          menuButton(scaffoldKey: scaffoldKey),
          InfoButton(scaffoldKey: scaffoldKey),
          if (currentLocation != null)
            PositionedButton(
              icon: Icons.my_location,
              bottom: 60,
              right: 20,
              tooltipMessage: 'Current Location',
              onPressed: _initializeLocation,
            ),
          if (currentLocation != null) _buildMapGuidButton(),
          if (currentLocation != null)
            ScanCodeButton(
              client: widget.client,
              context: context,
              getMissingFields: _getMissingFields,
              showMissingInfoDialog: _showMissingInfoDialog,
              buildJuicerOperationsBottomSheet: () =>
                  const JuicerOperationsBottomSheet(),
            ),
          if (currentLocation != null)
            PositionedButton(
              icon: Icons.layers_outlined,
              bottom: 120,
              left: 20,
              tooltipMessage: 'Change Map Style',
              onPressed: _showMapThemeDialog,
            ),
          if (isLoadingLocation)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _getDrawerForRole(Client client) {
    switch (client.role.toLowerCase()) {
      case 'juicer':
        return JuicerLeftDrawer(
          client: client,
          onLogout: () async {
            await onLogout(context); // Wrap the async call
          },
          vehicles: _vehicleList,
        );
      case 'tech':
        return TechLeftDrawer(
          client: client,
          onLogout: () async {
            await onLogout(context); // Wrap the async call
          },
          vehicles: _vehicleList,
        );
      default:
        return LeftDrawer(
          client: client,
          onLogout: () async {
            await onLogout(context); // Wrap the async call
          },
        );
    }
  }

  void _onLongPress(LatLng position) async {
    final markerId = MarkerId(DateTime.now().millisecondsSinceEpoch.toString());

    // Get location info for the long-pressed position
    final locationInfo =
        await getAddressFromLatLng(position.latitude, position.longitude);

    final marker = Marker(
      markerId: markerId,
      position: position,
      onTap: () => _onMarkerTap(markerId),
      infoWindow: InfoWindow(
        title: locationInfo?.address ?? 'Unknown Location',
        // Use address as title
        snippet: 'Tap to view details',
      ),
    );

    setState(() {
      // Remove the previous destination marker if it exists
      if (_destinationMarkerIds.isNotEmpty) {
        final previousMarkerId = _destinationMarkerIds.last;
        _removeMarker(
            previousMarkerId.value); // Remove using the string ID of MarkerId
      }

      // Add the new destination marker
      _markers.add(marker);
      _markerInfoMap[markerId] = MarkerInfo(
        id: markerId.value,
        // Use the markerId string value
        model: locationInfo?.address ?? 'Unknown',
        // Store the address as model info
        isAvailable: false,
        vehicle: null,
        isParking: false,
        isDestination: true,
      );

      // Add the new marker ID to the destination markers list
      _destinationMarkerIds.add(markerId);

      // Set the new destination
      _destination = position;
    });

    // Call the drawRoute function from the MapService instance
    final routeData = await _mapService.fetchRouteDetails(
      currentLocation!,
      position,
      context.locale.languageCode,
    );

    if (routeData != null) {
      _mapService.addPolyline(routeData['points'], _polylines, setState);

      // Update the MarkerInfo for the selected destination
      setState(() {
        if (_markerInfoMap.containsKey(markerId)) {
          _markerInfoMap[markerId] = MarkerInfo(
            id: _markerInfoMap[markerId]!.id,
            model: _markerInfoMap[markerId]!.model,
            isAvailable: _markerInfoMap[markerId]!.isAvailable,
            vehicle: _markerInfoMap[markerId]!.vehicle,
            isParking: false,
            isDestination: true,
            distance: routeData['distance'],
            duration: routeData['duration'],
            steps: routeData['steps'],
          );
        }
      });
    }
  }

  void _removeMarker(String markerId) {
    setState(() {
      // Find the MarkerId in _destinationMarkerIds that matches the string markerId
      MarkerId? markerToRemove = _destinationMarkerIds
          .firstWhere((markerIdObj) => markerIdObj.value == markerId);

      // Remove the marker from _markers
      _markers.removeWhere((marker) => marker.markerId == markerToRemove);

      // Remove from _destinationMarkerIds
      _destinationMarkerIds.remove(markerToRemove);

      // Optionally clear polylines if they are associated with the marker
      _polylines.clear();

      // Remove marker info from the map
      _markerInfoMap.remove(markerId);
    });
  }

  void _onMarkerTap(MarkerId markerId) {
    final markerInfo = _markerInfoMap[markerId];
    if (markerInfo == null) return;

    if (markerInfo.isParking) {
      // Handle parking marker tap
      _showParkingDetails(markerInfo.parking!); // Show parking details
    } else if (markerInfo.isDestination) {
      // Handle destination marker tap
      _showDestinationDetails(markerInfo);
    } else {
      // Handle vehicle marker tap
      showModalBottomSheet(
        context: context,
        builder: (context) => VehicleBottomSheet(
          markerInfo: markerInfo, // Pass vehicle marker information
          currentLocation: currentLocation, // Pass current location
          drawRoute:
              (LatLng origin, LatLng destination, MarkerId markerId) async {
            final routeData = await _mapService.fetchRouteDetails(
              origin,
              destination,
              context.locale.languageCode,
            );

            if (routeData != null) {
              _mapService.addPolyline(
                  routeData['points'], _polylines, setState);

              setState(() {
                if (_markerInfoMap.containsKey(markerId)) {
                  _markerInfoMap[markerId] = MarkerInfo(
                    id: _markerInfoMap[markerId]!.id,
                    model: _markerInfoMap[markerId]!.model,
                    isAvailable: _markerInfoMap[markerId]!.isAvailable,
                    vehicle: _markerInfoMap[markerId]!.vehicle,
                    isParking: false,
                    isDestination: true,
                    distance: routeData['distance'],
                    duration: routeData['duration'],
                    steps: routeData['steps'],
                  );
                }
              });
            }
          },
          context: context,
        ),
      );
    }
  }

  void _showParkingDetails(Parking parking) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Parking Name
                    Text(
                      parking.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // Parking Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            parking.address,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Status and Capacity
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          parking.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 16,
                            color: parking.isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capacity: ${parking.currentCapacity}/${parking.maxCapacity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    // Opening Hours
                    Text(
                      'Hours: ${parking.openingTime} - ${parking.closingTime}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Parking Pictures (if available)
                    ParkingImages(
                      parking: parking,
                      showImagePreview: _showImagePreview,
                      defaultImageUrl: defaultImageUrl,
                    ),
                    const SizedBox(height: 16),
                    // Close Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDarkMode ? Colors.grey[700] : Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(imageUrl),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDestinationDetails(MarkerInfo markerInfo) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            color: isDarkMode ? Colors.black : Colors.white,
            // Adjust background color
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Remove Marker button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close bottom sheet
                      _removeMarker(
                          markerInfo.id); // Remove the marker from the map
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove Marker'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Keep delete button red
                    ),
                  ),
                ),
                Text(
                  'Destination Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Location: ${markerInfo.model}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Distance: ${markerInfo.distance ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Duration: ${markerInfo.duration ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                ExpansionTile(
                  title: Text(
                    'Turn-by-turn Instructions',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  children: [
                    for (var step in markerInfo.steps ?? [])
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: html.Html(
                          data: step, // Render HTML data using flutter_html
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.grey[700]
                          : Colors.blue, // Adjust button color
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
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

  Widget _buildMapGuidButton() {
    return Positioned(
      bottom: 140,
      // Positioned above the Current Location button
      right: 20,
      child: Tooltip(
        message: _showMapGuide ? 'Close Map Guide' : 'Open Map Guide',
        child: RawMaterialButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return const MapGuideBottomSheet();
              },
            );
          },
          fillColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0,
            height: 40.0,
          ),
          child: Icon(
            _showMapGuide ? Icons.close : Icons.map,
            size: 24.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildScanCodeButton(Client client) {
    final buttonColor =
        (client.balance > 0 || client.role.toLowerCase() == 'juicer')
            ? Colors.red
            : Colors.grey; // Red if balance > 0 or role is juicer, grey if not
    const iconColor = Colors.white; // White text color for the Scan button

    return Positioned(
      bottom: 20,
      // Position it at the bottom
      left: 20,
      // Padding from the left side
      right: 20,
      // Padding from the right side, making it span almost the entire width
      child: Tooltip(
        message: 'Scan QR Code', // Tooltip message
        child: RawMaterialButton(
          onPressed:
              (client.balance > 0 || client.role.toLowerCase() == 'juicer')
                  ? () {
                      // Check if any required info is missing
                      List<String> missingFields = _getMissingFields(client);

                      if (missingFields.isNotEmpty) {
                        _showMissingInfoDialog(
                            missingFields); // Show dialog if info is missing
                      } else {
                        // Proceed to show the scan bottom sheet if no info is missing
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            if (client.role.toLowerCase() == 'juicer') {
                              return const JuicerOperationsBottomSheet(); // Custom bottom sheet for Juicer operations
                            } else {
                              return const CodeInputBottomSheet(); // Custom bottom sheet widget for clients
                            }
                          },
                        );
                      }
                    }
                  : null,
          // Disable the button if balance is 0 and role is not juicer
          fillColor: buttonColor,
          // Set the button background color to red or grey depending on balance or role
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                30.0), // Rounded corners for a smoother look
          ),
          constraints: const BoxConstraints.tightFor(
            width: double.infinity, // Full width button
            height: 60.0, // Larger height for better accessibility
          ),
          child: const Text(
            'Scan', // Display "Scan" on the button
            style: TextStyle(
              fontSize: 18.0, // Increase text size for better readability
              color: iconColor, // Set the text color to white for contrast
              fontWeight: FontWeight.bold, // Make the text bold
            ),
          ),
        ),
      ),
    );
  }

// Method to get missing fields
  List<String> _getMissingFields(Client client) {
    List<String> missingFields = [];
    if (client.fullName.isEmpty) missingFields.add('Full Name');
    if (client.email.isEmpty) missingFields.add('Email');
    if (client.phoneNumber.isEmpty) missingFields.add('Phone Number');
    if (client.address.isEmpty) missingFields.add('Address');
    return missingFields;
  }

// Custom bottom sheet for Juicer operations

// Dialog to show missing info
  void _showMissingInfoDialog(List<String> missingFields) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Incomplete Profile"),
          content: Text("The following fields are missing:\n\n" +
              missingFields.join("\n")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMapStyleButton() {
    return Positioned(
      bottom: 120, // Positioned above the Scan button on the left
      left: 20, // Aligned to the left side
      child: Tooltip(
        message: 'Change Map Style', // Tooltip message
        child: RawMaterialButton(
          onPressed: _showMapThemeDialog,
          fillColor: Theme.of(context).colorScheme.primary,
          // Use theme-based color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0,
            height: 40.0,
          ),
          child: Icon(
            Icons.layers_outlined,
            size: 24.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _initializeLocation() async {
    setState(() {
      isLoadingLocation = true; // Start showing loading spinner
    });
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        isLoadingLocation = false; // Location fetched successfully
      });
      if (_mapController != null && currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation!, 15.0),
        );
      }
    } catch (e) {
      showToast('An unexpected error occurred: $e');

      setState(() {
        isLoadingLocation = false; // Stop loading even if location fetch failed
        // Optionally, set a default location or handle accordingly
      });
    }
  }

  Future<void> _fetchAreas() async {
    try {
      List<Area> areas = await _areaService.fetchAreas();
      setState(() {
        polygons = areas.map((area) => area.polygon).toSet();
      });
    } catch (e) {
      showToast('An unexpected error occurred: $e');
      // Log the error for debugging
    }
  }

  Future<void> _fetchVehiculs() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final scooterIcon =
        await createCustomIcon(Icons.electric_scooter, Colors.blue);
    final ebikeIcon = await createCustomIcon(Icons.pedal_bike, Colors.green);
    final parkingIcon = await createCustomIcon(Icons.local_parking, Colors.red);

    try {
      List<Parking> parkings = await _parkingService.fetchParkings();

      List<Vehicle> vehicles = await _vehicleService.fetchVehicles();
      _vehicleList = vehicles;
      final filteredVehicles = vehicles.where((vehicle) {
        if (_selectedVehicleTypes.isEmpty) return true; // No filter selected
        return _selectedVehicleTypes.any(
            (type) => vehicle.model.toLowerCase().contains(type.toLowerCase()));
      }).toList();

      final newMarkers = <Marker>{};
      final newMarkerInfo = <MarkerId, MarkerInfo>{};
      for (var parking in parkings) {
        if (parking.coordinates.latitude == 0.0 ||
            parking.coordinates.longitude == 0.0) {
          continue; // Skip invalid data
        }

        final markerId = MarkerId(parking.id);
        final markerIcon = getMarkerIcon(
          null, // No vehicle, so we pass null
          BitmapDescriptor.defaultMarker, // Placeholder for scooters
          BitmapDescriptor.defaultMarker, // Placeholder for ebikes
          parkingIcon, // Pass the parking icon
        );
        final marker = Marker(
          markerId: markerId,
          icon: markerIcon,
          position: LatLng(
              parking.coordinates.latitude, parking.coordinates.longitude),
          onTap: () => _onMarkerTap(markerId),
          infoWindow: InfoWindow(
            title: parking.name,
            snippet:
                'Capacity: ${parking.currentCapacity}/${parking.maxCapacity}',
          ),
        );
        newMarkers.add(marker);
        newMarkerInfo[markerId] = MarkerInfo(
          id: parking.id,
          model: parking.name,
          isAvailable: parking.isOpen,
          isParking: true,
          parking: parking,
          vehicle: null,
          // No vehicle, only parking
          isDestination: false,
        );
      }
      for (var vehicle in filteredVehicles) {
        if (vehicle.latitude == null || vehicle.longitude == null) {
          continue; // Skip invalid data
        }

        final markerIcon = getMarkerIcon(
            vehicle, scooterIcon, ebikeIcon, BitmapDescriptor.defaultMarker);
        final markerId = MarkerId(vehicle.id);

        final marker = Marker(
          markerId: markerId,
          icon: markerIcon,
          position: LatLng(vehicle.latitude!, vehicle.longitude!),
          onTap: () => _onMarkerTap(markerId),
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
            isParking: false,
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
      Fluttertoast.showToast(
          msg: 'Error fetching vehicles: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isLoading = false; // Hide loading indicator on error
      });
    }
  }

  Future<void> showroledialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("ROle"),
          content: Text("ROle :\n\n" + widget.client!.role),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _changeMapTheme(String theme) async {
    const mapStyles = {
      'aubergine': 'assets/mapStyles/aubergine.json',
      'dark': 'assets/mapStyles/dark.json',
      'night': 'assets/mapStyles/night.json',
      'standard': 'assets/mapStyles/standard.json',
    };

    final stylePath = mapStyles[theme] ?? mapStyles['standard'];

    try {
      final style = await rootBundle.loadString(stylePath!);
      _mapController?.setMapStyle(style);
    } catch (e) {
      print('Error loading map style: $e');
    }
  }

  Future<void> onLogout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'.tr()),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel logout
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm logout
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _authService.logout(); // Use the AuthService to logout
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInPage()));
    }
  }
}
