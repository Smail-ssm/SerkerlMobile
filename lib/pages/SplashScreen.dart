import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../model/client.dart';
import '../pages/Map.dart';
import '../services/LocationService.dart';
import '../util/util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? seenOnboarding = prefs.getBool('seenOnboarding');
      User? user = FirebaseAuth.instance.currentUser;
      String? userId = prefs.getString('userId');

      if (seenOnboarding == true) {
        if (user != null && userId != null) {
          // Fetch Client data
          Client? client;
          try {
            client = await fetchClientData(userId);
          } catch (e) {
            Fluttertoast.showToast(
              msg: 'Error fetching client data: $e',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
            client = null;
          }

          // Fetch position via LocationService
          Position? position;
          try {
            position = await _locationService.determinePosition(context);
          } catch (e) {
            Fluttertoast.showToast(
              msg: 'Error fetching position: $e',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            );
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MapPage(
                client: client,
                position: position,
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
        _errorMessage = 'Failed to initialize app: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                  ),
                  Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'yourNewWayToSerkel'.tr(),
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
              onPressed: _initializeApp,
              child: const Text('Retry'),
            ),
          ],
        )
            : Container(),
      ),
    );
  }
}
