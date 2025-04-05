import 'dart:async';
import 'package:athlete_alumni/features/athletes/presentation/bloc/athlete_bloc.dart';
import 'package:athlete_alumni/features/athletes/presentation/bloc/filter_athletes_bloc.dart';
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
import 'package:athlete_alumni/features/athletes/presentation/pages/athletes_page.dart';

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
    debugPrint("Router.redirect called for path: ${state.uri.path}");
    debugPrint("Router.redirect extra: ${state.extra}");
    
    // Development bypass
    final bool isDevBypass = state.extra != null && 
                             state.extra is Map && 
                             (state.extra as Map).containsKey('devBypass') &&
                             (state.extra as Map)['devBypass'] == true;
    
    if (isDevBypass) {
      debugPrint("Router: Dev bypass detected, skipping auth checks");
      return null;
    }

    // Get current auth state
    final authBloc = sl<AuthBloc>();
    final authState = authBloc.state;
    final authStatus = authState.status;
    debugPrint("Router: Current auth status = $authStatus");
    
    // Don't redirect while we're waiting for the auth state
    if (authStatus == AuthStatus.initial || authStatus == AuthStatus.loading) {
      debugPrint("Router: Auth state is $authStatus, waiting for final state");
      return null;
    }
    
    final isLoggedIn = authStatus == AuthStatus.authenticated;
    debugPrint("Router: isLoggedIn = $isLoggedIn");
    
    final isGoingToLogin = state.uri.path == RouteConstants.login || 
                          state.uri.path == RouteConstants.register;
    
    // If not logged in and not going to login/register, redirect to login
    if (!isLoggedIn && !isGoingToLogin) {
      debugPrint("Router: Not logged in and not going to login/register, redirecting to login");
      return RouteConstants.login;
    }
    
    // If logged in and going to login/register, redirect to home
    if (isLoggedIn && isGoingToLogin) {
      debugPrint("Router: Logged in and going to login/register, redirecting to home");
      return RouteConstants.home;
    }
    
    debugPrint("Router: No redirect needed for ${state.uri.path}");
    return null;
  },
  
  routes: [
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => BlocProvider.value(
        value: sl<AuthBloc>(),
        child: const HomePage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => BlocProvider.value(
        value: sl<AuthBloc>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.register,
      builder: (context, state) => BlocProvider.value(
        value: sl<AuthBloc>(),
        child: const RegisterPage(),
      ),
    ),
    
    // Profile routes
    GoRoute(
      path: RouteConstants.profileWithId,
      name: 'profile',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        
        // Check if this is a dev bypass
        final bool isDevBypass = state.extra != null && state.extra is Map && (state.extra as Map).containsKey('devBypass');
        
        debugPrint("Profile Route: Building with id=$id, isDevBypass=$isDevBypass, extras=${state.extra}");
        
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
        debugPrint("MyProfile.redirect called with extra: ${state.extra}");
        
        // Check if this is a dev bypass
        final bool isDevBypass = state.extra != null && 
                                 state.extra is Map && 
                                 (state.extra as Map).containsKey('devBypass') &&
                                 (state.extra as Map)['devBypass'] == true;
        
        // For dev bypass, use a mock ID
        if (isDevBypass) {
          debugPrint("MyProfile Route: Dev bypass detected, using mock ID");
          // Just return the path - the redirect method will preserve the extras
          return '/profile/mock-id-123';
        }
        
        // Normal flow - check for authenticated user
        final currentUser = _getCurrentUser();
        if (currentUser != null) {
          debugPrint("MyProfile Route: Using current user ID: ${currentUser.id}");
          return '/profile/${currentUser.id}';
        }
        
        debugPrint("MyProfile Route: No current user, redirecting to login");
        return RouteConstants.login;
      },
    ),

    // Athletes route
    GoRoute(
      path: RouteConstants.athletes,
      builder: (context, state) {
        final bool isDevBypass = state.extra != null && 
                               state.extra is Map && 
                               (state.extra as Map).containsKey('devBypass');
        
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => sl<AthleteBloc>(),
            ),
            BlocProvider(
              create: (_) => sl<FilterAthletesBloc>(),
            ),
            // Add any other BLoCs needed by the AthletesPage
          ],
          child: const AthletesPage(),
        );
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