import 'package:flutter/material.dart';
import 'package:gokul_shree_app/src/core/theme/app_theme.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ContactInfoCard(
              icon: Icons.location_on,
              title: 'Our Campus',
              content: 'Gokul Shree School of Management,\nVaranasi, Uttar Pradesh, India',
            ),
            const SizedBox(height: 12),
            const _ContactInfoCard(
              icon: Icons.phone,
              title: 'Phone',
              content: '+91-9628281020',
            ),
            const SizedBox(height: 12),
            const _ContactInfoCard(
              icon: Icons.email,
              title: 'Email',
              content: 'info@gokulshreeschool.com',
            ),
            const SizedBox(height: 32),
            Text(
              'Send us an Enquiry',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Message / Query',
                prefixIcon: Icon(Icons.message_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement submitting
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enquiry sent successfully!')),
                  );
                },
                child: const Text('SUBMIT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ContactInfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
