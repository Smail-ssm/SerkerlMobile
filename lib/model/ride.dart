class Ride {
  String rideID; // Unique identifier for the ride
  String userID; // ID of the user who took the ride
  String scooterID; // ID of the scooter used for the ride
  String type; // Type of the ride
  DateTime timeStart; // Start time of the ride
  String distance; // Distance covered during the ride
  String duration; // Duration of the ride
  double cost; // Cost of the ride
  String feedback; // Feedback provided for the ride
  String status; // Status of the ride

  Ride({
    required this.rideID,
    required this.userID,
    required this.scooterID,
    required this.type,
    required this.timeStart,
    required this.distance,
    required this.duration,
    required this.cost,
    required this.feedback,
    required this.status,
  });

  // Factory constructor for creating a Ride from a JSON object
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      rideID: json['rideID'],
      userID: json['userID'],
      scooterID: json['scooterID'],
      type: json['type'],
      timeStart: DateTime.parse(json['timeStart']),
      distance: json['distance'],
      duration: json['duration'],
      cost: json['cost'].toDouble(),
      feedback: json['feedback'],
      status: json['status'],
    );
  }

  // Method for converting a Ride instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'rideID': rideID,
      'userID': userID,
      'scooterID': scooterID,
      'type': type,
      'timeStart': timeStart.toIso8601String(),
      'distance': distance,
      'duration': duration,
      'cost': cost,
      'feedback': feedback,
      'status': status,
    };
  }
}
