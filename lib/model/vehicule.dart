import 'MaintenanceLog.dart';
import 'Rental.dart';

class Vehicle {
  // Unique identifier for the ebike
  final String id;

  // Ebike properties
  final String model;
  final double batteryLevel; // Percentage (0.0 to 1.0)
  final bool isAvailable;

  // Optional location information (consider using a separate class for flexibility)
  final double latitude;
  final double longitude;

  // Reference to a Rental object, if rented (null if available)
  final Rental? rental;

  // Related device information (consider using a separate class or nested object)
  final String uid; // Imei for mobile devices, serial number for others
  final double mileage; // In kilometers or appropriate unit
  final DateTime?
      lastSignal; // Optional last signal time // Or potentially DeviceInfo containing relevant device properties

  // Sensor data (optional)
  final double? speed; // Current speed (e.g., km/h)
  final double? temperature; // Internal temperature (e.g., degrees Celsius)
  final double? acceleration; // Current acceleration (e.g., m/s^2)

  // Maintenance information (optional)
  final DateTime? nextMaintenanceDate; // Scheduled maintenance date
  final List<MaintenanceLog>?
      maintenanceLog; // List of past maintenance records

  // User association (optional)
  final String? user; // Currently associated user (if applicable)

  Vehicle({
    required this.id,
    required this.model,
    required this.batteryLevel,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.rental,
    required this.uid,
    required this.mileage,
    required this.lastSignal,
    required this.speed,
    required this.temperature,
    this.acceleration,
    this.nextMaintenanceDate,
    this.maintenanceLog,
    this.user,
  });

  // Example method to format the last signal time (if available)
  String get formattedLastSignal {
    if (lastSignal != null) {
      return lastSignal!.toIso8601String(); // Or a custom formatting as needed
    } else {
      return 'No signal data available';
    }
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> vehicleMap = {
      'id': id,
      'model': model,
      'batteryLevel': batteryLevel,
      'isAvailable': isAvailable,
      'mileage': mileage,
      'lastSignal': lastSignal,

      // Convert DeviceInfo object to a map
    };

    // Add optional properties with conditional checks
    vehicleMap.addAll({
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rental != null) 'rental': rental!.toMap(),
      // Convert Rental object to a map (if exists)
      if (speed != null) 'speed': speed,
      if (temperature != null) 'temperature': temperature,
      if (acceleration != null) 'acceleration': acceleration,
      if (nextMaintenanceDate != null)
        'nextMaintenanceDate': nextMaintenanceDate!.toIso8601String(),
      if (maintenanceLog != null)
        'maintenanceLog': maintenanceLog!.map((log) => log.toMap()).toList(),
      // Convert MaintenanceLog list to maps
      if (user != null) 'user': user,
      // Convert User object to a map (if exists)
    });

    return vehicleMap;
  }
}
