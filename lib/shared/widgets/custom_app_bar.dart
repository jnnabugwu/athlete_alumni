import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/router/route_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isAuthenticated = state.status == AuthStatus.authenticated;
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
                    context.go(RouteConstants.myProfile);
                  } else if (value == 'settings') {
                    // Navigate to settings page when implemented
                  } else if (value == 'logout') {
                    context.read<AuthBloc>().add(const AuthSignedOut());
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
            Padding(
              padding: const EdgeInsets.only(right: 16.0, left: 8.0),
              child: ElevatedButton(
                onPressed: () => isAuthenticated 
                  ? context.go(RouteConstants.myProfile)
                  : context.go(RouteConstants.register),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                ),
                child: Text(isAuthenticated ? 'My Profile' : 'Get Started'),
              ),
            ),
          ],
        );
      },
    );
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