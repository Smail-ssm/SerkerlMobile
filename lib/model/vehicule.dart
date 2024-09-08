import 'Battery.dart';
import 'DeviceInfo.dart';
import 'MaintenanceLog.dart';
import 'rental.dart';

class Vehicle {
  String id; // Unique identifier for the vehicle
  String model; // Model of the vehicle
  Battery battery; // Battery ID or percentage
  bool isAvailable; // Availability status of the vehicle
  double? latitude; // Latitude of the vehicle's location (optional)
  double? longitude; // Longitude of the vehicle's location (optional)
  Rental? rental; // Current rental information (optional)
  DeviceInfo? deviceInfo; // Device information (optional)
  int? speed; // Current speed (optional)
  int? temperature; // Internal temperature (optional)
  int? acceleration; // Current acceleration (optional)
  DateTime? nextMaintenanceDate; // Scheduled maintenance date (optional)
  List<MaintenanceLog>? maintenanceLog; // Maintenance logs (optional)
  String? user; // User associated with the vehicle (optional)
  String? qrcode; // QR code associated with the vehicle (optional)

  Vehicle({
    required this.id,
    required this.model,
    required this.battery,
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
      battery: Battery.fromJson(json['battery']),
      isAvailable: json['isAvailable'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      rental: json['rental'] is Map<String, dynamic>
          ? Rental.fromJson(json['rental'])
          : null,
      deviceInfo: json['deviceInfo'] is Map<String, dynamic>
          ? DeviceInfo.fromJson(json['deviceInfo'])
          : null,
      speed: json['speed']as int,
      temperature: json['temperature'] ,
      acceleration: json['acceleration'] ,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'])
          : null,
      maintenanceLog: json['maintenanceLog']is Map<String, dynamic>
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
      'batteryID': battery,
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
