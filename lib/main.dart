import 'package:ebike/splashscreen.dart';
import 'package:ebike/util/AppLocalization.dart';
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
  await AppLocalization.load(Locale('en')); // Load default language
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late Future<bool> _userSignedIn;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await _loadLocale();
    _userSignedIn = _checkUserSignIn();
  }

  Future<void> _loadLocale() async {
    SharedPreferences prefs = await _loadPrefs();
    String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
    } else {
      setState(() {
        _locale = Locale('en');
        _setLocale(Locale('en')); // Set default locale if none is saved
      });
    }
  }

  Future<void> _setLocale(Locale newLocale) async {
    SharedPreferences prefs = await _loadPrefs();
    await prefs.setString('languageCode', newLocale.languageCode);
    setState(() {
      _locale = newLocale;
    });
  }

  Future<SharedPreferences> _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<bool> _checkUserSignIn() async {
    SharedPreferences prefs = await _loadPrefs();
    String? userId = prefs.getString('userId');
    return userId != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userSignedIn,
      builder: (context, AsyncSnapshot<bool> userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: SplashScreen(),
          );
        } else {
          return MaterialApp(
            title: 'E-Bike Rental App',
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: userSnapshot.data! ? '/' : '/signin',
            locale: _locale,
            localizationsDelegates: const [
              AppLocalization.delegate,
              // Add other delegates here
              // ...
            ],
            supportedLocales: AppLocalization.supportedLocales,
          );
        }
      },
    );
  }
}
