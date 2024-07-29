class Subscription {
  String id; // Unique identifier for the subscription
  String title; // Title of the subscription
  String company; // Company offering the subscription
  bool activated; // Whether the subscription is activated
  int validDays; // Number of days the subscription is valid
  double price; // Price of the subscription
  int unlocksCount; // Number of unlocks allowed
  int rideMinutes; // Number of ride minutes allowed
  int pauseMinutes; // Number of pause minutes allowed
  double rideDistance; // Distance covered by the subscription

  Subscription({
    required this.id,
    required this.title,
    required this.company,
    required this.activated,
    required this.validDays,
    required this.price,
    required this.unlocksCount,
    required this.rideMinutes,
    required this.pauseMinutes,
    required this.rideDistance,
  });

  // Factory constructor for creating a Subscription from a JSON object
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      title: json['title'],
      company: json['company'],
      activated: json['activated'],
      validDays: json['validDays'],
      price: json['price'].toDouble(),
      unlocksCount: json['unlocksCount'],
      rideMinutes: json['rideMinutes'],
      pauseMinutes: json['pauseMinutes'],
      rideDistance: json['rideDistance'].toDouble(),
    );
  }

  // Method for converting a Subscription instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'activated': activated,
      'validDays': validDays,
      'price': price,
      'unlocksCount': unlocksCount,
      'rideMinutes': rideMinutes,
      'pauseMinutes': pauseMinutes,
      'rideDistance': rideDistance,
    };
  }
}
