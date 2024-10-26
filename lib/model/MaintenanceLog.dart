class MaintenanceLog {
  String id;
  String vehicleId;
  DateTime date;
  String technicianName;
  String type; // E.g., General, Battery, Brakes, etc.
  double cost;

  // Individual checks
  bool batteryCheck;
  bool brakesCheck;
  bool lightsCheck;
  bool tireCheck;
  bool componentCleaning;
  bool chainLubrication;
  bool boltTightening;
  bool brakeInspection;
  bool batteryHealthCheck;
  bool drivetrainCheck;
  bool wheelAlignmentCheck;

  // Additional notes or observations
  String notes;

  MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.technicianName,
    required this.type,
    required this.cost,
    this.batteryCheck = false,
    this.brakesCheck = false,
    this.lightsCheck = false,
    this.tireCheck = false,
    this.componentCleaning = false,
    this.chainLubrication = false,
    this.boltTightening = false,
    this.brakeInspection = false,
    this.batteryHealthCheck = false,
    this.drivetrainCheck = false,
    this.wheelAlignmentCheck = false,
    this.notes = '',
  });

  // Factory method to create a log from JSON data
  factory MaintenanceLog.fromJson(Map<String, dynamic> json) {
    return MaintenanceLog(
      id: json['id'],
      vehicleId: json['vehicleId'],
      date: DateTime.parse(json['date']),
      technicianName: json['technicianName'],
      type: json['type'],
      cost: json['cost'],
      batteryCheck: json['batteryCheck'] ?? false,
      brakesCheck: json['brakesCheck'] ?? false,
      lightsCheck: json['lightsCheck'] ?? false,
      tireCheck: json['tireCheck'] ?? false,
      componentCleaning: json['componentCleaning'] ?? false,
      chainLubrication: json['chainLubrication'] ?? false,
      boltTightening: json['boltTightening'] ?? false,
      brakeInspection: json['brakeInspection'] ?? false,
      batteryHealthCheck: json['batteryHealthCheck'] ?? false,
      drivetrainCheck: json['drivetrainCheck'] ?? false,
      wheelAlignmentCheck: json['wheelAlignmentCheck'] ?? false,
      notes: json['notes'] ?? '',
    );
  }

  // Method to convert the log to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'technicianName': technicianName,
      'type': type,
      'cost': cost,
      'batteryCheck': batteryCheck,
      'brakesCheck': brakesCheck,
      'lightsCheck': lightsCheck,
      'tireCheck': tireCheck,
      'componentCleaning': componentCleaning,
      'chainLubrication': chainLubrication,
      'boltTightening': boltTightening,
      'brakeInspection': brakeInspection,
      'batteryHealthCheck': batteryHealthCheck,
      'drivetrainCheck': drivetrainCheck,
      'wheelAlignmentCheck': wheelAlignmentCheck,
      'notes': notes,
    };
  }
}
