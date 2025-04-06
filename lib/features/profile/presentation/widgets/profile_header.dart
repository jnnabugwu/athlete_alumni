import 'package:flutter/material.dart';
import '../../../../core/models/athlete.dart'; // Updated import path

class ProfileHeader extends StatelessWidget {
  final Athlete athlete;

  const ProfileHeader({
    Key? key,
    required this.athlete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          // Profile Image
          Hero(
            tag: 'profile-${athlete.id}',
            child: CircleAvatar(
              radius: 60,
              backgroundImage: athlete.profileImageUrl != null && athlete.profileImageUrl!.isNotEmpty
                  ? NetworkImage(athlete.profileImageUrl!)
                  : null,
              backgroundColor: Colors.grey.shade200,
              onBackgroundImageError: athlete.profileImageUrl != null && athlete.profileImageUrl!.isNotEmpty
                  ? (exception, stackTrace) {
                      debugPrint("Error loading profile image: $exception");
                    }
                  : null,
              child: athlete.profileImageUrl == null || athlete.profileImageUrl!.isEmpty
                  ? Text(
                      athlete.name.isNotEmpty ? athlete.name[0] : '?',
                      style: const TextStyle(fontSize: 40),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            athlete.name,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          
          // Athlete Type Badge
          _buildAthleteBadge(context),
        ],
      ),
    );
  }
  
  Widget _buildAthleteBadge(BuildContext context) {
    final bool isCurrent = athlete.status == AthleteStatus.current;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.blue : Colors.amber,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCurrent ? Icons.school : Icons.work,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            athlete.status.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
