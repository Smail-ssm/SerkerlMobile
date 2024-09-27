import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late List<Slide> slides;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    slides = _createSlides();
    _checkInitialPermissions();
  }

  // Check permissions when the page is first initialized
  Future<void> _checkInitialPermissions() async {
    final bool locationGranted = await Permission.location.isGranted;
    final bool notificationGranted = await Permission.notification.isGranted;

    if (locationGranted && notificationGranted) {
      setState(() {
        _permissionsGranted = true;
      });
    }
  }

  // Function to generate the slides
  List<Slide> _createSlides() {
    return [
      Slide(
        title: "Welcome to Our E-Scooter and E-Bike App",
        description: "Rent scooters or e-bikes easily and quickly with just a few taps.",
        pathImage: "assets/images/intro_welcome.png",
        backgroundColor: Colors.blue,
      ),
      Slide(
        title: "Find and Reserve",
        description: "Locate the nearest scooter or e-bike on the map, reserve it in advance, and get riding!",
        pathImage: "assets/images/intro_find.png",
        backgroundColor: Colors.green,
      ),
      Slide(
        title: "Simple Payment",
        description: "Link your preferred payment method, and enjoy hassle-free payments for your rides.",
        pathImage: "assets/images/intro_payment.png",
        backgroundColor: Colors.orange,
      ),
      Slide(
        title: "Eco-Friendly Rides",
        description: "Reduce your carbon footprint by choosing an eco-friendly way to travel through the city.",
        pathImage: "assets/images/intro_eco.png",
        backgroundColor: Colors.teal,
      ),
      Slide(
        title: "Ride History & Tracking",
        description: "Track your rides and view your riding history anytime from your profile.",
        pathImage: "assets/images/intro_history.png",
        backgroundColor: Colors.purple,
      ),
      Slide(
        title: "Safety First",
        description: "Learn the safety guidelines to ensure a secure and enjoyable ride experience.",
        pathImage: "assets/images/intro_safety.png",
        backgroundColor: Colors.redAccent,
      ),
      Slide(
        title: "Earn Rewards",
        description: "Earn points for each ride and redeem them for free rides or discounts.",
        pathImage: "assets/images/intro_rewards.png",
        backgroundColor: Colors.amber,
      ),
      Slide(
        title: "Get Started",
        description: "Sign up now and start your first ride with us today!",
        pathImage: "assets/images/intro_get_started.png",
        backgroundColor: Colors.lightBlue,
      ),
    ];
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.notification,
    ].request();

    // Check if all permissions are granted
    if (statuses[Permission.location] == PermissionStatus.granted &&
        statuses[Permission.notification] == PermissionStatus.granted) {
      setState(() {
        _permissionsGranted = true;
      });
      _onDonePress();
    } else {
      Fluttertoast.showToast(
        msg: 'Permissions are required for full functionality.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: _permissionsGranted ? _onDonePress : _requestPermissions,
      renderSkipBtn: const Text("Skip"),
      renderNextBtn: const Text("Next"),
      renderDoneBtn: _permissionsGranted ? const Text("Done") : const Text("Allow Permissions"),
    );
  }

  // Function to handle what happens when the user presses "Done"
  Future<void> _onDonePress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
