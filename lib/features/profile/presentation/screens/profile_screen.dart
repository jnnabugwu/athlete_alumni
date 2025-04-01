import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../../../../core/di/injection.dart';
import '../bloc/profile_bloc.dart';
import '../pages/profile_page.dart';
import '../bloc/edit_profile_bloc.dart';
import '../screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String athleteId;
  final bool isOwnProfile;
  final bool isDevMode;
  
  const ProfileScreen({
    Key? key,
    required this.athleteId,
    required this.isOwnProfile,
    this.isDevMode = false,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    
    print("ProfileScreen.initState: isDevMode = ${widget.isDevMode}, athleteId = ${widget.athleteId}");
    
    if (widget.isDevMode) {
      print("ProfileScreen: Creating mock athlete for development mode");
      // Create mock athlete data for development mode
      final mockAthlete = Athlete(
        id: 'mock-id-123',
        name: 'Dev Test User',
        email: 'dev@example.com',
        status: AthleteStatus.current,
        major: 'Computer Science',
        career: 'Software Developer',
        profileImageUrl: 'https://via.placeholder.com/150',
        university: 'Dev University',
        sport: 'Basketball',
        achievements: ['Created with DevBypass', 'Testing Mode'],
        graduationYear: DateTime(2023),
      );
      
      print("ProfileScreen: Mock athlete created. Now will skip GetProfileEvent and directly emit ProfileLoaded");
      
      // Skip the network request altogether for dev mode
      // context.read<ProfileBloc>().add(GetProfileEvent(widget.athleteId));
      
      // Directly emit the ProfileLoaded state with the mock athlete
      Future.microtask(() {
        if (mounted) {
          print("ProfileScreen: Emitting mock athlete to ProfileBloc");
          context.read<ProfileBloc>().emit(ProfileLoaded(mockAthlete));
        }
      });
    } else {
      // Normal flow - fetch the real profile
      print("ProfileScreen: Normal flow - fetching real profile for ID: ${widget.athleteId}");
      context.read<ProfileBloc>().add(GetProfileEvent(widget.athleteId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        print("ProfileScreen: BlocConsumer listener - state: ${state.runtimeType}");
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
        }
      },
      builder: (context, state) {
        print("ProfileScreen: BlocConsumer builder - state: ${state.runtimeType}");
        if (state is ProfileLoading) {
          // Show loading indicator
          print("ProfileScreen: Rendering loading indicator");
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ProfileLoaded) {
          // Show profile page with loaded data
          print("ProfileScreen: Rendering ProfilePage with athlete: ${state.athlete}");
          return ProfilePage(
            athlete: state.athlete,
            isOwnProfile: widget.isOwnProfile,
            onEditPressed: widget.isOwnProfile 
              ? () => _navigateToEditProfile(context, state.athlete)
              : null,
          );
        } else if (state is ProfileError) {
          // Show error view
          print("ProfileScreen: Rendering error view: ${state.message}");
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
                        print("ProfileScreen: Try Again in dev mode - recreating mock athlete");
                        final mockAthlete = Athlete(
                          id: 'mock-id-123',
                          name: 'Dev Test User',
                          email: 'dev@example.com',
                          status: AthleteStatus.current,
                          major: 'Computer Science',
                          career: 'Software Developer',
                          profileImageUrl: 'https://via.placeholder.com/150',
                          university: 'Dev University',
                          sport: 'Basketball',
                          achievements: ['Created with DevBypass', 'Testing Mode'],
                          graduationYear: DateTime(2023),
                        );
                        context.read<ProfileBloc>().emit(ProfileLoaded(mockAthlete));
                      } else {
                        // Retry loading profile
                        print("ProfileScreen: Try Again in normal mode - retrying GetProfileEvent");
                        context.read<ProfileBloc>().add(GetProfileEvent(widget.athleteId));
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
        print("ProfileScreen: Rendering default loading view (initial state)");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  void _navigateToEditProfile(BuildContext context, Athlete athlete) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<EditProfileBloc>()
            ..add(InitializeEditProfileEvent(athlete)),
          child: EditProfileScreen(athlete: athlete),
        ),
      ),
    );
  }
} 