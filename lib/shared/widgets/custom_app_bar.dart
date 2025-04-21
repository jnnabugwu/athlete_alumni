import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart' as app_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<app_auth.AuthBloc, app_auth.AuthState>(
      builder: (context, state) {
        final bool isAuthenticated = state.status == app_auth.AuthStatus.authenticated;
        final String? userName = state.athlete?.name;

        return AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            'AthleteAlumni',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.go(RouteConstants.athletes),
              child: const Text(
                'Find Athletes',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
            if (isAuthenticated && userName != null) 
              // Show dropdown menu with greeting when user is authenticated
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                onSelected: (value) {
                  if (value == 'profile') {
                    _handleProfileTap(context);
                  } else if (value == 'settings') {
                    // Navigate to settings page when implemented
                  } else if (value == 'logout') {
                    // Get the AuthBloc and dispatch logout event
                    context.read<app_auth.AuthBloc>().add(const app_auth.AuthSignedOut());
                    
                    // Show message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logging out...')),
                    );
                    
                    // Navigate to login screen
                    context.go(RouteConstants.login);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Hello, ${userName.split(' ').first}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('View Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              )
            else 
              // Show regular sign in button when not authenticated
              TextButton(
                onPressed: () => context.go(RouteConstants.login),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
              SizedBox(width: MediaQuery.sizeOf(context).width * .05,)
          ],
        );
      },
    );
  }

  void _handleProfileTap(BuildContext context) {
    final authBloc = GetIt.I<app_auth.AuthBloc>();
    final authState = authBloc.state;
    
    if (authState.status == app_auth.AuthStatus.authenticated) {
      // Get the current Supabase user
      final currentUser = Supabase.instance.client.auth.currentUser;
      
      if (currentUser != null) {
        // If we have a current user, use their ID
        context.go('/profile/${currentUser.id}');
      } else {
        // If somehow we're authenticated but don't have a user, go to login
        context.go(RouteConstants.login);
      }
    } else {
      // If not authenticated, redirect to login
      context.go(RouteConstants.login);
    }
  }
}

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const CustomNavBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem(
            context, 
            'Home', 
            RouteConstants.home, 
            currentIndex == 0
          ),
          _buildNavItem(
            context, 
            'Find Athletes', 
            RouteConstants.athletes, 
            currentIndex == 1
          ),
          _buildNavItem(
            context, 
            'Forums', 
            RouteConstants.forums, 
            currentIndex == 2
          ),
          _buildNavItem(
            context, 
            'Local Athletes', 
            '${RouteConstants.athletes}/local', 
            currentIndex == 3
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(
    BuildContext context, 
    String label, 
    String route, 
    bool isActive
  ) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive 
                ? Colors.white 
                : Colors.white.withOpacity(0.7),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}