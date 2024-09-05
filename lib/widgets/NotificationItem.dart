import 'dart:convert';

class NotificationItem {
  final int? id; // SQLite ID field
  final String title;
  final String message;
  final DateTime date;

  NotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.date,
  });

  // Convert a JSON object to a NotificationItem
  factory NotificationItem.fromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    return NotificationItem(
      id: data['id'],
      title: data['title'],
      message: data['message'],
      date: DateTime.parse(data['date']),
    );
  }

  // Convert a NotificationItem to a JSON object
  String toJson() {
    return jsonEncode({
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(), // Use ISO 8601 for date formatting
    });
  }

  // Convert a NotificationItem to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'date': date.toIso8601String(),
    };
  }

  // Create a NotificationItem from a Map (SQLite row)
  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      date: DateTime.parse(map['date']),
    );
  }
}
