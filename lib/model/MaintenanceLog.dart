class MaintenanceLog {
  String id; // Unique identifier for the maintenance record
  DateTime date; // Date and time of the maintenance
  String description; // Description of the maintenance performed

  MaintenanceLog({
    required this.id,
    required this.date,
    required this.description,
  });

  // Factory constructor for creating a MaintenanceLog from a JSON object
  factory MaintenanceLog.fromJson(Map<String, dynamic> json) {
    return MaintenanceLog(
      id: json['id'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  // Method for converting a MaintenanceLog instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(), // Convert date to ISO string
      'description': description,
    };
  }
}
