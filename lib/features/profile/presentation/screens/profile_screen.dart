import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/athlete.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_constants.dart';
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
  
  @override
  void initState() {
    super.initState();
    _profileBloc = sl<ProfileBloc>();
    
    if (widget.isDevMode) {
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
    context.push(RouteConstants.editProfile);
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
              ? () => _navigateToEditProfile()
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
                        print("ProfileScreen: Try Again in normal mode - retrying GetProfileEvent");
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
        print("ProfileScreen: Rendering default loading view (initial state)");
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
} 