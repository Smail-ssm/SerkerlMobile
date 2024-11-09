import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../model/client.dart';
import '../util/util.dart';

class JuicerCommunicationPage extends StatefulWidget {
  final Client client;
  final String sessionId;

  const JuicerCommunicationPage({Key? key, required this.client, required this.sessionId}) : super(key: key);

  @override
  _JuicerCommunicationPageState createState() => _JuicerCommunicationPageState();
}

class _JuicerCommunicationPageState extends State<JuicerCommunicationPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String env = getFirestoreDocument();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      try {
        print('Attempting to send message: ${_messageController.text.trim()}');
        await _database
            .child(env)
            .child('chats')
            .child(widget.client.fullName)
            .child('sessions')
            .child(widget.sessionId)
            .child('messages')
            .push()
            .set({
          'senderId': widget.client.userId,
          'message': _messageController.text.trim(),
          'timestamp': ServerValue.timestamp,
        });
        print('Message sent successfully');
        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('Message is empty, not sending');
    }
  }

  Query _getMessages() {
    print('Fetching messages for session: ${widget.sessionId}');
    return _database
        .child(env)
        .child('chats')
        .child(widget.client.fullName)
        .child('sessions')
        .child(widget.sessionId)
        .child('messages')
        .orderByChild('timestamp');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication with Admin'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _getMessages().onValue,
              builder: (context, snapshot) {
                print('StreamBuilder: Connection state is ${snapshot.connectionState}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print('Waiting for messages to load');
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  print('No messages available');
                  return const Center(child: Text('No messages available.'));
                }
                print('Messages received');
                final messagesMap = Map<String, dynamic>.from(
                    (snapshot.data!.snapshot.value as Map<Object?, Object?>).cast<String, dynamic>());
                final messages = messagesMap.values.toList()
                  ..sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
                print('Total messages fetched: ${messages.length}');
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = Map<String, dynamic>.from(messages[index] as Map);
                    bool isSentByUser = message['senderId'] == widget.client.userId;
                    String formattedTime = message['timestamp'] != null
                        ? DateFormat('hh:mm a').format(
                        DateTime.fromMillisecondsSinceEpoch(message['timestamp']))
                        : 'Unknown time';
                    print('Rendering message: ${message['message']}, Sent by user: $isSentByUser');
                    return Align(
                      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSentByUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'] ?? '',
                              style: TextStyle(
                                  color: isSentByUser ? Colors.white : Colors.black),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Sent at $formattedTime',
                              style: TextStyle(
                                  color: isSentByUser ? Colors.white70 : Colors.black54,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    print('Send button pressed');
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
