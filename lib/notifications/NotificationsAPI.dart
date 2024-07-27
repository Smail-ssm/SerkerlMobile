import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NotificationItem.dart';

class NotificationsAPI {
  List<NotificationItem> _notifications = [];
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _listeners = <VoidCallback>[];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = NotificationItem(
        title: message.notification!.title ?? '',
        message: message.notification!.body ?? '',
        date: message.sentTime ?? DateTime.now(),
      );
      _notifications.add(notification);
      _saveNotifications();
    });
  }

  void handleNotification(RemoteMessage? message) {
    if (message == null) {
      return;
    }
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotification);
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final storedNotifications =
        _notifications.map((notification) => notification.toJson()).toList();
    await prefs.setStringList('notifications', storedNotifications);
  }
}
