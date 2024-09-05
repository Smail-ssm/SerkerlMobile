import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/NotificationDatabase.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Store the token in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("fcmToken", token!);

    // Get the current user's UID (assuming FirebaseAuth is used)
    var currentUser = FirebaseAuth.instance.currentUser;

     final usersCollection = FirebaseFirestore.instance.collection(getFirestoreDocument());

    await usersCollection
        .doc('users')
        .collection(currentUser!.uid)
        .doc('user')
        .update({
      'fcmToken': token,
    });

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.messageId}');
      // Process and save the notification
      _saveNotification(message);
    });

    // Handle messages when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.messageId}');
      // Handle the notification click
    });
  }

  Future<void> _saveNotification(RemoteMessage message) async {
    // Extract notification details
    final notificationData = {
      'title': message.notification?.title ?? 'No Title',
      'body': message.notification?.body ?? 'No Body',
      'date': DateTime.now().toIso8601String(),
    };

    // Save notification to SQLite
    await NotificationDatabase.saveNotification(notificationData);
  }
}
