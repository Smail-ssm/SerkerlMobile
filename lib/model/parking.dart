import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parking {
  String id;
  String name;
  String address;
  String supervisor;
  int maxCapacity;
  int currentCapacity;
  bool isOpen;
  String openingTime;
  String closingTime;
  LatLng coordinates; // Single point location for parking
  Timestamp createdAt; // Optional timestamp for created date

  Parking({
    required this.id,
    required this.name,
    required this.address,
    required this.supervisor,
    required this.maxCapacity,
    required this.currentCapacity,
    required this.isOpen,
    required this.openingTime,
    required this.closingTime,
    required this.coordinates,
    required this.createdAt,
  });

  // Factory constructor for creating a Parking from a JSON object
  factory Parking.fromJson(Map<String, dynamic> json) {
    List<dynamic>? coordinatesData = json['coordinates']; // Get the 'coordinates' array from the JSON

    LatLng coordinates = LatLng(0.0, 0.0); // Default coordinates

    // Check if the 'coordinates' array exists and has the correct structure
    if (coordinatesData != null && coordinatesData.isNotEmpty) {
      var firstCoordinate = coordinatesData[0];
      if (firstCoordinate != null && firstCoordinate['lat'] != null && firstCoordinate['lng'] != null) {
        coordinates = LatLng(firstCoordinate['lat'], firstCoordinate['lng']); // Extract the lat/lng
      }
    }

    return Parking(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Parking',
      address: json['address'] ?? 'Unknown address',
      supervisor: json['supervisor'] ?? 'Unknown supervisor',
      maxCapacity: json['maxCapacity'] ?? 0,
      currentCapacity: json['currentCapacity'] ?? 0,
      isOpen: json['isOpen'] is bool
          ? json['isOpen']
          : (json['isOpen'].toString().toLowerCase() == 'true'), // Convert string to bool
      openingTime: json['openingTime'] ?? '00:00',
      closingTime: json['closingTime'] ?? '00:00',
      coordinates: coordinates, // Set the parsed coordinates here
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method for converting a Parking instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'supervisor': supervisor,
      'maxCapacity': maxCapacity,
      'currentCapacity': currentCapacity,
      'isOpen': isOpen,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'coordinates': {
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
      },
      'createdAt': createdAt,
    };
  }
}
