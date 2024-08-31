class Model {
  String id; // Unique identifier for the model
  String name; // Name of the model
  String area; // Area or category of the model
  String description; // Description of the model
  String manufacturer; // Manufacturer of the model
  String type; // Manufacturer of the model
  int year; // Year of manufacture

  Model({
    required this.id,
    required this.type,
    required this.name,
    required this.area,
    required this.description,
    required this.manufacturer,
    required this.year,
  });

  // Factory constructor for creating a Model from a JSON object
  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'],
      name: json['name'],
      area: json['area'],
      description: json['description'],
      manufacturer: json['manufacturer'],
      year: json['year'],
      type: json['type'],
    );
  }

  // Method for converting a Model instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'description': description,
      'manufacturer': manufacturer,
      'year': year,
      'type': type,
    };
  }
}
