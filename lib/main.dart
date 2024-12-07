import 'package:easy_localization/easy_localization.dart';
import 'package:ebike/pages/Map.dart';
import 'package:ebike/pages/OnboardingPage.dart';
import 'package:ebike/pages/SplashScreen.dart';
import 'package:ebike/pages/referral_dialog.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/util/NotificationService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:uni_links/uni_links.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'dart:async'; // For StreamSubscription

import 'util/firebase_options.dart';
import 'util/theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    // Initialize Firebase and Notifications
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final notificationService = NotificationService();
    await notificationService.initialize();
    await FirebaseMessaging.instance.requestPermission();
    // Activate Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // or AndroidProvider.safetyNet
      appleProvider: AppleProvider.deviceCheck, // iOS-specific provider
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

    // Initialize the notification plugin for Android
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Handle Firebase Messages (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show notification
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'Serkel',
              'Serkel',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Background handler for Firebase messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    // Fluttertoast.showToast(
    //   msg: 'Firebase initialization error: $e',
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM,
    //   backgroundColor: Colors.black,
    //   textColor: Colors.white,
    //   fontSize: 16.0,
    // );
  }

  // Load environment variables
  try {
    await dotenv.load();
    Fluttertoast.showToast(
      msg: 'Loaded environment variables',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Error loading environment variables: $e',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('fr', 'FR'),
        Locale('ar', 'TN')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

// Firebase background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _sub;
  ThemeMode _themeMode = ThemeMode.system;
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _initDeepLinkListener() {
    // Listen for deep links while the app is running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (Object err) {
      print('Error listening for deep links: $err');
    });

    // Handle deep link when app is started via the link
    getInitialUri().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }).catchError((err) {
      print('Error retrieving initial link: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    final referralCode = uri.queryParameters['code'];
    if (referralCode != null) {
      // Show the referral dialog with the code
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return ReferralDialog(referralCode: referralCode);
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'serkel'.tr(),
        themeMode: _themeMode, // Apply the selected theme mode
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingPage(),
          '/home': (context) => const MapPage(),
          '/signin': (context) => const SignInPage(),
        },
      ),

    );
  }
}
