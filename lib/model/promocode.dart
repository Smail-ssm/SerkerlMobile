class Promocode {
  String? id; // Optional ID field, to be used for updates and deletion
  String code; // The promocode itself
  String assignTo; // Entity or user to whom the promocode is assigned
  int count; // Number of times the promocode can be used
  String entity; // Entity type associated with the promocode
  double bonus; // Bonus value or discount amount
  String status; // Status of the promocode (e.g., 'active', 'inactive')
  DateTime validFrom; // Start date of validity
  DateTime validTo; // End date of validity
  bool activated; // Whether the promocode has been activated or not

  Promocode({
    this.id,
    required this.code,
    required this.assignTo,
    required this.count,
    required this.entity,
    required this.bonus,
    required this.status,
    required this.validFrom,
    required this.validTo,
    required this.activated,
  });

  // Factory constructor for creating a Promocode from a JSON object
  factory Promocode.fromJson(Map<String, dynamic> json) {
    return Promocode(
      id: json['id'],
      code: json['code'],
      assignTo: json['assignTo'],
      count: json['count'],
      entity: json['entity'],
      bonus: json['bonus'].toDouble(),
      status: json['status'],
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      activated: json['activated'],
    );
  }

  // Method for converting a Promocode instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'assignTo': assignTo,
      'count': count,
      'entity': entity,
      'bonus': bonus,
      'status': status,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'activated': activated,
    };
  }
}
