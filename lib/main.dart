import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebike/pages/Map.dart';
import 'package:ebike/pages/signin_page.dart';
import 'package:ebike/util/util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
 import 'util/firebase_options.dart';
import 'model/client.dart';
import 'util/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 3000)); // Simulate loading time

    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (user != null && userId != null) {
      // Fetch Client data
      Client? client;
      try {
        client = await  fetchClientData(userId); // Implement this function in user_service.dart
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
          builder: (context) => MapPage(client: client ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Location permissions are denied.');
        throw Exception('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SizedBox(
          height: 200,
          width: 200,
          child: SvgPicture.asset("assets/logo.svg"),
        ),
      ),
    );
  }


}
