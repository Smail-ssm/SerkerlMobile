import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:ebike/pages/FeedbackPage.dart';
import 'package:ebike/pages/NotificationsList.dart';
import 'package:ebike/pages/Pricing.dart';
import 'package:ebike/pages/Settings.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/services/Vehicleservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/area.dart';
import '../model/client.dart';
import '../model/parking.dart';
import '../model/vehicule.dart';
import '../services/AreaService.dart';
import '../services/map_service.dart';
import '../services/parkingService.dart';
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
import 'SupportPage.dart';

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
  Set<Polyline> _polylines = {};
  final List<MarkerId> _destinationMarkerIds = [];
  final MapService _mapService =
      MapService(ParkingService(), Vehicleservice()); // Initialize the service

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

  late LatLng _destination; // Track loading state

  @override
  void initState() {
    super.initState();

    _initializeLocation();
    _fetchAreas(); // Fetch areas when the widget initializes
    _fetchVehiculs(); // Fetch areas when the widget initializes
    //  _fetchAndRenderParkings(); // Fetch and render parking on map initialization

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

  Future<void> _fetchMarkers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call the service with _selectedVehicleTypes passed as the filter
      final result = await _mapService.fetchAndCreateMarkers(
        _markers,
        _markerInfoMap,
        _selectedVehicleTypes, // Pass the selected vehicle types
      );

      setState(() {
        _markers.clear();
        _markers.addAll(result['markers']);
        _markerInfoMap.clear();
        _markerInfoMap.addAll(result['markerInfoMap']);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: 'Error fetching markers: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
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
      _moveCameraToCurrentLocation();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching location: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        isLoadingLocation = false; // Stop loading even if location fetch failed
        // Optionally, set a default location or handle accordingly
      });
    }
  }

  void _moveCameraToCurrentLocation() {
    if (_mapController != null && currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 15.0),
      );
    }
  }

  Future<void> _fetchAreas() async {
    try {
      List<Area> areas = await _areaService.fetchAreas();
      setState(() {
        polygons = areas.map((area) => area.polygon).toSet();
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error fetching areas: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
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
      body: Stack(
        children: [
          if (currentLocation != null)
            _buildGoogleMap()
          else
            const Center(child: CircularProgressIndicator()),
          menuButton(scaffoldKey: scaffoldKey),
          InfoButton(scaffoldKey: scaffoldKey),
          if (currentLocation != null) _buildCurrentLocationButton(),
          if (currentLocation != null) _buildMapGuidButton(),
          if (currentLocation != null) _buildScanCodeButton(),
          if (currentLocation != null) _buildMapStyleButton(),
          if (isLoadingLocation)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    if (currentLocation == null) {
      return Container(); // Or any placeholder widget
    }
    return GoogleMap(
      mapType: _currentMapType,
      initialCameraPosition: CameraPosition(
        target: currentLocation!,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      polygons: polygons,
      markers: _markers,
      polylines: _polylines,
      // Display the route polyline
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      // No my location button
      zoomControlsEnabled: false,
      onLongPress: _onLongPress,
      // Handle long press to set destination
      mapToolbarEnabled: false,
    );
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

    _drawRoute(currentLocation!, position, markerId);
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
          context: context,
          markerInfo: markerInfo, // Pass vehicle marker information
          currentLocation: currentLocation, // Pass current location
          drawRoute: (LatLng origin, LatLng destination, MarkerId markerId) {
            _drawRoute(
                origin, destination, markerId); // Implement route drawing
          },
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Parking Name
                    Text(
                      parking.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    // Parking Address
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            parking.address,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
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
                    SizedBox(height: 8),
                    Text(
                      'Capacity: ${parking.currentCapacity}/${parking.maxCapacity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 8),
                    // Opening Hours
                    Text(
                      'Hours: ${parking.openingTime} - ${parking.closingTime}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16),
                    // Parking Pictures (if available)
                    _buildParkingImages(parking),
                    SizedBox(height: 16),
                    // Close Button
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.blue,
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
  Widget _buildParkingImages(Parking parking) {
    if (parking.images.isEmpty) {
      return Text('No images available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: parking.images.length,
            itemBuilder: (context, index) {
              final imageUrl = parking.images[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 200,
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  final bool _showMapGuide = false;

  Widget _buildRefreshButton() {
    return Builder(
      builder: (BuildContext context) {
        final buttonColor = Theme.of(context).colorScheme.primary;
        final iconColor = Theme.of(context).colorScheme.onPrimary;

        return FloatingActionButton.extended(
          onPressed: () {
            _initializeLocation();
            _fetchAreas(); // Fetch areas when the widget initializes
            _fetchVehiculs(); // Fetch areas when the widget initializes
            //  _fetchAndRenderParkings(); // Fetch and render parking on map initialization
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
      bottom: 80, // Adjusted above the Scan button
      right: 20, // Positioned close to the right edge
      child: Tooltip(
        message: 'Current Location',
        child: RawMaterialButton(
          onPressed: _initializeLocation,
          fillColor: Theme.of(context).colorScheme.primary,
          // Use theme-based color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          constraints: const BoxConstraints.tightFor(
            width: 40.0,
            height: 40.0,
          ),
          child: Icon(
            Icons.my_location,
            size: 24.0,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildMapGuidButton() {
    return Positioned(
      bottom: 140, // Positioned above the Current Location button
      right: 20,
      child: Tooltip(
        message: _showMapGuide ? 'Close Map Guide' : 'Open Map Guide',
        child: RawMaterialButton(
          onPressed: () {
            _showMapGuideBottomSheet(context);
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

  Widget _buildScanCodeButton() {
    final buttonColor = Colors.red; // Set the color to red as in the image
    final iconColor = Colors.white; // White text color for the Scan button

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
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return const CodeInputBottomSheet(); // Custom bottom sheet widget
              },
            );
          },
          fillColor: buttonColor,
          // Set the button background color to red
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                30.0), // Rounded corners for a smoother look
          ),
          constraints: const BoxConstraints.tightFor(
            width: double.infinity, // Full width button
            height: 60.0, // Larger height for better accessibility
          ),
          child: Text(
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

  Widget _buildMapStyleButton() {
    return Positioned(
      bottom: 120, // Positioned above the Scan button on the left
      left: 20, // Aligned to the left side
      child: Tooltip(
        message: 'Change Map Style', // Tooltip message
        child: RawMaterialButton(
          onPressed: _showMapTypeDialog,
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

  void _changeMapType(MapType mapType) {
    setState(() {
      _currentMapType = mapType;
    });
    Navigator.of(context).pop(); // Close the dialog
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
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BalanceAndPricingPage (client: widget.client)),
              );
            },
            value: "0",
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SupportPage(client: widget.client)),
              );
            },
          ),
          buildListTile(
            'profile'.tr(),
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
            'share'.tr(),
            Icons.share,
            () {
              showShareBottomSheet(
                  context, "HGH3YJJ"); // Use your dynamic promo code here
            },
          ),
          buildListTile(
            'feedback'.tr(),
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
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }, // Call the logout function when tapped
          child: CircleAvatar(child: Icon(Icons.settings, color: iconColor)),
        ),
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
          title: Text('Logout'.tr()),
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
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

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

  Future<void> _drawRoute(
      LatLng origin, LatLng destination, MarkerId markerId) async {
    final String language = context.locale.languageCode;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin='
        '${origin.latitude},${origin.longitude}&destination='
        '${destination.latitude},${destination.longitude}&key=${Config.googleMapsApiKey}&language=$language';

    try {
      final response =
          await http.get(Uri.parse(url)); // Use http.get to fetch directions
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode the JSON response

        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          // Extract polyline, distance, duration, and steps
          final points = route['overview_polyline']['points'];
          final distance = route['legs'][0]['distance']['text'];
          final duration = route['legs'][0]['duration']['text'];

          List<String> steps = [];
          for (var step in route['legs'][0]['steps']) {
            steps.add(
                step['html_instructions']); // Extract turn-by-turn instructions
          }

          // Update the marker info with the extracted data
          setState(() {
            _addPolyline(points); // Draw the polyline on the map

            // Update the MarkerInfo for the selected destination
            if (_markerInfoMap.containsKey(markerId)) {
              _markerInfoMap[markerId] = MarkerInfo(
                isParking: false,

                id: _markerInfoMap[markerId]!.id,
                model: _markerInfoMap[markerId]!.model,
                isAvailable: _markerInfoMap[markerId]!.isAvailable,
                vehicle: _markerInfoMap[markerId]!.vehicle,
                isDestination: true,
                distance: distance,
                // Set the distance
                duration: duration,
                // Set the duration
                steps: steps, // Set the turn-by-turn instructions
              );
            }
          });
        } else {
          Fluttertoast.showToast(
              msg: 'No routes found',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Failed to fetch directions. Status Code: ${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }
  }

  void _addPolyline(String encodedPolyline) {
    List<LatLng> polylinePoints = decodePolyline(encodedPolyline);
    setState(() {
      _polylines.clear(); // Clear any previous polylines
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          visible: true,
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }
}
