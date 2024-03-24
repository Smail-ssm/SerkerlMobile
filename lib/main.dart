import 'package:ebike/splashscreen.dart';
import 'package:ebike/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLocale(); // Load saved locale when app starts
  }

  // Method to load saved locale from SharedPreferences
  void _loadLocale() async {
    SharedPreferences prefs = await loadPrefs();
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

  // Method to change the app's locale and reload the app
  void _setLocale(Locale newLocale) async {
    SharedPreferences prefs = await loadPrefs();
    await prefs.setString('languageCode', newLocale.languageCode);
    setState(() {
      _locale = newLocale;
    });
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: checkUserSignIn(), // Check if user is signed in
            builder: (context, AsyncSnapshot<bool> userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  onGenerateRoute: AppRouter.generateRoute,
                  initialRoute: '/',
                  home: SplashScreen(),
                );
              } else {
                if (userSnapshot.data!) {
                  return MaterialApp(
                    title: 'E-Bike Rental App',
                    theme: AppTheme.lightTheme(),
                    onGenerateRoute: AppRouter.generateRoute,
                    initialRoute: '/',
                    locale: _locale,
                    localizationsDelegates: [
                      AppLocalization.delegate,
                      // Add other delegates here
                      // ...
                    ],
                    supportedLocales: AppLocalization.supportedLocales,
                  );
                } else {
                  return MaterialApp(
                    title: 'E-Bike Rental App',
                    theme: AppTheme.lightTheme(),
                    onGenerateRoute: AppRouter.generateRoute,
                    initialRoute: '/signin',
                    locale: _locale,
                    localizationsDelegates: [
                      AppLocalization.delegate,
                      // Add other delegates here
                      // ...
                    ],
                    supportedLocales: AppLocalization.supportedLocales,
                  );
                }
              }
            },
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }

  Future<bool> checkUserSignIn() async {
    SharedPreferences prefs = await loadPrefs();
    String? userId = prefs.getString('userId');
    return userId != null; // Return true if user ID exists, false otherwise
  }

  Future<SharedPreferences> loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }
}
