import 'package:flutter/material.dart';
import 'package:gadgetzilla/screens/signup_screen.dart'; // Make sure this path is correct

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background curved lines
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 180),
                  child: Image.asset(
                    'assets/Element 1.png',
                    width: screenWidth * 1.2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Main content layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 40, left: 24, right: 24),
                  child: Text(
                    'Define\nyourself in\nyour unique\nway.',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Robot image
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: screenWidth * 2,
                      width: screenWidth * 2,
                      child: Image.asset(
                        'assets/Onboard Logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Later: Check if user is logged in, then go to HomeScreen
                        // For now: Go to SignupScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
