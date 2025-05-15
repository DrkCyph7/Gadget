import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildAccountOption('My Listings', Icons.list_alt),
            _buildAccountOption('My Details', Icons.person_outline),
            _buildAccountOption('Notifications', Icons.notifications_outlined),
            _buildAccountOption('FAQs', Icons.help_outline),
            _buildAccountOption('Help Center', Icons.contact_support_outlined),
            _buildAccountOption('Logout', Icons.logout, isLogout: true),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Image.asset('assets/home.png', width: 24),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              IconButton(
                icon: Image.asset('assets/search.png', width: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: Image.asset('assets/heart.png', width: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/saved');
                },
              ),
              IconButton(
                icon: Image.asset('assets/profile_filled.png', width: 24),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    String title,
    IconData icon, {
    bool isLogout = false,
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
          onTap: () {
            // Handle option tap
          },
        ),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}
