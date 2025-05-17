import 'package:flutter/material.dart';
import 'account_screen.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How do I list a new product?',
      'answer':
          'Navigate to the "+" and complete the required fields, then tap "Publish".',
    },
    {
      'question': 'How do I delete a product?',
      'answer': 'Go to "My Listings", tap the Bin icon on the item.',
    },
    {
      'question': 'Can I edit an existing product?',
      'answer':
          'Currently, products cannot be edited after publishing. Please delete and relist if needed.',
    },
    {
      'question': 'Why is my product not visible on the Discover?',
      'answer':
          'Ensure the product has been published with all required fields including an image.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQs',
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
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          return ExpansionTile(
            title: Text(item['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(item['answer']!),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
