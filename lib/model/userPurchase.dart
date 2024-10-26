import 'subscription.dart'; // Import the Subscription class

class UserPurchase {
  String id; // Unique identifier for the user purchase
  DateTime validFrom; // Start date of the purchase validity
  DateTime validTill; // End date of the purchase validity
  Subscription subscription; // The associated subscription
  String status; // Status of the purchase
  String client; // Name of the client
  String phone; // Phone number of the client
  int unlocksCount; // Number of unlocks available
  int rideMinutes; // Number of ride minutes available
  int pauseMinutes; // Number of pause minutes available
  double rideDistance; // Distance available in the purchase

  UserPurchase({
    required this.id,
    required this.validFrom,
    required this.validTill,
    required this.subscription,
    required this.status,
    required this.client,
    required this.phone,
    required this.unlocksCount,
    required this.rideMinutes,
    required this.pauseMinutes,
    required this.rideDistance,
  });

  // Factory constructor for creating a UserPurchase from a JSON object
  factory UserPurchase.fromJson(Map<String, dynamic> json) {
    return UserPurchase(
      id: json['id'],
      validFrom: DateTime.parse(json['validFrom']),
      validTill: DateTime.parse(json['validTill']),
      subscription: Subscription.fromJson(json['subscription']),
      status: json['status'],
      client: json['client'],
      phone: json['phone'],
      unlocksCount: json['unlocksCount'],
      rideMinutes: json['rideMinutes'],
      pauseMinutes: json['pauseMinutes'],
      rideDistance: json['rideDistance'].toDouble(),
    );
  }

  // Method for converting a UserPurchase instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'validFrom': validFrom.toIso8601String(),
      'validTill': validTill.toIso8601String(),
      'subscription': subscription.toJson(),
      'status': status,
      'client': client,
      'phone': phone,
      'unlocksCount': unlocksCount,
      'rideMinutes': rideMinutes,
      'pauseMinutes': pauseMinutes,
      'rideDistance': rideDistance,
    };
  }

}
