import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/athlete.dart';
import '../widgets/profile_header.dart';
import '../widgets/common_info_section.dart';
import '../widgets/type_specific_section.dart';

class ProfilePage extends StatelessWidget {
  final Athlete athlete;
  final bool isOwnProfile;
  final VoidCallback? onEditPressed;
  
  const ProfilePage({
    Key? key,
    required this.athlete,
    required this.isOwnProfile,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if this is a dev bypass navigation
    final bool isDevBypass = GoRouterState.of(context).extra != null &&
        (GoRouterState.of(context).extra as Map?)?.containsKey('devBypass') == true &&
        (GoRouterState.of(context).extra as Map)['devBypass'] == true;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isOwnProfile ? 'My Profile' : 'Athlete Profile'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Go to Home',
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (isOwnProfile && onEditPressed != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Edit'),
                onPressed: onEditPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with image, name, and athlete type badge
            ProfileHeader(athlete: athlete),
            
            // Common information section (sports and bio)
            CommonInfoSection(athlete: athlete),
            
            // Type-specific information based on athlete status
            TypeSpecificSection(athlete: athlete),
            
            // Edit profile button if viewing own profile
            if (isOwnProfile) _buildEditButton(context),
            
            // Return to home button
            _buildHomeButton(context),
            
            // Extra padding at the bottom for better scroll experience
            const SizedBox(height: 24),
            
            // Add developer tools panel if in dev bypass mode
            if (isDevBypass) _buildDevToolsPanel(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEditButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: onEditPressed,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24, 
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: OutlinedButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.home),
          label: const Text('Return to Home'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24, 
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildDevToolsPanel(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        border: Border.all(color: Colors.amber.shade800),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Text(
                'Developer Tools',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Use these buttons to navigate to different routes for testing:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Home'),
                onPressed: () => context.go(
                  '/',
                  extra: {'devBypass': true},
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Athletes List'),
                onPressed: () => context.go(
                  '/mentors',
                  extra: {'devBypass': true},
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('Messages'),
                onPressed: () => context.go(
                  '/messages',
                  extra: {'devBypass': true},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
