import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
 import '../widgets/NotificationItem.dart';
import 'NotificationDatabase.dart';

class NotificationsAPI {
  final List<NotificationItem> _notifications = [];
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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = NotificationItem(
        title: message.notification?.title ?? '',
        message: message.notification?.body ?? '',
        date: message.sentTime ?? DateTime.now(),
      );
      _notifications.add(notification);

      // Save notification to SQLite
      await NotificationDatabase.saveNotification({
        'title': notification.title,
        'body': notification.message,
        'date': notification.date.toIso8601String(),
      });

      // Notify listeners to refresh notifications
      notifyListeners();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotification(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then(handleNotification);
  }

  void handleNotification(RemoteMessage? message) {
    if (message != null) {
      // Handle the notification when the app is opened from a notification
      // For example, navigate to a specific page or show a dialog
    }
  }
}
