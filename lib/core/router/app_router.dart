import 'dart:async';
import 'package:athlete_alumni/features/athletes/presentation/bloc/athlete_bloc.dart';
import 'package:athlete_alumni/features/athletes/presentation/bloc/filter_athletes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:athlete_alumni/core/di/injection.dart';
import 'package:athlete_alumni/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:athlete_alumni/features/profile/domain/usecases/upload_profile_image_usecase.dart';
import 'package:athlete_alumni/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:athlete_alumni/features/profile/presentation/screens/profile_screen.dart';
import 'package:athlete_alumni/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:athlete_alumni/features/profile/presentation/bloc/edit_profile_bloc.dart';

import 'package:athlete_alumni/core/router/route_constants.dart';

// Import your screens here
// import 'package:athlete_alumni/features/athletes/presentation/pages/athletes_page.dart';
// import 'package:athlete_alumni/features/athletes/presentation/pages/athlete_detail_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/login_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/register_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/password_reset_page.dart';
import 'package:athlete_alumni/features/auth/presentation/pages/password_reset_form_page.dart';
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
    
    // Check if the user is going to public routes that don't require authentication
    final isPublicRoute = state.uri.path == RouteConstants.login || 
                          state.uri.path == RouteConstants.register ||
                          state.uri.path == RouteConstants.passwordReset ||
                          state.uri.path.startsWith('/password-reset/');
    
    debugPrint("Router: isPublicRoute = $isPublicRoute for ${state.uri.path}");
    
    // If not logged in and not going to a public route, redirect to login
    if (!isLoggedIn && !isPublicRoute) {
      debugPrint("Router: Not logged in and not going to a public route, redirecting to login");
      return RouteConstants.login;
    }
    
    // If logged in and going to login/register, redirect to home
    if (isLoggedIn && (state.uri.path == RouteConstants.login || state.uri.path == RouteConstants.register)) {
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
    GoRoute(
      path: RouteConstants.passwordReset,
      builder: (context, state) => BlocProvider.value(
        value: sl<AuthBloc>(),
        child: const PasswordResetPage(),
      ),
    ),
    GoRoute(
      path: RouteConstants.passwordResetForm,
      builder: (context, state) {
        final token = state.pathParameters['token'] ?? '';
        return BlocProvider.value(
          value: sl<AuthBloc>(),
          child: PasswordResetFormPage(token: token),
        );
      },
    ),
    
    // Profile routes
    GoRoute(
      path: RouteConstants.profileWithId,
      name: 'profile',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        
        // Check if this is a dev bypass
        final bool isDevBypass = state.extra != null && state.extra is Map && (state.extra as Map).containsKey('devBypass');
        
        debugPrint("Profile Route: Building with id=$id, extras=${state.extra}");
        
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
          ),
        );
      },
      routes: [
        // Add a child route for editing profiles
        GoRoute(
          path: 'edit',
          name: 'editProfile',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            debugPrint("Edit Profile Route: Building with id=$id");
            
            // Check if this is a temporary user ID
            final bool isTemporaryId = id.startsWith('user-') || 
                                      id == 'unknown-user-id' ||
                                      id == 'new-user';
            
            // Create a new ProfileBloc instead of trying to access one from the parent context
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) {
                    final profileBloc = ProfileBloc(
                      getProfileUseCase: sl<GetProfileUseCase>(),
                      updateProfileUseCase: sl<UpdateProfileUseCase>(),
                      uploadProfileImageUseCase: sl<UploadProfileImageUseCase>(),
                    );
                    
                    if (isTemporaryId) {
                      // For temporary IDs, initialize a new profile
                      final authBloc = sl<AuthBloc>();
                      final authState = authBloc.state;
                      
                      // Extract email from auth state if available
                      final String? email = authState.status == AuthStatus.authenticated && 
                                         authState.athlete != null && 
                                         authState.athlete!.email != null && 
                                         authState.athlete!.email!.isNotEmpty
                          ? authState.athlete!.email
                          : null;
                          
                      // Extract username and other data from auth state
                      String? fullName = null;
                      String? username = null;
                      String? college = null;
                      AthleteStatus? athleteStatus = null;
                      
                      if (authState.status == AuthStatus.authenticated) {
                        // Try to get user metadata from auth session
                        final supabaseClient = sl<SupabaseClient>();
                        final currentUser = supabaseClient.auth.currentUser;
                        if (currentUser != null) {
                          final userData = currentUser.userMetadata;
                          if (userData != null) {
                            debugPrint("Edit Profile Route: Found user metadata: $userData");
                            fullName = userData['full_name'] as String?;
                            username = userData['username'] as String?;
                            college = userData['college'] as String?;
                            final statusStr = userData['athlete_status'] as String?;
                            if (statusStr != null) {
                              athleteStatus = statusStr == 'former' ? 
                                  AthleteStatus.former : AthleteStatus.current;
                            }
                          }
                          
                          // If metadata didn't have username, try getting from user
                          if (username == null) {
                            // We can't use await here, so we'll just use any data we already have
                            // and let the ProfileBloc handle fetching additional data
                            debugPrint("Edit Profile Route: Could not get username from metadata, will attempt fetch in ProfileBloc");
                          }
                        }
                      }
                     
                      // Provide defaults for username if not found to avoid database errors
                      if (username == null) {
                        username = "user_${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}";
                        debugPrint("Edit Profile Route: Generated default username: $username");
                      }
                          
                      debugPrint("Edit Profile Route: Initializing new profile for temporary ID: $id");
                      profileBloc.add(InitializeNewProfileEvent(
                        authUserId: id,
                        email: email,
                        fullName: fullName,
                        username: username,
                        college: college,
                        athleteStatus: athleteStatus,
                      ));
                    } else {
                      // For regular IDs, load the profile data
                      debugPrint("Edit Profile Route: Loading profile data for ID: $id");
                      profileBloc.add(GetProfileEvent(id));
                    }
                    
                    return profileBloc;
                  },
                ),
                BlocProvider(
                  create: (context) => sl<EditProfileBloc>(),
                ),
              ],
              child: Builder(
                builder: (context) {
                  // Use the Builder to get a context that has access to the ProfileBloc
                  return BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, profileState) {
                      if (profileState is ProfileLoaded) {
                        // Initialize the EditProfileBloc with the loaded athlete data
                        context.read<EditProfileBloc>().add(InitializeEditProfileEvent(profileState.athlete));
                        return EditProfileScreen(athlete: profileState.athlete);
                      }
                      
                      // Show loading indicator while the profile is loading
                      if (profileState is ProfileLoading) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('Loading Profile')),
                          body: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      // Handle error state - initialize with default data for new users
                      if (profileState is ProfileError && isTemporaryId) {
                        debugPrint("Edit Profile Route: Creating default athlete data for temporary ID: $id");
                        
                        // Create minimal athlete data for the form
                        final authBloc = sl<AuthBloc>();
                        final authState = authBloc.state;
                        final email = authState.status == AuthStatus.authenticated && 
                                      authState.athlete?.email != null ? 
                                      authState.athlete!.email : '';
                        
                        // Create a minimal athlete with just the ID and email
                        final defaultAthlete = Athlete(
                          id: id,
                          email: email,
                          name: '',
                          status: AthleteStatus.current,
                          major: AthleteMajor.other,
                          career: AthleteCareer.other,
                        );
                        
                        // Initialize the EditProfileBloc with the default athlete
                        context.read<EditProfileBloc>().add(InitializeEditProfileEvent(defaultAthlete));
                        return EditProfileScreen(athlete: defaultAthlete);
                      }
                      
                      // Show error screen if profile loading failed and it's not a new user
                      return Scaffold(
                        appBar: AppBar(title: const Text('Edit Profile')),
                        body: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Failed to load profile data'),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
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
          return '/profile/mock-id-123';
        }
        
        // Get the current auth state
        final authBloc = sl<AuthBloc>();
        final authState = authBloc.state;
        
        // We need to handle unauthenticated users
        if (authState.status == AuthStatus.unauthenticated) {
          debugPrint("MyProfile Route: User is not authenticated, redirecting to login");
          return RouteConstants.login;
        }
        
        // If we have athlete data with an ID, use that ID
        if (authState.athlete != null && authState.athlete!.id.isNotEmpty) {
          final athleteId = authState.athlete!.id;
          debugPrint("MyProfile Route: User has athlete ID: $athleteId, redirecting");
          return '/profile/$athleteId';
        } 
        
        // For authenticated users with no athlete data, generate a unique ID
        if (authState.status == AuthStatus.authenticated) {
          final uniqueId = 'user-${DateTime.now().millisecondsSinceEpoch}';
          debugPrint("MyProfile Route: Generating unique ID for user: $uniqueId");
          return '/profile/$uniqueId';
        }
        
        // Auth is still loading, use the builder to show loading screen
        debugPrint("MyProfile Route: Auth state is ${authState.status}, using loading screen");
        return state.uri.path; // Return current path to force using the builder
      },
      // Add a builder as a fallback to prevent it from being a redirect-only route
      builder: (context, state) {
        debugPrint("MyProfile Route: Builder called - this should only happen when loading auth state");
        // When auth is loading, show the ProfileLoadingScreen which will auto-navigate when auth is ready
        return const ProfileLoadingScreen();
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
  // Only return athlete if fully authenticated
  if (authState.status == AuthStatus.authenticated && authState.athlete != null) {
    return authState.athlete;
  }
  return null;
}

// Helper to check if a profile belongs to the current user
bool _isOwnProfile(String profileId) {
  final currentUser = _getCurrentUser();
  if (currentUser != null) {
    // First try a direct ID match
    if (currentUser.id == profileId) {
      return true;
    }
    
    // For Google Sign-In users, we also need to check the email
    // Since the router can't do async operations, we'll check the database in the ProfileScreen
    debugPrint('Router: Checking profile ID: $profileId vs. current user: ${currentUser.id}');
    
    // If the ID is a temp ID and we have authenticated user, consider it own profile
    if (profileId.startsWith('user-') || profileId == 'unknown-user-id') {
      debugPrint('Router: Temp ID detected, marking as own profile');
      return true;
    }
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

// Add this class at the end of the file, right before the last closing brace
class ProfileLoadingScreen extends StatefulWidget {
  const ProfileLoadingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen> {
  Timer? _navigationTimer;
  bool _hasAttemptedNavigation = false;

  @override
  void initState() {
    super.initState();
    // Schedule a single navigation attempt after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptDirectNavigation();
    });
  }
  
  void _attemptDirectNavigation() {
    if (_hasAttemptedNavigation) return;
    _hasAttemptedNavigation = true;
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Taking you to your profile...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Let's just check for athlete data directly
    final authBloc = sl<AuthBloc>();
    final authState = authBloc.state;
    
    // Delay slightly to let any state updates propagate
    _navigationTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      debugPrint("ProfileLoadingScreen: Direct navigation attempt");
      
      // Generate a profile ID - either use existing athlete ID or create a new unique one
      final String profileId = authState.athlete?.id.isNotEmpty == true
          ? authState.athlete!.id
          : 'user-${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint("ProfileLoadingScreen: Using profile ID: $profileId");
      context.go('/profile/$profileId');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text('Loading your profile...', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Please wait while we prepare your data', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Manual navigation attempt
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trying again...'),
                    duration: Duration(seconds: 1),
                  ),
                );
                
                // Generate a unique ID for the user
                final uniqueId = 'user-${DateTime.now().millisecondsSinceEpoch}';
                debugPrint("Retry button: Using generated profile ID: $uniqueId");
                
                // Navigate directly to profile with the unique ID
                context.go('/profile/$uniqueId');
              },
              child: const Text('Retry Navigation'),
            ),
          ],
        ),
      ),
    );
  }
}