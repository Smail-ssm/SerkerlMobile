import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String channelCountdownId = "countdown_channel_id";
  static const String channelCountdownName = "Countdown Channel";
  static const String channelCountdownDescription = "Receiving Countdown Notifications";

  final AndroidNotificationChannel _countdownNotificationChannel = const AndroidNotificationChannel(
    channelCountdownId,
    channelCountdownName,
    description: channelCountdownDescription,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_countdownNotificationChannel);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
          onDidReceiveNotificationResponse: notificationTapBackground);

      print("Notification Initialized Successfully!");
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse notificationResponse) {
    if (notificationResponse.actionId == 'stop') {
      // Cancel the notification if the stop action is triggered
      FlutterLocalNotificationsPlugin().cancel(0); // 0 is the notification ID
    } else {
      log(notificationResponse.actionId ?? "");
    }
  }


  Future<void> showCountdownNotification({required int seconds}) async {
    int remainingTime = seconds;

    final AndroidNotificationDetails androidNotificationDetailsChronometer = AndroidNotificationDetails(
      channelCountdownId,
      channelCountdownName,
      channelDescription: channelCountdownDescription,
      importance: Importance.max,
      priority: Priority.max,
      ongoing: true,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        '', // Empty large text placeholder
        htmlFormatBigText: true,
        contentTitle: 'Timer Notification',
        htmlFormatTitle: true,
      ),
      when: DateTime.now().millisecondsSinceEpoch + (remainingTime * 1000),
      chronometerCountDown: false,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      actions: const [
        AndroidNotificationAction('pause', 'PAUSE', cancelNotification: false),
        AndroidNotificationAction('stop', 'STOP', cancelNotification: true),
      ],
    );

    flutterLocalNotificationsPlugin.show(
      0,
      "Timer Notification",
      "Counting down: $remainingTime seconds remaining...",
      NotificationDetails(android: androidNotificationDetailsChronometer),
    );

    // Periodically update the notification once per minute
    Future<void> updateNotification() async {
      if (remainingTime > 0) {
        await Future.delayed(const Duration(seconds: 1), () {
          remainingTime--;
          flutterLocalNotificationsPlugin.show(
            0,
            "Timer Notification",
            "Counting down: $remainingTime seconds remaining...",
            NotificationDetails(android: androidNotificationDetailsChronometer),
          );
          updateNotification();
        });
      }
    }

    updateNotification();
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
