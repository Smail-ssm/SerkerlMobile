class Rental {
  String id; // Unique identifier for the rental
  String vId; // Reference to the rented Vehicle object
  String? startTime; // Rental start time (nullable)
  String? expectedReturnTime; // Expected return time (nullable)
  double baseRate; // Per unit rate (e.g., per hour)
  double unlockPrice; // Price to unlock the vehicle
  double pausePrice; // Optional price for pausing the rental
  String? user; // Reference to the User object (optional)
  String notes; // User-provided notes (optional)

  Rental({
    required this.id,
    required this.vId,
    this.startTime, // Nullable
    this.expectedReturnTime, // Nullable
    required this.baseRate,
    required this.unlockPrice,
    required this.pausePrice,
    this.user,
    required this.notes,
  });

  // Factory constructor for creating a Rental from a JSON object
  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] as String,
      vId: json['vId'] as String,
      startTime: json['startTime'] as String?,
      expectedReturnTime: json['expectedReturnTime'] as String?,
      baseRate: (json['baseRate'] as num).toDouble(),
      unlockPrice: (json['unlockPrice'] as num).toDouble(),
      pausePrice: (json['pausePrice'] as num).toDouble(),
      user: json['user'] as String?,
      notes: json['notes'] as String,
    );
  }

  // Method for converting a Rental instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vId': vId,
      'startTime': startTime,
      'expectedReturnTime': expectedReturnTime,
      'baseRate': baseRate,
      'unlockPrice': unlockPrice,
      'pausePrice': pausePrice,
      'user': user,
      'notes': notes+ "\n",
    };
  }
}
