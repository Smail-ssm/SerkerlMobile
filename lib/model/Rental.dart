class Rental {
  // Unique identifier for the rental
  final String id;

  // Reference to the rented Vehicle object
  final String vId;

  // Rental start and expected return times (consider using DateTime)
  final DateTime startTime;
  final DateTime expectedReturnTime;

  // Rental cost details
  final double baseRate; // Per unit (e.g., per hour)
  final double unlockPrice;
  final double pausePrice; // Optional, if applicable to your system

  // Additional information (optional)
  final String? user; // Reference to the User object (if applicable)
  final String? notes; // User-provided notes (optional)

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

  // Example method to calculate estimated rental cost based on current time
  double calculateEstimatedCost(DateTime currentTime) {
    final duration = currentTime.difference(startTime);
    final hours = duration.inHours.toDouble();
    return baseRate * hours + unlockPrice + (pausePrice * 1);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vId, // Reference the vehicle's ID
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
