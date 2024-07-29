import 'dart:convert';

class NotificationItem {
  final String title;
  final String message;
  final DateTime date;

  NotificationItem(
      {required this.title, required this.message, required this.date});

  factory NotificationItem.fromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    return NotificationItem(
      title: data['title'],
      message: data['message'],
      date: DateTime.parse(data['date']),
    );
  }

  String toJson() {
    return jsonEncode({
      'title': title,
      'message': message,
      'date': date.toString(),
    });
  }
}
