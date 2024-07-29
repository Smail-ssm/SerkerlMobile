import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Area {
  String id;
  String name;
  String description;
  Polygon polygon;
  String color;
  List<LatLng> coordinates;
  Timestamp  createdAt; // Optional timestamp for created date

  Area({
    required this.id,
    required this.name,
    required this.description,
    required this.polygon,
    required this.color,
    required this.coordinates,
    required this.createdAt,
  });

  // Factory constructor for creating an Area from a JSON object
  factory Area.fromJson(Map<String, dynamic> json) {
    List<LatLng> coordinates = (json['coordinates'] as List)
        .map((coord) => LatLng(coord['lat'], coord['lng']))
        .toList();

    return Area(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      polygon: Polygon(
        polygonId: PolygonId(json['id']),
        points: coordinates,
        strokeColor: Color(int.parse(json['color'].substring(1, 7), radix: 16) + 0xFF000000),
        fillColor: Color(int.parse(json['color'].substring(1, 7), radix: 16) + 0x33000000),
        strokeWidth: 3,
      ),
      color: json['color'],
      coordinates: coordinates,
      createdAt:    json['createdAt']   ,
    );
  }

  // Method for converting an Area instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'polygon': {
        'polygonId': polygon.polygonId.value,
        'points': polygon.points.map((point) => {
          'lat': point.latitude,
          'lng': point.longitude,
        }).toList(),
        'strokeColor': polygon.strokeColor.value.toRadixString(16),
        'fillColor': polygon.fillColor.value.toRadixString(16),
        'strokeWidth': polygon.strokeWidth,
      },
      'color': color,
      'coordinates': coordinates.map((coord) => {'lat': coord.latitude, 'lng': coord.longitude}).toList(),
      'createdAt': createdAt ,
    };
  }
}
