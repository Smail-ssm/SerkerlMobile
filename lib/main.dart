// Import the SignInPage if not already imported
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
import 'auth/signin_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Bike Rental App',
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool? _userSignedIn;

  @override
  void initState() {
    super.initState();
    _checkUserSignIn();
  }

  Future<void> _checkUserSignIn() async {
    SharedPreferences prefs = await _loadPrefs();
    String? userId = prefs.getString('userId');
    setState(() {
      _userSignedIn = userId != null;
    });
  }

  Future<SharedPreferences> _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  @override
  Widget build(BuildContext context) {
    if (_userSignedIn == null) {
      // If user sign-in status is not yet determined, show loading indicator
      return SignInPage();
    } else {
      // If user is signed in, navigate to HomePage, otherwise navigate to SignInPage
      return _userSignedIn! ? HomePage() : SignInPage();
    }
  }
}
