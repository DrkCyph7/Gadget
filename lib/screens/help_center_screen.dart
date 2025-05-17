import 'package:flutter/material.dart';
import 'account_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, String>> helpTopics = const [
    {
      'title': 'Contact Support',
      'detail':
          'Reach us via email at support@gadgetzilla.com or through the in-app chat.',
    },
    {
      'title': 'Report a Bug',
      'detail':
          'Found an issue? Please report it under the Feedback section of your profile.',
    },
    {
      'title': 'Terms & Privacy',
      'detail':
          'Review our Terms of Service and Privacy Policy to understand your rights and responsibilities.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
              ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: helpTopics.length,
        itemBuilder: (context, index) {
          final item = helpTopics[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(item['title']!),
              subtitle: Text(item['detail']!),
              leading: const Icon(Icons.help_outline),
            ),
          );
        },
      ),
    );
  }
}
