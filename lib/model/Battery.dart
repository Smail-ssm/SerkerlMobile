class Battery {
  String id; // Example: ID of the battery
  int vehicleId; // ID of the vehicle associated with this battery
  String type; // Type of the battery (e.g., Lithium-ion, Lead-acid)
  double capacity; // Capacity of the battery in Ah or kWh
  String manufacturer; // Manufacturer of the battery
  String level; // Manufacturer of the battery

  Battery({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.capacity,
    required this.manufacturer,
    required this.level,
  });

  // Factory constructor for creating a Battery from a JSON object
  factory Battery.fromJson(Map<String, dynamic> json) {
    return Battery(
      id: json['id'],
      vehicleId: json['vehicleId'],
      type: json['type'],
      capacity: json['capacity'].toDouble(),
      manufacturer: json['manufacturer'],
      level: json['level'],
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
    };
  }
}
