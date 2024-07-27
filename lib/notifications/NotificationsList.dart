import 'package:ebike/notifications/NotificationsAPI.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/NotificationCard.dart';
import 'NotificationItem.dart';

class NotificationsPage extends StatefulWidget {
  final user;

  const NotificationsPage({required this.user});
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
    final prefs = await SharedPreferences.getInstance();
    final storedNotifications = prefs.getStringList('notifications') ?? [];
    _notifications = storedNotifications
        .map((notificationString) =>
            NotificationItem.fromJson(notificationString))
        .toList();
    setState(() {});
  }

  Future<void> _deleteNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _notifications.removeAt(index);
    final storedNotifications =
        _notifications.map((notification) => notification.toJson()).toList();
    await prefs.setStringList('notifications', storedNotifications);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification
                      .title), // Use a unique key for each notification
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteNotification(index);
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
    );
  }
}
