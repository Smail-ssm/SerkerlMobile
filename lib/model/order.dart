class Order {
  String id; // Unique identifier for the order
  int vehicleId; // ID of the vehicle associated with the order
  String vehicleNo; // Vehicle number
  DateTime startTime; // Start time of the order
  DateTime endTime; // End time of the order
  double duration; // Duration of the order in minutes
  double distance; // Distance traveled in the order (e.g., in kilometers)
  double totalCost; // Total cost of the order
  double paidWithBalance; // Amount paid with balance
  double paidWithSubscription; // Amount paid with subscription
  double discount; // Discount applied to the order
  String rideEndLocation; // Location where the ride ended
  String movementHistory; // History of movements during the ride

  Order({
    required this.id,
    required this.vehicleId,
    required this.vehicleNo,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distance,
    required this.totalCost,
    required this.paidWithBalance,
    required this.paidWithSubscription,
    required this.discount,
    required this.rideEndLocation,
    required this.movementHistory,
  });

  // Factory constructor for creating an Order from a JSON object
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      vehicleId: json['vehicleId'],
      vehicleNo: json['vehicleNo'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: json['duration'].toDouble(),
      distance: json['distance'].toDouble(),
      totalCost: json['totalCost'].toDouble(),
      paidWithBalance: json['paidWithBalance'].toDouble(),
      paidWithSubscription: json['paidWithSubscription'].toDouble(),
      discount: json['discount'].toDouble(),
      rideEndLocation: json['rideEndLocation'],
      movementHistory: json['movementHistory'],
    );
  }

  // Method for converting an Order instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'vehicleNo': vehicleNo,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'duration': duration,
      'distance': distance,
      'totalCost': totalCost,
      'paidWithBalance': paidWithBalance,
      'paidWithSubscription': paidWithSubscription,
      'discount': discount,
      'rideEndLocation': rideEndLocation,
      'movementHistory': movementHistory,
    };
  }
}
