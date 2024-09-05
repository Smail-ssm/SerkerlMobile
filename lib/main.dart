import 'package:ebike/pages/Map.dart';
import 'package:ebike/pages/OnboardingPage.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/util/NotificationService.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/client.dart';
import 'util/firebase_options.dart';
import 'util/theme.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    final notificationService = NotificationService();
    await notificationService.initialize();
    await FirebaseMessaging.instance.requestPermission();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Initialize the notification plugin
    final initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
     final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
     );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // Show notification
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
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
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Firebase initialization error: $e');
    // Handle the error, maybe show a dialog or retry
  }
  try {
    await dotenv.load();
    print('Loaded environment variables');
  } catch (e) {
    print('Error loading environment variables: $e');
  }
  runApp(const MyApp());
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages here
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SERKEL 🔃',
      theme: lightTheme,
      // Set the light theme
      darkTheme: darkTheme,
      // Set the dark theme
      themeMode: ThemeMode.system,
      // Use system theme mode
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => OnboardingPage(),
        '/home': (context) => const MapPage(),
        // Home or main page
        '/signin': (context) => const SignInPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? seenOnboarding = prefs.getBool('seenOnboarding'); // Corrected the key name syntax

      User? user = FirebaseAuth.instance.currentUser;
      String? userId = prefs.getString('userId');

      if (seenOnboarding == true) {
        if (user != null && userId != null) {
          // Fetch Client data
          Client? client;
          try {
            client = await fetchClientData(userId); // Implement this function in user_service.dart
          } catch (e) {
            print('Error fetching client data: $e');
            client = null;
          }

          // Initialize Position
          Position? position;
          bool isPositionLoaded = false;

          while (!isPositionLoaded) {
            try {
              position = await _determinePosition();

                isPositionLoaded = true;


            } catch (e) {
              print('Error fetching position: $e');
              // Show a loading bar while retrying to fetch the position
              setState(() {
                _isLoading = true;
              });
              await Future.delayed(const Duration(seconds: 2)); // Delay before retrying
            }
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                  client: client,
                  position: position // Pass position if needed
              ),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/signin');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize app: $e'; // Update state to show error message
      });
    }
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show dialog to prompt the user to enable location services
      bool openSettings = await _showLocationDialog(
        'Location Services Disabled',
        'Please enable location services to continue using this app.',
      );

      if (openSettings) {
        await Geolocator.openLocationSettings();
        // Recheck the location services after prompting the user
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled.');
        }
      } else {
        throw Exception('User declined to enable location services.');
      }
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show dialog to prompt the user to enable location permissions
      bool openSettings = await _showLocationDialog(
        'Location Permission Denied',
        'Please allow location permissions in settings to continue using this app.',
      );

      if (openSettings) {
        await Geolocator.requestPermission();
        // Check the permission again after prompting the user
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      } else {
        throw Exception('User declined to enable location permissions.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, show a dialog to open app settings
      bool openSettings = await _showLocationDialog(
        'Location Permission Permanently Denied',
        'Please enable location permissions in app settings to continue using this app.',
      );

      if (openSettings) {
        await Geolocator.openAppSettings();
        throw Exception('Location permissions are permanently denied.');
      } else {
        throw Exception('User declined to enable location permissions.');
      }
    }

    // If everything is fine, get the current position
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> _showLocationDialog(String title, String content) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          // Prevent closing by tapping outside
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // User chose not to open settings
                  },
                ),
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // User agreed to open settings
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.black,
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              'Image not found',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                        Center(
                          child:   CircularProgressIndicator(color: Theme.of(context).highlightColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your new way to Serkel 🔃 ...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),

                ],
              )
            : _errorMessage != null
                   ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _initializeApp, // Retry initialization
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : Container(), // Replace with your success state widget
      ),
    );
  }
}
