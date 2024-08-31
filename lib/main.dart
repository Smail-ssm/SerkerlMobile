import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/pages/Map.dart';
import 'package:ebike/pages/OnboardingPage.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'util/firebase_options.dart';
import 'model/client.dart';
import 'util/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SERKEL 🔃',
      theme: lightTheme, // Set the light theme
      darkTheme: darkTheme, // Set the dark theme
      themeMode: ThemeMode.system, // Use system theme mode
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => OnboardingPage(),
        '/home': (context) => const MapPage(), // Home or main page
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
      await Future.delayed(const Duration(milliseconds: 3000)); // Simulate loading time

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? seenOnboarding = prefs.getBool('seenOnboarding'); // Corrected the key name syntax

      User? user = FirebaseAuth.instance.currentUser;
      String? userId = prefs.getString('userId');

      if (seenOnboarding == true) {
        if (user  != null && userId != null) {
          // Fetch Client data
          Client? client;
          try {
            client = await fetchClientData(userId); // Implement this function in user_service.dart
          } catch (e) {
            print('Error fetching client data: $e');
            client = null;
          }

          Position? position;
          try {
            position = await _determinePosition();
          } catch (e) {
            position = null; // Handle location service errors
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(client: client, position: position), // Pass position if needed
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
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          throw Exception('Location permissions are denied.');
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error in obtaining location: $e');
      throw e; // Re-throw to handle in _initializeApp
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _errorMessage != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            ElevatedButton(
              onPressed: _initializeApp, // Retry initialization
              child: const Text('Retry'),
            ),
          ],
        )
            : SizedBox(
          height: 200,
          width: 200,
          child: Image.asset("assets/logo.png"),
        ),
      ),
    );
  }
}
