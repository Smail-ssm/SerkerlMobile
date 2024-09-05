import 'package:ebike/model/client.dart';
import 'package:flutter/material.dart';
 import '../services/NotificationDatabase.dart';
import '../services/NotificationsAPI.dart';
import '../widgets/NotificationCard.dart';
import '../widgets/NotificationItem.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key, Client? client}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    // Add listener for notificationsAPI updates
    NotificationsAPI().addListener(() {
      _loadNotifications(); // Reload notifications when updated
    });
  }

  Future<void> _loadNotifications() async {
    final notificationsData = await NotificationDatabase.getNotifications();
    setState(() {
      _notifications = notificationsData.map((data) {
        return NotificationItem(
          title: data['title'],
          message: data['body'],
          date: DateTime.parse(data['date']),
        );
      }).toList();
    });
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications(); // Refresh the list by reloading notifications
  }

  Future<void> _deleteNotification(int index) async {
    final notification = _notifications[index];
    try {
      await NotificationDatabase.deleteNotification(notification.date );
      setState(() {
        _notifications.removeAt(index);
      });
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _notifications.isEmpty
            ? const Center(child: Text('No notifications yet'))
            : ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return Dismissible(
              key: Key(notification.date.toString()), // Ensure unique key
              onDismissed: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  await _deleteNotification(index);
                }
              },
              background: Container(
                color: Colors.red,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                    SizedBox(width: 8.0),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              child: NotificationCard(notification: notification),
            );
          },
        ),
      ),
    );
  }
}
