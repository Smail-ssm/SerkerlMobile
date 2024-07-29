class Rental {
  String id; // Unique identifier for the rental
  String vId; // Reference to the rented Vehicle object
  DateTime startTime; // Rental start time
  DateTime expectedReturnTime; // Expected return time
  double baseRate; // Per unit rate (e.g., per hour)
  double unlockPrice; // Price to unlock the vehicle
  double pausePrice; // Optional price for pausing the rental
  String? user; // Reference to the User object (optional)
  String? notes; // User-provided notes (optional)

  Rental({
    required this.id,
    required this.vId,
    required this.startTime,
    required this.expectedReturnTime,
    required this.baseRate,
    required this.unlockPrice,
    required this.pausePrice,
    this.user,
    this.notes,
  });

  // Factory constructor for creating a Rental from a JSON object
  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      vId: json['vId'],
      startTime: DateTime.parse(json['startTime']),
      expectedReturnTime: DateTime.parse(json['expectedReturnTime']),
      baseRate: json['baseRate'].toDouble(),
      unlockPrice: json['unlockPrice'].toDouble(),
      pausePrice: json['pausePrice'].toDouble(),
      user: json['user'],
      notes: json['notes'],
    );
  }

  // Method for converting a Rental instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vId': vId,
      'startTime': startTime.toIso8601String(),
      'expectedReturnTime': expectedReturnTime.toIso8601String(),
      'baseRate': baseRate,
      'unlockPrice': unlockPrice,
      'pausePrice': pausePrice,
      'user': user,
      'notes': notes,
    };
  }
}
