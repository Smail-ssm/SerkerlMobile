class DeviceInfo {
  String id; // Unique identifier for the device
  String uid; // IMEI for mobile devices, serial number for others
  double mileage; // Mileage of the device
  String lastSignal; // Last signal received
  String serialNumber; // Serial number of the device
  String firmwareVersion; // Firmware version of the device

  DeviceInfo({
    required this.id,
    required this.uid,
    required this.mileage,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.lastSignal,
  });

  // Factory constructor for creating a DeviceInfo from a JSON object
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'],
      uid: json['uid'],
      mileage: json['mileage'].toDouble(),
      serialNumber: json['serialNumber'],
      firmwareVersion: json['firmwareVersion'],
      lastSignal: json['lastSignal'],
    );
  }

  // Method for converting a DeviceInfo instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'mileage': mileage,
      'serialNumber': serialNumber,
      'firmwareVersion': firmwareVersion,
      'lastSignal': lastSignal,
    };
  }
}
