import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  Future<Position> determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool openSettings = await _showLocationDialog(
        context,
        'Location Services Disabled',
        'Please enable location services to continue using this app.',
      );
      if (openSettings) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }
      } else {
        throw Exception('User declined to enable location services.');
      }
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      bool openSettings = await _showLocationDialog(
        context,
        'Location Permission Denied',
        'Please allow location permissions in settings to continue using this app.',
      );
      if (openSettings) {
        await Geolocator.requestPermission();
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      } else {
        throw Exception('User declined to enable location permissions.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      bool openSettings = await _showLocationDialog(
        context,
        'Location Permission Permanently Denied',
        'Please enable location permissions in app settings to continue using this app.',
      );
      if (openSettings) {
        await Geolocator.openAppSettings();
        throw Exception('Location permissions are permanently denied.');
      } else {
        throw Exception('User declined to enable location permissions.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> _showLocationDialog(BuildContext context, String title, String content) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ) ??
        false;
  }
}
