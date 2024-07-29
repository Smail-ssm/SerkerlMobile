import 'package:ebike/util/Notfoiuund.dart';
 import 'package:flutter/material.dart';

import '../pages/Map.dart';
import '../pages/signin_page.dart';
 import '../pages/signup_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route name and arguments

    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => const MapPage( ));
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpPage());

      // Add more routes as needed
      default:
        // If route not found, navigate to a default page or show an error
        return MaterialPageRoute(builder: (_) => const NotFoundRout());
    }
  }

  // Helper method to navigate to a route
  static Future<void> navigateTo(BuildContext context, String routeName,
      {dynamic arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}
