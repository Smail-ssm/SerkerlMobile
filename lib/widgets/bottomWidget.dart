import 'dart:async';
import 'dart:math';
import 'dart:ui';

 import 'package:ebike/services/Vehicleservice.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Rental.dart';
import '../model/vehicule.dart';
import '../services/NotificationManager.dart';
import '../services/RentalService.dart';
import 'MarkerInfo.dart';

class VehicleBottomSheet extends StatefulWidget {
  const VehicleBottomSheet({
    Key? key,
    required this.context,
    required this.userId,
    required this.markerInfo,
    required this.currentLocation,
    required this.drawRoute,
  }) : super(key: key);

  final BuildContext context;
  final String userId;
  final MarkerInfo markerInfo;
  final LatLng? currentLocation;
  final Function(LatLng origin, LatLng destination, MarkerId markerId)
      drawRoute;

  @override
  _VehicleBottomSheetState createState() => _VehicleBottomSheetState();
}

class _VehicleBottomSheetState extends State<VehicleBottomSheet> {
  final Vehicleservice _vehicleService = Vehicleservice();
  final RentalService _rentalService = RentalService();
  Timer? countdownTimer;

  bool _isVehicleReserved = false;
  Vehicle? selectedVH;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVehicleInfo(widget.markerInfo.vehicle!.id);
   }

  Future<void> _initializeVehicleInfo(String id) async {
    try {
      Vehicle vehicle = await _vehicleService.fetchVehicleById(id);
      setState(() {
        selectedVH = vehicle;
        _isVehicleReserved = vehicle.isReserved;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching vehicle info: $e');
      setState(() {
        _errorMessage = 'Failed to load vehicle details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16.0,
          ),
        ),
      );
    }

    if (selectedVH == null) {
      return Center(
        child: Text(
          'No vehicle data available.',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16.0,
          ),
        ),
      );
    }

    LatLng vehicleLocation = LatLng(
      selectedVH!.latitude!,
      selectedVH!.longitude!,
    );

    double distance = _calculateDistance(
      widget.currentLocation!.latitude,
      widget.currentLocation!.longitude,
      vehicleLocation.latitude,
      vehicleLocation.longitude,
    );

    double walkingTime = distance / 1.39;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
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
                    '№ ${selectedVH!.id.substring(0, selectedVH!.id.length > 6 ? 6 : selectedVH!.id.length)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(
                        _getBatteryIcon(selectedVH!.battery.level),
                        color: _getBatteryIconColor(selectedVH!.battery.level),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '${selectedVH!.battery.level} %',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
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
                child: Icon(
                  _isVehicleReserved
                      ? Icons.lock_clock
                      : Icons.lock_open_outlined,
                  color: Colors.white,
                  size: 28.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          const Divider(),
          Text(
            'Distance: ${_formatDistance(distance)}',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            'Estimated Time on Foot: ${_formatTime(walkingTime)}',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16.0),
          // Action Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_isVehicleReserved) {
                  if (selectedVH!.user == widget.userId) {
                    _handleReservation(false); // Cancel reservation
                  } else {
                    Fluttertoast.showToast(
                      msg:
                          'You cannot cancel this reservation as it was made by another user.',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                } else {
                  _handleReservation(true); // Reserve the vehicle
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVehicleReserved ? Colors.grey : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 48.0),
              ),
              child: Text(
                _isVehicleReserved ? 'Cancel Reservation' : 'Reserve',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Close Button
          Center(
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
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  IconData _getBatteryIcon(double batteryLevel) {
    if (batteryLevel <= 0.0) return Icons.battery_0_bar_outlined;
    if (batteryLevel > 0 && batteryLevel <= 20)
      return Icons.battery_1_bar_outlined;
    if (batteryLevel > 20 && batteryLevel <= 40)
      return Icons.battery_2_bar_outlined;
    if (batteryLevel > 40 && batteryLevel <= 60)
      return Icons.battery_3_bar_outlined;
    if (batteryLevel > 60 && batteryLevel <= 80)
      return Icons.battery_4_bar_outlined;
    if (batteryLevel > 80 && batteryLevel <= 95)
      return Icons.battery_5_bar_outlined;
    return Icons.battery_full_outlined;
  }

  Color _getBatteryIconColor(double batteryLevel) {
    if (batteryLevel <= 20) return Colors.red;
    if (batteryLevel <= 60) return Colors.orange;
    return Colors.green;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371000;
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  String _formatDistance(double distanceInMeters) {
    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(2)} km';
  }

  String _formatTime(double timeInSeconds) {
    int minutes = (timeInSeconds / 60).floor();
    int seconds = (timeInSeconds % 60).floor();
    return '${minutes}m ${seconds}s';
  }

  double calculateRange(double batteryLevel) {
    return batteryLevel;
  }


  Future<void> _handleReservation(bool isReserving) async {
    final String rentalId = DateTime.now().millisecondsSinceEpoch.toString();

    Rental rental = createRental(rentalId, isReserving);

    final bool isConfirmed = await _showConfirmationDialog(
      context,
      isReserving ? 'Reserve Scooter' : 'Cancel Reservation',
      isReserving
          ? 'Do you want to reserve this scooter? Once reserved, the lock will open, and the vehicle will be ready.'
          : 'Are you sure you want to cancel this reservation? This action cannot be undone.',
    );

    if (!isConfirmed) return;

    try {
      await _vehicleService.reserveVehicle(selectedVH!.id, widget.userId, rental);
      selectedVH!.user = widget.userId;
      setState(() => _isVehicleReserved = true);

      int countdownSeconds = 60; // Sample duration

      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (countdownSeconds <= 0) {
          timer.cancel();
          _saveCountdownCompletionTime();
          return;
        }
        setState(() => countdownSeconds--);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to reserve vehicle.',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  Rental createRental(String rentalId, bool isReserving) {
    final Rental rental = Rental(
      id: rentalId,
      vId: selectedVH!.id,
      startTime: DateTime.now(),
      expectedReturnTime: DateTime.now().add(const Duration(hours: 1)),
      baseRate: 5.0,
      unlockPrice: 1.0,
      pausePrice: 0.5,
      user: widget.userId,
      notes: isReserving
          ? 'Reserved by user ${widget.userId}'
          : 'Reservation canceled by user ${widget.userId}',
    );
    return rental;
  }
  Future<void> _saveCountdownCompletionTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('countdownCompletedAt', DateTime.now().toIso8601String());
    Fluttertoast.showToast(
      msg: 'Countdown completed and time saved.',
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
    );
  }

}
