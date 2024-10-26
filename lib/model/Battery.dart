class Battery {
  String id;
  int vehicleId;
  String type;
  double capacity;
  String manufacturer;
  double level;
  String status; // New field to track battery status (In Use, Charging, Pending Charge, Charged)

  Battery({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.capacity,
    required this.manufacturer,
    required this.level,
    required this.status, // New required parameter for status
  });

  // Factory constructor for creating a Battery from a JSON object
  factory Battery.fromJson(Map<String, dynamic> json) {
    return Battery(
      id: json['id'] ?? '',
      vehicleId: json['vehicleId'] ?? 0,
      type: json['type'] ?? '',
      capacity: (json['capacity'] is double)
          ? json['capacity']
          : double.tryParse(json['capacity'].toString()) ?? 0.0,      manufacturer: json['manufacturer'] ?? '',
      level: (json['level'] is double)
          ? json['level']
          : double.tryParse(json['level'].toString()) ?? 0.0,      status: json['status'] ?? 'Pending Charge', // Default status
    );
  }


  // Method for converting a Battery instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'type': type,
      'capacity': capacity,
      'manufacturer': manufacturer,
      'level': level,
      'status': status,
    };
  }
}
