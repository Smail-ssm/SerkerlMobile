import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../model/client.dart';
import '../util/util.dart';
import 'CommunicationPage.dart';

class SessionListPage extends StatefulWidget {
  final Client client;

  SessionListPage({required this.client});

  @override
  _SessionListPageState createState() => _SessionListPageState();
}

class _SessionListPageState extends State<SessionListPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String env = getFirestoreDocument();
  final TextEditingController _sessionSubjectController = TextEditingController();

  Query _getSessions() {
    print('Fetching sessions for client: ${widget.client.fullName}');
    return _database.child(env).child('chats').child(widget.client.fullName).child('sessions').orderByChild('isHidden').equalTo(false);
  }

  void _createNewSession() async {
    if (_sessionSubjectController.text.trim().isNotEmpty) {
      final String newSessionId = const Uuid().v4();
      await _database
          .child(env)
          .child('chats')
          .child(widget.client.fullName)
          .child('sessions')
          .child(newSessionId)
          .set({
        'subject': _sessionSubjectController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'isHidden': false,
      });
      Navigator.of(context).pop();
      _sessionSubjectController.clear();
    }
  }

  void _hideSession(String sessionId) async {
    await _database
        .child(env)
        .child('chats')
        .child(widget.client.fullName)
        .child('sessions')
        .child(sessionId)
        .update({'isHidden': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Sessions'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _getSessions().onValue,
        builder: (context, snapshot) {
          print('StreamBuilder: Connection state is ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for sessions to load');
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            print('No sessions available');
            return const Center(child: Text('No sessions available.'));
          }
          print('Sessions received');
          final sessionsMap = Map<String, dynamic>.from(
              (snapshot.data!.snapshot.value as Map<Object?, Object?>).cast<String, dynamic>());
          final sessions = sessionsMap.entries.toList();
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final sessionId = sessions[index].key;
              final sessionData = Map<String, dynamic>.from(sessions[index].value);
              print('Rendering session: $sessionId');
              return Dismissible(
                key: Key(sessionId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  _hideSession(sessionId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Session hidden')),
                  );
                },
                child: ListTile(
                  title: Text('Subject: ${sessionData['subject'] ?? 'No Subject'}'),
                  subtitle: Text('Created at: ${sessionData['createdAt'] ?? 'Unknown date'}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JuicerCommunicationPage(client: widget.client, sessionId: sessionId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('New Session'),
              content: TextField(
                controller: _sessionSubjectController,
                decoration: const InputDecoration(
                  hintText: 'Enter session subject',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: _createNewSession,
                  child: const Text('Create'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
