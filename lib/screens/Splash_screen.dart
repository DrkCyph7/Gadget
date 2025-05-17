import 'package:flutter/material.dart';
import 'package:gadgetzilla/screens/onboarding_screen.dart';
import 'package:gadgetzilla/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/Element.png', fit: BoxFit.cover),
          Column(
            children: [
              const Spacer(flex: 4), // slightly less space above
              Center(
                child: Image.asset(
                  'assets/GadgetZilla Logo.png',
                  height: 200,
                  width: 200,
                ),
              ),
              const Spacer(flex: 3), // slightly more space below logo
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: LoadingAnimationWidget.fourRotatingDots(
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
