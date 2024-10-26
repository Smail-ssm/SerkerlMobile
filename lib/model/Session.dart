import 'Message.dart';

class Session {
  final String sessionId;  // ID of the session
  final String userId;     // ID of the user to whom the session belongs
  final DateTime? createdAt;  // Optional: Timestamp for when the session was created
  final String? status;    // Optional: Status of the session (e.g., 'active', 'closed')
  final List<Message> messages;  // List of messages in the session

  Session({
    required this.sessionId,
    required this.userId,
    this.createdAt,
    this.status,
    required this.messages,
  });

  // Factory constructor to create a Session object from a Map (e.g., from Firebase)
  factory Session.fromMap(Map<String, dynamic> map, String sessionId) {
    var messages = <Message>[];
    if (map['messages'] != null) {
      messages = (map['messages'] as Map<dynamic, dynamic>)
          .values
          .map((message) => Message.fromMap(Map<String, dynamic>.from(message)))
          .toList();
    }
    return Session(
      sessionId: sessionId,
      userId: map['userId'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) : null,
      status: map['status'] ?? '',
      messages: messages,
    );
  }

  // Convert the Session object back to a Map for sending to Firebase
  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'status': status,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }
}
