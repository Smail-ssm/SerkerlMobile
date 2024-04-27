class MaintenanceLog {
  // Unique identifier for the maintenance record
  final String id;

  // Date and time of the maintenance
  final DateTime date;

  // Description of the maintenance performed
  final String description;

  MaintenanceLog({
    required this.id,
    required this.date,
    required this.description,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
