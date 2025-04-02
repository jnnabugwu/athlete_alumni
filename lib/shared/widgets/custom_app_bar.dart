import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_constants.dart';
import '../../core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => context.go(RouteConstants.register),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Get Started'),
          ),
        ),
      ],
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