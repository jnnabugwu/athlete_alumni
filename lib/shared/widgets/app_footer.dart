import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A1929), // Dark blue background
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AthleteAlumni Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AthleteAlumni',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connecting college athletes with their networks for career success.',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.public, color: Colors.white), // Twitter
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.business_center, color: Colors.white), // LinkedIn
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_camera, color: Colors.white), // Instagram
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick Links Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Links',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink(context, 'Home', '/'),
                    _buildFooterLink(context, 'Find Athletes', '/athletes'),
                    _buildFooterLink(context, 'Forums', '/forums'),
                    _buildFooterLink(context, 'Find Mentors', '/mentors'),
                  ],
                ),
              ),
              // Schools Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Schools',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink(context, 'Princeton University', '/schools/princeton'),
                    _buildFooterLink(context, 'UCLA', '/schools/ucla'),
                    _buildFooterLink(context, 'Stanford University', '/schools/stanford'),
                    _buildFooterLink(context, 'Browse All Schools', '/schools'),
                  ],
                ),
              ),
              // Support Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterLink(context, 'Contact Us', '/contact'),
                    _buildFooterLink(context, 'Privacy Policy', '/privacy'),
                    _buildFooterLink(context, 'Terms of Service', '/terms'),
                    _buildFooterLink(context, 'Help Center', '/help'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text(
            '© 2025 AthleteAlumni. All rights reserved.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => GoRouter.of(context).go(route),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 