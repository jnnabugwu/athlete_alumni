import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/athlete.dart';
import '../../../../core/di/injection.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../bloc/edit_profile_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../pages/profile_edit_page.dart';

//TODO: understand this screen decrepancy later
class EditProfileScreen extends StatelessWidget {
  final Athlete athlete;
  
  const EditProfileScreen({
    Key? key,
    required this.athlete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state is EditProfileSaveSuccess) {
          // Update the profile bloc with new data
          context.read<ProfileBloc>().add(UpdateProfileEvent(state.athlete));
          
          // Also update the auth bloc with the new athlete profile
          final authBloc = sl<AuthBloc>();
          authBloc.add(UpdateAthleteProfile(state.athlete));
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          
          // Explicitly navigate to the profile page instead of just popping
          debugPrint('EditProfileScreen: Navigating to profile page with ID: ${state.athlete.id}');
          context.go('/profile/${state.athlete.id}');
        } else if (state is EditProfileSaveFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is EditProfileSaving) {
          // Show saving indicator
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving changes...'),
                ],
              ),
            ),
          );
        } else if (state is EditProfileLoaded || state is EditProfileInitial) {
          // If loaded state, use that data, otherwise use the initial athlete
          final currentAthlete = state is EditProfileLoaded ? state.athlete : athlete;
          
          return ProfileEditPage(
            athlete: currentAthlete,
            onSave: (updatedAthlete) {
              // Dispatch save event to bloc
              context.read<EditProfileBloc>().add(SaveProfileEvent(updatedAthlete));
            },
          );
        }
        
        // Default loading state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
} 