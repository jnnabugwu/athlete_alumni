import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDevBypass = GoRouterState.of(context).extra != null &&
        (GoRouterState.of(context).extra as Map?)?.containsKey('devBypass') == true &&
        (GoRouterState.of(context).extra as Map)['devBypass'] == true;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFeaturesSection(context),
            if (isDevBypass) _buildDevToolsPanel(context),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavBar(currentIndex: 0),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        
        return Container(
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Connect with Athletes',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Find and connect with athletes from your alma mater',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    // Show a snackbar to indicate navigation attempt
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navigating to your profile...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Get the current auth state
                    final authState = context.read<AuthBloc>().state;
                    
                    // Check for athlete ID first, fall back to generating a unique ID if needed
                    final String profileId = authState.athlete?.id.isNotEmpty == true 
                        ? authState.athlete!.id
                        : 'user-${DateTime.now().millisecondsSinceEpoch}';
                    
                    debugPrint("HomePage button: Using profile ID: $profileId (has athlete data: ${authState.athlete != null})");
                    
                    // Navigate to the profile with isOwnProfile = true
                    context.go(
                      '/profile/$profileId',
                      extra: {
                        'isOwnProfile': true,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: state.status == AuthStatus.loading || state.status == AuthStatus.initial
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      : Text(
                          state.status == AuthStatus.authenticated ? 'Go to Profile' : 'Get Started',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          const Text(
            'Why AthleteAlumni?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureCard(
                icon: Icons.people,
                title: 'Connect',
                description: 'Network with athletes from your school',
              ),
              _buildFeatureCard(
                icon: Icons.sports,
                title: 'Discover',
                description: 'Find athletes in your area',
              ),
              _buildFeatureCard(
                icon: Icons.forum,
                title: 'Engage',
                description: 'Join discussions and share experiences',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
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
                icon: const Icon(Icons.person),
                label: const Text('Profile Page'),
                onPressed: () => context.go(
                  RouteConstants.myProfile,
                  extra: {'devBypass': true},
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Athletes List'),
                onPressed: () => context.go(
                  RouteConstants.athletes,
                  extra: {'devBypass': true},
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('Messages'),
                onPressed: () => context.go(
                  RouteConstants.messages,
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