import 'package:ebike/splashscreen.dart';
import 'package:ebike/util/AppRouter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Bike Rental App',
      home: App(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  late bool _userSignedIn;

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
    return FutureBuilder<void>(
      future:
          _checkUserSignIn(), // Update the future to match the correct Future type
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: SplashScreen(),
          );
        } else {
          return MaterialApp(
            title: 'E-Bike Rental App',
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute:
                _userSignedIn ? '/' : '/signin', // Use _userSignedIn directly
          );
        }
      },
    );
  }
}
