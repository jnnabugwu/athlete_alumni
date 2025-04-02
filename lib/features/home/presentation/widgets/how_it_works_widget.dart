import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HowItWorksWidget extends StatelessWidget {
  const HowItWorksWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'How AthleteAlumni Works',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Connect with fellow athletes from your college and sport to build your network and career',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          _buildSteps(context),
        ],
      ),
    );
  }

  Widget _buildSteps(BuildContext context) {
    // Responsive layout handling
    final screenWidth = MediaQuery.of(context).size.width;
    bool isNarrow = screenWidth < 800;

    if (isNarrow) {
      // Stack steps vertically on narrow screens
      return const Column(
        children: [
          StepCard(
            number: '1',
            title: 'Create Your Profile',
            description: 'Sign up and build your athlete profile with your college, sport, and career details.',
          ),
          SizedBox(height: 16),
          StepCard(
            number: '2',
            title: 'Find Your Network',
            description: 'Browse rosters by college and sport to connect with current and former athletes.',
          ),
          SizedBox(height: 16),
          StepCard(
            number: '3',
            title: 'Get Mentored',
            description: 'Connect with alumni mentors who share your background and can guide your career path.',
          ),
        ],
      );
    } else {
      // Horizontal layout for wider screens
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StepCard(
              number: '1',
              title: 'Create Your Profile',
              description: 'Sign up and build your athlete profile with your college, sport, and career details.',
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: StepCard(
              number: '2',
              title: 'Find Your Network',
              description: 'Browse rosters by college and sport to connect with current and former athletes.',
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: StepCard(
              number: '3',
              title: 'Get Mentored',
              description: 'Connect with alumni mentors who share your background and can guide your career path.',
            ),
          ),
        ],
      );
    }
  }
}

class StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const StepCard({
    Key? key,
    required this.number,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}