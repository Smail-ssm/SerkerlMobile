import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import '../util/Config.dart';
import '../widgets/MarkerInfo.dart'; // Import your MarkerInfo model

class RouteService {
  final BuildContext context;
  final Map<MarkerId, MarkerInfo> markerInfoMap;
  final Function(String points) addPolyline;

  RouteService({
    required this.context,
    required this.markerInfoMap,
    required this.addPolyline,
  });

  Future<void> drawRoute(LatLng origin, LatLng destination, MarkerId markerId) async {
    final String language = context.locale.languageCode;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin='
        '${origin.latitude},${origin.longitude}&destination='
        '${destination.latitude},${destination.longitude}&key=${Config.googleMapsApiKey}&language=$language';

    try {
      final response = await http.get(Uri.parse(url)); // Fetch directions
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

          // Update the marker info with the extracted data
          if (markerInfoMap.containsKey(markerId)) {
            markerInfoMap[markerId] = MarkerInfo(
              isParking: markerInfoMap[markerId]!.isParking,
              id: markerInfoMap[markerId]!.id,
              model: markerInfoMap[markerId]!.model,
              isAvailable: markerInfoMap[markerId]!.isAvailable,
              vehicle: markerInfoMap[markerId]!.vehicle,
              isDestination: true,
              distance: distance,
              duration: duration,
              steps: steps,
            );
          }

          addPolyline(points); // Draw the polyline on the map

          // Show a SnackBar notification for the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Route found! Distance: $distance, Duration: $duration'),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Show a SnackBar notification if no routes are found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No routes found. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Handle the error response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch route. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
