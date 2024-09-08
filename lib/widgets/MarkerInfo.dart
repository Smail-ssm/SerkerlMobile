import 'package:ebike/model/vehicule.dart';

import '../model/parking.dart';

class MarkerInfo {
  final String id;
  final String model;
  final bool isAvailable;
  final Vehicle? vehicle;
  final bool isParking; // The associated parking, if it's a parking marker
  final Parking? parking; // The associated parking, if it's a parking marker

  final bool isDestination;
  final String? distance;       // Added field for distance
  final String? duration;       // Added field for duration
  final List<String>? steps;    // Added field for turn-by-turn steps

  MarkerInfo({
    required this.id,
    required this.model,
    required this.isAvailable,
    required this.isParking,
    this.vehicle,
    this.parking,
    required this.isDestination,
    this.distance,
    this.duration,
    this.steps,
  });
}
