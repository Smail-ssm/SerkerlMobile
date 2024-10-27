class MaintenanceLog {
  String id;
  String vehicleId;
  DateTime date;
  String technicianName;
  String type;
  double cost;

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
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      technicianName: json['technicianName'] as String? ?? '',
      type: json['type'] as String? ?? 'General',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      batteryCheck: json['batteryCheck'] as bool? ?? false,
      brakesCheck: json['brakesCheck'] as bool? ?? false,
      lightsCheck: json['lightsCheck'] as bool? ?? false,
      tireCheck: json['tireCheck'] as bool? ?? false,
      componentCleaning: json['componentCleaning'] as bool? ?? false,
      chainLubrication: json['chainLubrication'] as bool? ?? false,
      boltTightening: json['boltTightening'] as bool? ?? false,
      brakeInspection: json['brakeInspection'] as bool? ?? false,
      batteryHealthCheck: json['batteryHealthCheck'] as bool? ?? false,
      drivetrainCheck: json['drivetrainCheck'] as bool? ?? false,
      wheelAlignmentCheck: json['wheelAlignmentCheck'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
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
