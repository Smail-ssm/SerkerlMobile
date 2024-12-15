import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'MarkerInfo.dart';

class VehicleBottomSheet extends StatelessWidget {
  const VehicleBottomSheet({
    Key? key,
    required this.context,
    required this.markerInfo,
    required this.currentLocation,
    required this.drawRoute,
  }) : super(key: key);

  final BuildContext context;
  final MarkerInfo markerInfo;
  final LatLng? currentLocation;
  final Function(LatLng origin, LatLng destination, MarkerId markerId)
      drawRoute;

  @override
  Widget build(BuildContext context) {
    // Detect if the app is in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    LatLng vehicleLocation = LatLng(
      markerInfo.vehicle!.latitude!,
      markerInfo.vehicle!.longitude!,
    );

    // Calculate the distance between the current location and the vehicle location
    double distance = _calculateDistance(
      currentLocation!.latitude,
      currentLocation!.longitude,
      vehicleLocation.latitude,
      vehicleLocation.longitude,
    );

    // Estimate time (in seconds) for walking
    double walkingTime = distance / 1.39; // 1.39 m/s for walking (5 km/h)

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        // Set color based on theme
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black45 : Colors.black26,
            offset: const Offset(0, 4),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Vehicle Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '№ ${markerInfo.vehicle!.model}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : Colors.black, // Dynamic text color
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        _getBatteryIcon(markerInfo.vehicle!.battery.level),
                        color: _getBatteryIconColor(
                            markerInfo.vehicle!.battery.level),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${calculateRange(markerInfo.vehicle!.battery.level) ?? 'N/A'} %',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.black87, // Dynamic text color
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.black,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(
                  Icons.lock_clock,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Start Ride Button

          const SizedBox(height: 16.0),

          // Pricing Information
          Text(
            'Pricing',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: isDarkMode
                  ? Colors.white70
                  : Colors.black87, // Dynamic text color
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            '1.00 DT + 0.250 DT/min',
            style: TextStyle(
              fontSize: 14.0,
              color: isDarkMode
                  ? Colors.white60
                  : Colors.black54, // Dynamic text color
            ),
          ),
          const SizedBox(height: 16.0),

          // Additional Details
          const Divider(),
          Text(
            'Distance: ${_formatDistance(distance)}',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white70
                  : Colors.black87, // Dynamic text color
            ),
          ),
          Text(
            'Estimated Time on Foot: ${_formatTime(walkingTime)}',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white70
                  : Colors.black87, // Dynamic text color
            ),
          ),
          const SizedBox(height: 16.0),

          // Close Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the bottom sheet
              },
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  // Function to get the appropriate battery icon based on the battery level
  IconData _getBatteryIcon(double batteryLevel) {
    if (batteryLevel <= 0.0) {
      return Icons.battery_0_bar_outlined;
    } else if (batteryLevel > 0 && batteryLevel <= 20) {
      return Icons.battery_1_bar_outlined;
    } else if (batteryLevel > 20 && batteryLevel <= 40) {
      return Icons.battery_2_bar_outlined;
    } else if (batteryLevel > 40 && batteryLevel <= 60) {
      return Icons.battery_3_bar_outlined;
    } else if (batteryLevel > 60 && batteryLevel <= 80) {
      return Icons.battery_4_bar_outlined;
    } else if (batteryLevel > 80 && batteryLevel <= 95) {
      return Icons.battery_5_bar_outlined;
    } else {
      return Icons.battery_full_outlined;
    }
  }

  // Function to get the battery icon color based on the level
  Color _getBatteryIconColor(double batteryLevel) {
    if (batteryLevel <= 20) {
      return Colors.red;
    } else if (batteryLevel <= 60) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // Function to start the ride (to be defined based on app logic)
  void _startRide() {
    // TODO: Add your ride start logic here
    print('Ride started');
  }

  // Function to calculate distance between two LatLng points (Haversine Formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000; // Radius of the Earth in meters
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in meters
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  // Format distance in kilometers
  String _formatDistance(double distanceInMeters) {
    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(2)} km';
  }

  // Format time to minutes and seconds
  String _formatTime(double timeInSeconds) {
    int minutes = (timeInSeconds / 60).floor();
    int seconds = (timeInSeconds % 60).floor();
    return '${minutes}m ${seconds}s';
  }

  calculateRange(double id) {
    return (id);
  }
}
