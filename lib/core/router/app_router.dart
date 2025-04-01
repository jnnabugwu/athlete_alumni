import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:athlete_alumni/core/di/injection.dart';
import 'package:athlete_alumni/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:athlete_alumni/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:athlete_alumni/features/profile/presentation/screens/profile_screen.dart';

import 'package:athlete_alumni/core/router/route_constants.dart';

// Import your screens here
// import 'package:athlete_alumni/features/athletes/presentation/pages/athletes_page.dart';
// import 'package:athlete_alumni/features/athletes/presentation/pages/athlete_detail_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/login_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/register_page.dart';
import 'package:athlete_alumni/features/home/presentation/pages/home_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteConstants.home,
  debugLogDiagnostics: true,
  
  // Refresh the router when auth state changes
  refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
  
  // Redirect based on authentication state
  redirect: (context, state) {
    // Development bypass
    // Check if this is a direct navigation from the Dev Login button
    final bool isDevBypass = state.extra != null && state.extra is Map && (state.extra as Map).containsKey('devBypass');
    
    // Skip all auth checks if this is a dev bypass
    if (isDevBypass) {
      print("Router: Dev bypass detected, skipping auth checks");
      return null; // Don't redirect
    }
    
    final isLoggedIn = _isAuthenticated();
    final isGoingToLogin = state.uri.path == RouteConstants.login || 
                          state.uri.path == RouteConstants.register;
    
    // If not logged in and not going to login/register, redirect to login
    if (!isLoggedIn && !isGoingToLogin) {
      return RouteConstants.login;
    }
    
    // If logged in and going to login/register, redirect to home
    if (isLoggedIn && isGoingToLogin) {
      return RouteConstants.home;
    }
    
    return null;
  },
  
  routes: [
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.register,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    
    // Profile routes
    GoRoute(
      path: RouteConstants.profileWithId,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        
        // Check if this is a dev bypass
        final bool isDevBypass = state.extra != null && state.extra is Map && (state.extra as Map).containsKey('devBypass');
        
        // If dev bypass, we don't check if it's own profile since there's no real authentication
        final isOwnProfile = isDevBypass ? true : _isOwnProfile(id);
        
        return BlocProvider(
          create: (context) => ProfileBloc(
            getProfileUseCase: sl<GetProfileUseCase>(),
            updateProfileUseCase: sl<UpdateProfileUseCase>(),
            uploadProfileImageUseCase: sl<UploadProfileImageUseCase>(),
          ),
          child: ProfileScreen(
            athleteId: id,
            isOwnProfile: isOwnProfile,
            isDevMode: isDevBypass,
          ),
        );
      },
    ),
    
    // My Profile - shortcut for current user
    GoRoute(
      path: RouteConstants.myProfile,
      redirect: (context, state) {
        // Check if this is a dev bypass
        final bool isDevBypass = state.extra != null && 
                                 state.extra is Map && 
                                 (state.extra as Map).containsKey('devBypass');
        
        // For dev bypass, use a mock ID
        if (isDevBypass) {
          print("MyProfile Route: Dev bypass detected, using mock ID");
          return '/profile/mock-id-123';
        }
        
        // Normal flow - check for authenticated user
        final currentUser = _getCurrentUser();
        if (currentUser != null) {
          return '/profile/${currentUser.id}';
        }
        
        return RouteConstants.login;
      },
    ),
  ],
  
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text('Page not found'),
    ),
  ),
);

// Helper to check if user is authenticated
bool _isAuthenticated() {
  final authState = sl<AuthBloc>().state;
  return authState.status == AuthStatus.authenticated;
}

// Helper to get the current user
Athlete? _getCurrentUser() {
  final authState = sl<AuthBloc>().state;
  if (authState.status == AuthStatus.authenticated) {
    return authState.athlete;
  }
  return null;
}

// Helper to check if a profile belongs to the current user
bool _isOwnProfile(String profileId) {
  final currentUser = _getCurrentUser();
  if (currentUser != null) {
    return currentUser.id == profileId;
  }
  return false;
}

// Helper to make BLoC streams work with GoRouter refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) : _stream = stream {
    _subscription = _stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}