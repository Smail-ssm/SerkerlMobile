import 'package:ebike/model/vehicule.dart';

class MarkerInfo {
  final String id;
  final String model;
  final bool isAvailable;
  final Vehicle? vehicle; // Nullable vehicle field
  final bool isDestination; // Flag to distinguish destination markers

  MarkerInfo({
    required this.id,
    required this.model,
    required this.isAvailable,
    this.vehicle,
    this.isDestination = false,
  });
}