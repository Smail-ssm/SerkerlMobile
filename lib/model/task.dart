import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String vehicleId;
  final String vehicleModel;
  final String status;
  final String address;
  final DateTime createdAt;
  final String taskType;
  final double batteryLevel;
  final double latitude;
  final double longitude;
  final String? assignedTo;
  final String? assignedToName;

  Task({
    required this.id,
    required this.vehicleId,
    required this.address,
    required this.vehicleModel,
    required this.status,
    required this.createdAt,
    required this.taskType,
    required this.batteryLevel,
    required this.latitude,
    required this.longitude,
    this.assignedTo,
    this.assignedToName,
  });

  // Factory method to create a Task object from Firestore data
  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['id'] as String,
      address: data['address'] as String,
      vehicleId: data['vehicleId'] as String,
      vehicleModel: data['vehicleModel'] as String,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      taskType: data['taskType'] as String,
      batteryLevel: (data['batteryLevel'] as num).toDouble(),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      assignedTo: data['assignedTo'] as String?,
      assignedToName: data['assignedToName'] as String?,
    );
  }
}
