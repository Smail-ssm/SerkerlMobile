import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import '../model/parking.dart';
import '../model/vehicule.dart';
import '../widgets/MarkerInfo.dart';
import 'Vehicleservice.dart';
import 'parkingService.dart';

class MapService {
  final ParkingService _parkingService;
  final Vehicleservice _vehicleService;

  MapService(this._parkingService, this._vehicleService);

  // Create custom icon function
  Future<BitmapDescriptor> createCustomIcon(IconData icon, Color color) async {
    final iconSize = 120.0;
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;

    canvas.drawCircle(Offset(iconSize / 2, iconSize / 2), iconSize / 2, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(fontSize: iconSize * 0.6, fontFamily: icon.fontFamily, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(iconSize / 4, iconSize / 4));

    final image = await pictureRecorder.endRecording().toImage(iconSize.toInt(), iconSize.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  // Fetch vehicles and parkings, and create markers
  Future<Map<String, dynamic>> fetchAndCreateMarkers(
      Set<Marker> markers, Map<MarkerId, MarkerInfo> markerInfoMap, List<String> selectedVehicleTypes) async {

    final scooterIcon = await createCustomIcon(Icons.electric_scooter, Colors.blue);
    final ebikeIcon = await createCustomIcon(Icons.pedal_bike, Colors.green);
    final parkingIcon = await createCustomIcon(Icons.local_parking, Colors.red);

    final List<Parking> parkings = await _parkingService.fetchParkings();
    final List<Vehicle> vehicles = await _vehicleService.fetchVehicles();

    final Set<Marker> newMarkers = {};
    final Map<MarkerId, MarkerInfo> newMarkerInfo = {};

    // Add parking markers
    for (var parking in parkings) {
      if (parking.coordinates.latitude == 0.0 || parking.coordinates.longitude == 0.0) {
        continue; // Skip invalid data
      }

      final markerId = MarkerId(parking.id);
      final marker = Marker(
        markerId: markerId,
        icon: parkingIcon,
        position: LatLng(parking.coordinates.latitude, parking.coordinates.longitude),
        infoWindow: InfoWindow(
          title: parking.name,
          snippet: 'Capacity: ${parking.currentCapacity}/${parking.maxCapacity}',
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
      return selectedVehicleTypes.any((type) => vehicle.model.toLowerCase().contains(type.toLowerCase()));
    }).toList();

    for (var vehicle in filteredVehicles) {
      if (vehicle.latitude == null || vehicle.longitude == null) {
        continue; // Skip invalid data
      }

      final markerId = MarkerId(vehicle.id);
      final markerIcon = vehicle.model.toLowerCase().contains('scooter') ? scooterIcon : ebikeIcon;

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
  void _onMarkerTap(MarkerId markerId, Map<MarkerId, MarkerInfo> markerInfoMap) {
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
}
