import 'package:flutter/material.dart';
import 'package:gadgetzilla/screens/onboarding_screen.dart';
import 'package:gadgetzilla/screens/home_screen.dart'; // Import HomeScreen
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter is initialized before any asynchronous code runs
  WidgetsFlutterBinding.ensureInitialized();

  // Get the instance of SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Check if the user is logged in
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Run the app
  runApp(MyApp(isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp(this.isLoggedIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadgetZilla',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.blue),
      home: isLoggedIn ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}
