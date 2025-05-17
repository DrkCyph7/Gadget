import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login_Screen.dart';
import 'profile_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Center(
              child: Text(
                'Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _buildAccountOption(context, 'My Listings', Icons.list_alt),
            _buildAccountOption(
              context,
              'My Details',
              Icons.person_outline,
              goToProfile: true,
            ),
            _buildAccountOption(
              context,
              'Notifications',
              Icons.notifications_outlined,
            ),
            _buildAccountOption(context, 'FAQs', Icons.help_outline),
            _buildAccountOption(
              context,
              'Help Center',
              Icons.contact_support_outlined,
            ),
            _buildAccountOption(
              context,
              'Logout',
              Icons.logout,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    BuildContext context,
    String title,
    IconData icon, {
    bool isLogout = false,
    bool goToProfile = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
          title: Text(
            title,
            style: TextStyle(
              color: isLogout ? Colors.red : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            if (isLogout) {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            } else if (goToProfile) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
