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
      bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is authenticated
        String? userId = prefs.getString('userId');
        if (seenOnboarding && userId != null) {
          // Fetch client data and user location
          Client? client = await _fetchClientData(userId);
          Position? position = await _fetchUserLocation();

          if (client != null && position != null) {
            _navigateToMapPage(client, position);
          } else {
            _navigateToSignInPage();
          }
        } else {
          _navigateToOnboardingPage();
        }
      } else {
        // User is not authenticated
        _navigateToSignInPage();
      }
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<Client?> _fetchClientData(String userId) async {
    try {
      return await fetchClientData(userId);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching client data: $e',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<Position?> _fetchUserLocation() async {
    try {
      return await _locationService.determinePosition(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching position: $e',
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
      return null;
    }
  }

  void _navigateToMapPage(Client client, Position position) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(client: client, position: position),
      ),
    );
  }

  void _navigateToSignInPage() {
    Navigator.pushReplacementNamed(context, '/signin');
  }

  void _navigateToOnboardingPage() {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  void _handleInitializationError(dynamic error) {
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to initialize app: $error';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isLoading
            ? _buildLoadingScreen(context)
            : _buildErrorScreen(),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Column(
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
    );
  }

  Widget _buildErrorScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _errorMessage ?? '',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _initializeApp,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
