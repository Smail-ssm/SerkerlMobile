class DeviceInfo {
  // Unique identifier for the device (consider using a globally unique identifier (GUID) or UUID)
  final String id;

  // Device properties relevant to ebikes
  final String uid; // Imei for mobile devices, serial number for others
  final double mileage; // In kilometers or appropriate unit
  final DateTime? lastSignal; // Optional last signal time

  DeviceInfo({
    required this.id,
    required this.uid,
    required this.mileage,
    this.lastSignal,
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
    return {
      'id': id,
      'uid': uid,
      'mileage': mileage,
      'lastSignal': lastSignal?.toIso8601String(), // Handle optional lastSignal
    };
  }
}
