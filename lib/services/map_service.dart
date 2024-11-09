import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../model/client.dart';
import '../model/parking.dart';
import '../model/vehicule.dart';
import '../util/Config.dart';
import '../util/util.dart';
import '../widgets/MarkerInfo.dart';
import 'Vehicleservice.dart';
import 'parkingService.dart';

class MapService {
  final ParkingService _parkingService;
  final Vehicleservice _vehicleService;

   MapService( this._parkingService, this._vehicleService);

  // Create custom icon function
  Future<BitmapDescriptor> createCustomIcon(IconData icon, Color color) async {
    const iconSize = 120.0;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;

    canvas.drawCircle(const Offset(iconSize / 2, iconSize / 2), iconSize / 2, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
          fontSize: iconSize * 0.6,
          fontFamily: icon.fontFamily,
          color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(iconSize / 4, iconSize / 4));

    final image = await pictureRecorder
        .endRecording()
        .toImage(iconSize.toInt(), iconSize.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  // Fetch vehicles and parkings, and create markers
  Future<Map<String, dynamic>> fetchAndCreateMarkers(
      Set<Marker> markers,
      Map<MarkerId, MarkerInfo> markerInfoMap,
      List<String> selectedVehicleTypes) async {
    final scooterIcon =
        await createCustomIcon(Icons.electric_scooter, Colors.blue);
    final ebikeIcon = await createCustomIcon(Icons.pedal_bike, Colors.green);
    final parkingIcon = await createCustomIcon(Icons.local_parking, Colors.red);

    final List<Parking> parkings = await _parkingService.fetchParkings();
    final List<Vehicle> vehicles = await _vehicleService.fetchVehicles();

    final Set<Marker> newMarkers = {};
    final Map<MarkerId, MarkerInfo> newMarkerInfo = {};

    // Add parking markers
    for (var parking in parkings) {
      if (parking.coordinates.latitude == 0.0 ||
          parking.coordinates.longitude == 0.0) {
        continue; // Skip invalid data
      }

      final markerId = MarkerId(parking.id);
      final marker = Marker(
        markerId: markerId,
        icon: parkingIcon,
        position:
            LatLng(parking.coordinates.latitude, parking.coordinates.longitude),
        infoWindow: InfoWindow(
          title: parking.name,
          snippet:
              'Capacity: ${parking.currentCapacity}/${parking.maxCapacity}',
        ),
        onTap: () {
          _onMarkerTap(markerId, markerInfoMap);
        },
      );

      newMarkers.add(marker);
      newMarkerInfo[markerId] = MarkerInfo(
        id: parking.id,
        model: parking.name,
        isAvailable: parking.isOpen,
        isParking: true,
        parking: parking,
        vehicle: null,
        isDestination: false,
      );
    }

    // Filter and add vehicle markers
    final filteredVehicles = vehicles.where((vehicle) {
      if (selectedVehicleTypes.isEmpty) return true;
      return selectedVehicleTypes.any(
          (type) => vehicle.model.toLowerCase().contains(type.toLowerCase()));
    }).toList();

    for (var vehicle in filteredVehicles) {
      if (vehicle.latitude == null || vehicle.longitude == null) {
        continue; // Skip invalid data
      }

      final markerId = MarkerId(vehicle.id);
      final markerIcon = vehicle.model.toLowerCase().contains('scooter')
          ? scooterIcon
          : ebikeIcon;

      final marker = Marker(
        markerId: markerId,
        icon: markerIcon,
        position: LatLng(vehicle.latitude!, vehicle.longitude!),
        infoWindow: InfoWindow(
          title: vehicle.model,
          snippet: vehicle.isAvailable ? 'Available' : 'Not Available',
        ),
        onTap: () {
          _onMarkerTap(markerId, markerInfoMap);
        },
      );

      newMarkers.add(marker);
      newMarkerInfo[markerId] = MarkerInfo(
        id: vehicle.id,
        model: vehicle.model,
        isAvailable: vehicle.isAvailable,
        isParking: false,
        vehicle: vehicle,
        parking: null,
        isDestination: false,
      );
    }

    return {'markers': newMarkers, 'markerInfoMap': newMarkerInfo};
  }

  // Example onMarkerTap function to handle taps
  void _onMarkerTap(
      MarkerId markerId, Map<MarkerId, MarkerInfo> markerInfoMap) {
    final markerInfo = markerInfoMap[markerId];
    if (markerInfo == null) return;

    if (markerInfo.isParking) {
      print('Parking tapped: ${markerInfo.model}');
      // Show parking details logic here
    } else {
      print('Vehicle tapped: ${markerInfo.model}');
      // Show vehicle details logic here
    }
  }

  Future<void> updateUserLocation(Client? client) async {
    if (client?.role.toLowerCase() == 'client') return;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final String env =
        getFirestoreDocument(); // Get environment (e.g., 'preprod')
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await _firestore
          .collection(env)
          .doc('users') // This refers to the 'users' collection
          .collection('users') // This is where individual users' documents are stored
          .doc(client?.userId)
          .update({
        'lat': position.latitude,
        'lng': position.longitude,
      });
      debugPrint(
          'User location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }
  void addPolyline(
      String encodedPolyline, Set<Polyline> polylines, Function updatePolylines) {
    List<LatLng> polylinePoints = decodePolyline(encodedPolyline);
    updatePolylines(() {
      polylines.clear(); // Clear any previous polylines
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          visible: true,
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dLng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylinePoints;
  }

  Future<Map<String, dynamic>?> fetchRouteDetails(
      LatLng origin, LatLng destination, String language) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin='
        '${origin.latitude},${origin.longitude}&destination='
        '${destination.latitude},${destination.longitude}&key=${Config.googleMapsApiKey}&language=$language';

    try {
      final response = await http.get(Uri.parse(url)); // Use http.get to fetch directions
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
            steps.add(step['html_instructions']); // Extract turn-by-turn instructions
          }

          return {
            'points': points,
            'distance': distance,
            'duration': duration,
            'steps': steps,
          };
        } else {
          Fluttertoast.showToast(
              msg: 'No routes found',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          return null;
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
        return null;
      }
    } catch (e) {
      print('Error fetching directions: $e');
      return null;
    }
  }
}
