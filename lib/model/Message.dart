class Message {
  final String messageId;  // ID of the message
  final String userId;     // ID of the user who sent the message
  final String message;    // The message content
  final DateTime timestamp;  // Timestamp for when the message was sent
  final String? status;    // Optional: Message status (e.g., 'read', 'unread')

  Message({
    required this.messageId,
    required this.userId,
    required this.message,
    required this.timestamp,
    this.status,
  });

  // Factory constructor to create a Message object from a Map (e.g., from Firebase)
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] ?? '',
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      status: map['status'] ?? '',
    );
  }

  // Convert the Message object back to a Map for sending to Firebase
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'userId': userId,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status,
    };
  }
}
