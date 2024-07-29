import 'DeviceInfo.dart';
import 'MaintenanceLog.dart';

import 'rental.dart'; // Import the Rental class
// Import the Model class

class Vehicle {
  String id; // Unique identifier for the vehicle
  String model; // Model of the vehicle
  int batteryID; // Battery ID or percentage
  bool isAvailable; // Availability status of the vehicle
  double? latitude; // Latitude of the vehicle's location (optional)
  double? longitude; // Longitude of the vehicle's location (optional)
  Rental? rental; // Current rental information (optional)
  DeviceInfo? deviceInfo; // Device information (optional)
  double? speed; // Current speed (optional)
  double? temperature; // Internal temperature (optional)
  double? acceleration; // Current acceleration (optional)
  DateTime? nextMaintenanceDate; // Scheduled maintenance date (optional)
  List<MaintenanceLog>? maintenanceLog; // Maintenance logs (optional)
  String? user; // User associated with the vehicle (optional)
  String? qrcode; // QR code associated with the vehicle (optional)

  Vehicle({
    required this.id,
    required this.model,
    required this.batteryID,
    required this.isAvailable,
    this.latitude,
    this.longitude,
    this.rental,
    this.deviceInfo,
    this.speed,
    this.temperature,
    this.acceleration,
    this.nextMaintenanceDate,
    this.maintenanceLog,
    this.user,
    this.qrcode,
  });

  // Factory constructor for creating a Vehicle from a JSON object
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      model: json['model'],
      batteryID: json['batteryID'],
      isAvailable: json['isAvailable'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      rental: json['rental'] != null ? Rental.fromJson(json['rental']) : null,
      deviceInfo: json['deviceInfo'] != null
          ? DeviceInfo.fromJson(json['deviceInfo'])
          : null,
      speed: json['speed']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      acceleration: json['acceleration']?.toDouble(),
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'])
          : null,
      maintenanceLog: json['maintenanceLog'] != null
          ? (json['maintenanceLog'] as List)
              .map((log) => MaintenanceLog.fromJson(log))
              .toList()
          : null,
      user: json['user'],
      qrcode: json['qrcode'],
    );
  }

  // Method for converting a Vehicle instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'batteryID': batteryID,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
      'rental': rental?.toJson(),
      'deviceInfo': deviceInfo?.toJson(),
      'speed': speed,
      'temperature': temperature,
      'acceleration': acceleration,
      'nextMaintenanceDate': nextMaintenanceDate?.toIso8601String(),
      'maintenanceLog': maintenanceLog?.map((log) => log.toJson()).toList(),
      'user': user,
      'qrcode': qrcode,
    };
  }
}
