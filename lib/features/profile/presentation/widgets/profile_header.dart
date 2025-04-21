import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart'; // Updated import path
import '../bloc/profile_bloc.dart';

class ProfileHeader extends StatelessWidget {
  final Athlete athlete;

  const ProfileHeader({
    Key? key,
    required this.athlete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) =>
          current is ProfileLoaded ||
          current is ProfileError,
      builder: (context, state) {
        // Get the image URL from the ProfileLoaded state
        final String? imageUrl = state is ProfileLoaded ? state.imageUrl : null;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Column(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? Text(
                        athlete.name?.isNotEmpty == true
                            ? athlete.name![0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                athlete.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (athlete.email != null && athlete.email!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  athlete.email!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              
              // Athlete Type Badge
              _buildAthleteBadge(context),
            ],
          ),
        );
      },
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
