import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
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
    // Check for route parameters
    final routerState = GoRouterState.of(context);
    final Map<String, dynamic>? extra = routerState.extra as Map<String, dynamic>?;
    
    // Get current authentication state
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final authUser = authState.athlete;
    final String? authUserId = authUser?.id;
    final bool isAuthenticated = authState.status == AuthStatus.authenticated;
    
    // Check if we need to override isOwnProfile from the router extra params
    final bool routeIsOwnProfile = extra != null && 
        extra.containsKey('isOwnProfile') && 
        extra['isOwnProfile'] == true;
    
    // Check if the profile matches the authenticated user's ID
    final bool idMatches = isAuthenticated && 
                         authUserId != null && 
                         athlete.id == authUserId;
    
    // For Google sign-in, also check email match as a fallback
    final bool emailMatches = isAuthenticated && 
                            authUser?.email != null && 
                            athlete.email != null &&
                            authUser!.email == athlete.email;
    
    // Determine if this is the user's own profile through multiple methods
    final bool effectiveIsOwnProfile = routeIsOwnProfile || isOwnProfile || idMatches || emailMatches;
    
    // Log information about the decision
    if (kDebugMode) {
      print('🧩 Profile ownership check:');
      print('  - Route isOwnProfile: $routeIsOwnProfile');
      print('  - Constructor isOwnProfile: $isOwnProfile');
      print('  - ID match: $idMatches (${authUserId ?? 'no auth ID'} vs ${athlete.id})');
      print('  - Email match: $emailMatches (${authUser?.email ?? 'no auth email'} vs ${athlete.email ?? 'no profile email'})');
      print('  - Decision: ${effectiveIsOwnProfile ? 'IS own profile' : 'NOT own profile'}');
    }
    
    final bool isDevBypass = extra != null &&
        extra.containsKey('devBypass') &&
        extra['devBypass'] == true;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(effectiveIsOwnProfile ? 'My Profile' : 'Athlete Profile'),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Go to Home',
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (effectiveIsOwnProfile && onEditPressed != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Edit'),
                onPressed: onEditPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
            
            // Logout button if viewing own profile
            if (effectiveIsOwnProfile) _buildLogoutButton(context),
            
            // Navigation buttons row (home and edit)
            _buildBottomButtons(context, effectiveIsOwnProfile),
            
            // Extra padding at the bottom for better scroll experience
            const SizedBox(height: 24),
            
            // Add developer tools panel if in dev bypass mode
            if (isDevBypass) _buildDevToolsPanel(context),
          ],
        ),
      ),
    );
  }
  
  // Bottom buttons row with Home and Edit buttons
  Widget _buildBottomButtons(BuildContext context, bool isOwn) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isOwn)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton.icon(
                  onPressed: onEditPressed ?? () {
                    // Navigate to edit profile page
                    context.push('/profile/edit', extra: {'athlete': athlete});
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isOwn ? 8.0 : 0),
              child: OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Home'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: ElevatedButton.icon(
          onPressed: () => _showLogoutConfirmationDialog(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: 24, 
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(200, 50),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // Get the AuthBloc and dispatch logout event
    context.read<AuthBloc>().add(const AuthSignedOut());
    
    // Show message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logging out...')),
    );
    
    // Navigate to login screen
    context.go('/auth/login');
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
