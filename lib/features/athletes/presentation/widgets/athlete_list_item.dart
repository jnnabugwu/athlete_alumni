import 'package:flutter/material.dart';
import '../../../../core/models/athlete.dart';

class AthleteListItem extends StatelessWidget {
  final Athlete athlete;
  final VoidCallback onTap;

  const AthleteListItem({
    Key? key,
    required this.athlete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Profile image
              CircleAvatar(
                radius: 30,
                backgroundImage: athlete.profileImageUrl != null
                    ? NetworkImage(athlete.profileImageUrl!)
                    : null,
                child: athlete.profileImageUrl == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              // Athlete info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      athlete.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      athlete.sport ?? 'Unknown Sport',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${athlete.university ?? 'Unknown University'} • ${athlete.major.displayName}',
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: athlete.status == AthleteStatus.current
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  athlete.status == AthleteStatus.current ? 'Current' : 'Former',
                  style: TextStyle(
                    color: athlete.status == AthleteStatus.current
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 