import 'package:intl/intl.dart'; // Add this import if you want to handle date formatting

class Setting {
  String id; // Unique identifier for the setting
  String name; // Name of the setting
  dynamic value; // Value of the setting, can be string, number, boolean, date, or time
  SettingType type; // Type of the setting

  Setting({
    required this.id,
    required this.name,
    required this.value,
    required this.type,
  });

  // Factory constructor for creating a Setting from a JSON object
  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['id'],
      name: json['name'],
      value: _parseValue(json['value'], json['type']),
      type: SettingType.values.firstWhere((e) => e.toString() == 'SettingType.${json['type']}'),
    );
  }

  // Method for converting a Setting instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': _serializeValue(value, type),
      'type': type.toString().split('.').last,
    };
  }

  // Helper method to parse the value based on type
  static dynamic _parseValue(dynamic value, String type) {
    switch (type) {
      case 'string':
        return value as String;
      case 'number':
        return value is int || value is double ? value.toDouble() : double.parse(value.toString());
      case 'boolean':
        return value is bool ? value : value.toLowerCase() == 'true';
      case 'date':
        return DateTime.parse(value);
      case 'time':
      // Assuming time is in HH:mm:ss format
        return DateFormat('HH:mm:ss').parse(value).toLocal();
      default:
        throw ArgumentError('Invalid type');
    }
  }

  // Helper method to serialize the value based on type
  static dynamic _serializeValue(dynamic value, SettingType type) {
    switch (type) {
      case SettingType.string:
        return value as String;
      case SettingType.number:
        return value is double ? value : double.parse(value.toString());
      case SettingType.boolean:
        return value as bool;
      case SettingType.date:
        return (value as DateTime).toIso8601String();
      case SettingType.time:
        return DateFormat('HH:mm:ss').format(value as DateTime);
      default:
        throw ArgumentError('Invalid type');
    }
  }
}

enum SettingType { string, number, boolean, date, time }
