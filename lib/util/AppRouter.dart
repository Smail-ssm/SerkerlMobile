import 'package:ebike/Notfoiuund.dart';
import 'package:ebike/splashscreen.dart';
import 'package:flutter/material.dart';

import '../HomePage.dart';
import '../auth/signin_page.dart';
import '../auth/signup_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name and arguments
    final args = settings.arguments;

    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/signin':
        return MaterialPageRoute(builder: (_) => SignInPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpPage());
      case '/splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      // Add more routes as needed
      default:
        // If route not found, navigate to a default page or show an error
        return MaterialPageRoute(builder: (_) => Notfound());
    }
  }

  // Helper method to navigate to a route
  static Future<void> navigateTo(BuildContext context, String routeName,
      {dynamic arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}
