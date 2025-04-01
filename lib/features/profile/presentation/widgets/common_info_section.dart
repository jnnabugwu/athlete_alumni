import 'package:flutter/material.dart';
import '../../../../core/models/athlete.dart';

class CommonInfoSection extends StatelessWidget {
  final Athlete athlete;

  const CommonInfoSection({
    Key? key,
    required this.athlete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sports section
          _buildSportsSection(context),
          const SizedBox(height: 24),
          
          // School section 
          if (athlete.university != null)
            _buildUniversitySection(context),
          
          // Achievements section if available
          if (athlete.achievements != null && athlete.achievements!.isNotEmpty)
            _buildAchievementsSection(context),
        ],
      ),
    );
  }
  
  Widget _buildSportsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sports, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sport',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (athlete.sport != null)
          Chip(
            label: Text(
              athlete.sport!,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          )
        else
          Text(
            'No sport information available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
  
  Widget _buildUniversitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, size: 20),
              const SizedBox(width: 8),
              Text(
                'University',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Text(
              athlete.university!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 20),
              const SizedBox(width: 8),
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: athlete.achievements!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(athlete.achievements![index]),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 