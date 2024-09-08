import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late List<Slide> slides;

  @override
  void initState() {
    super.initState();
    slides = _createSlides();
  }

  // Function to generate the slides
  List<Slide> _createSlides() {
    return [
      Slide(
        title: "Welcome to Our App",
        description: "This is an awesome app that helps you with X, Y, and Z.",
        pathImage: "assets/images/intro1.png",
        backgroundColor: Colors.blue,
      ),
      Slide(
        title: "Easy to Use",
        description: "Our app is designed to be user-friendly and easy to navigate.",
        pathImage: "assets/images/intro2.png",
        backgroundColor: Colors.green,
      ),
      Slide(
        title: "Get Started",
        description: "Sign up and start using the app right away!",
        pathImage: "assets/images/intro3.png",
        backgroundColor: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: slides,
      onDonePress: _onDonePress,
      renderSkipBtn: const Text("Skip"),
      renderNextBtn: const Text("Next"),
      renderDoneBtn: const Text("Done"),
    );
  }

  // Function to handle what happens when the user presses "Done"
  Future<void> _onDonePress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
