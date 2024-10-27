import 'Battery.dart';
import 'DeviceInfo.dart';
import 'MaintenanceLog.dart';
import 'rental.dart';

class Vehicle {
  String id;
  String model;
  Battery battery;
  bool isAvailable;
  double? latitude;
  double? longitude;
  Rental? rental;
  DeviceInfo? deviceInfo;
  int? speed;
  int? temperature;
  int? acceleration;
  DateTime? nextMaintenanceDate;
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
      id: json['id'] as String,
      model: json['model'] as String,
      battery: Battery.fromJson(json['battery'] as Map<String, dynamic>),
      isAvailable: json['isAvailable'] as bool,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rental: json['rental'] is Map<String, dynamic>
          ? Rental.fromJson(json['rental'])
          : null,
      deviceInfo: json['deviceInfo'] is Map<String, dynamic>
          ? DeviceInfo.fromJson(json['deviceInfo'])
          : null,
      speed: json['speed'] as int?,
      temperature: json['temperature'] as int?,
      acceleration: json['acceleration'] as int?,
      nextMaintenanceDate: json['nextMaintenanceDate'] != null
          ? DateTime.parse(json['nextMaintenanceDate'])
          : null,
      maintenanceLog: json['maintenanceLog'] != null && json['maintenanceLog'] is List
          ? (json['maintenanceLog'] as List)
          .map((log) => MaintenanceLog.fromJson(log as Map<String, dynamic>))
          .toList()
          : [], // Default to an empty list if maintenanceLog is null
      user: json['user'] as String?,
      qrcode: json['qrcode'] as String?,
    );
  }

  // Method for converting a Vehicle instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'battery': battery.toJson(),
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
