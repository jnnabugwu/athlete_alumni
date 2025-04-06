import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/athlete.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../pages/profile_page.dart';


class ProfileScreen extends StatefulWidget {
  final String? athleteId;
  final bool isOwnProfile;
  final bool isDevMode;
  
  const ProfileScreen({
    Key? key,
    this.athleteId,
    this.isOwnProfile = false,
    this.isDevMode = false,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileBloc _profileBloc;
  late final AuthBloc _authBloc;
  bool _isNewUser = false;
  
  @override
  void initState() {
    super.initState();
    _profileBloc = context.read<ProfileBloc>();
    _authBloc = sl<AuthBloc>();
    
    // Check if the ID looks like a temporary user ID (not an athlete ID yet)
    final bool isTemporaryId = widget.athleteId != null && 
                              (widget.athleteId!.startsWith('user-') || 
                               widget.athleteId! == 'unknown-user-id' ||
                               widget.athleteId! == 'new-user');
    
    if (isTemporaryId) {
      _isNewUser = true;
      // Get the auth user ID from AuthBloc
      final authBloc = sl<AuthBloc>();
      final authState = authBloc.state;
      
      // Extract the user ID from the athlete object if available, or use the provided ID
      final String userId = authState.status == AuthStatus.authenticated && 
                           authState.athlete != null && 
                           authState.athlete!.id.isNotEmpty
          ? authState.athlete!.id
          : widget.athleteId ?? 'unknown-user-id';
          
      final String? email = authState.status == AuthStatus.authenticated && 
                           authState.athlete != null && 
                           authState.athlete!.email != null && 
                           authState.athlete!.email!.isNotEmpty
          ? authState.athlete!.email
          : null;
      
      // Initialize a new profile
      _profileBloc.add(InitializeNewProfileEvent(
        authUserId: userId,
        email: email,
      ));
      
      debugPrint('ProfileScreen: Initializing new profile for user ID: $userId');
    } else if (widget.isDevMode) {
      // Use mock data for development
      const mockAthlete = Athlete(
        id: 'mock-id-123',
        name: 'Dev Test Athlete',
        email: 'dev@test.com',
        status: AthleteStatus.former,
        major: AthleteMajor.computerScience,
        career: AthleteCareer.softwareEngineer,
        university: 'Dev University',
        sport: 'Swimming',
        achievements: ['NCAA Championship', 'All-American', 'Team Captain'],
        profileImageUrl: 'https://placehold.co/300x300',
      );
      
      _profileBloc.add(const MockProfileLoadedEvent(mockAthlete));
    } else {
      // Get real profile data
      _profileBloc.add(GetProfileEvent(widget.athleteId ?? ''));
    }
  }
  
  @override
  void dispose() {
    //_profileBloc.close();
    super.dispose();
  }
  
  void _navigateToEditProfile() {
    // Get the current athlete ID from the profile state
    String athleteId = widget.athleteId ?? 'unknown';
    
    if (_profileBloc.state is ProfileLoaded) {
      final loadedState = _profileBloc.state as ProfileLoaded;
      athleteId = loadedState.athlete.id;
    }
    
    // Use the GoRouter's pushNamed method with the route name and parameters
    debugPrint("ProfileScreen: Navigating to edit profile for ID: $athleteId");
    
    // Show a brief indicator that we're handling the edit action
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening edit profile...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    context.pushNamed(
      'editProfile',  
      pathParameters: {'id': athleteId},
    );
  }

  // Determine if this is the user's own profile
  bool _determineIsOwnProfile() {
    // First check the explicit widget property
    if (widget.isOwnProfile) {
      return true;
    }
    
    // If we're in development mode, allow editing
    if (widget.isDevMode) {
      return true;
    }
    
    // Check if the current user matches the profile being viewed
    final authBloc = sl<AuthBloc>();
    final authState = authBloc.state;
    
    if (authState.status == AuthStatus.authenticated && 
        authState.athlete != null && 
        widget.athleteId != null) {
      // Compare the IDs to determine if this is the user's own profile
      return authState.athlete!.id == widget.athleteId;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Get the current determination if this is the user's own profile
    final bool isOwnProfile = _determineIsOwnProfile();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc),
        BlocProvider.value(value: _authBloc),
      ],
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          debugPrint("ProfileScreen: BlocConsumer listener - state: ${state.runtimeType}");
          if (state is ProfileUpdateSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          } else if (state is ProfileUpdateFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update profile: ${state.message}')),
            );
          } else if (state is ProfileImageUploadSuccess) {
            // Show success message for image upload
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile image uploaded successfully')),
            );
          } else if (state is ProfileImageUploadFailure) {
            // Show error message for image upload
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: ${state.message}')),
            );
          } else if (state is ProfileError) {
            // Show general error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          } else if (state is ProfileLoaded && _isNewUser) {
            // If this is a new user and we just loaded an empty profile,
            // automatically navigate to edit mode
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToEditProfile();
            });
          }
        },
        builder: (context, state) {
          debugPrint("ProfileScreen: BlocConsumer builder - state: ${state.runtimeType}");
          if (state is ProfileLoading) {
            // Show loading indicator
            debugPrint("ProfileScreen: Rendering loading indicator");
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is ProfileLoaded) {
            // Show profile page with loaded data
            debugPrint("ProfileScreen: Rendering ProfilePage with athlete: ${state.athlete}");
            
            return ProfilePage(
              athlete: state.athlete,
              isOwnProfile: isOwnProfile,
              onEditPressed: () => _navigateToEditProfile(),
            );
          } else if (state is ProfileError) {
            // Show error view
            debugPrint("ProfileScreen: Rendering error view: ${state.message}");
            return Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Failed to load profile: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.isDevMode) {
                          // In dev mode, create and emit mock data again
                          debugPrint("ProfileScreen: Try Again in dev mode - recreating mock athlete");
                          final mockAthlete = Athlete(
                            id: 'mock-id-123',
                            name: 'Dev Test User',
                            email: 'dev@example.com',
                            status: AthleteStatus.current,
                            major: AthleteMajor.computerScience,
                            career: AthleteCareer.softwareEngineer,
                            profileImageUrl: 'https://via.placeholder.com/150',
                            university: 'Dev University',
                            sport: 'Basketball',
                            achievements: ['Created with DevBypass', 'Testing Mode'],
                            graduationYear: DateTime(2023),
                          );
                          _profileBloc.emit(ProfileLoaded(mockAthlete));
                        } else {
                          // Retry loading profile
                          debugPrint("ProfileScreen: Try Again in normal mode - retrying GetProfileEvent");
                          _profileBloc.add(GetProfileEvent(widget.athleteId ?? ''));
                        }
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Show loading by default
          debugPrint("ProfileScreen: Rendering default loading view (initial state)");
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
} 