import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/athlete.dart';
import '../bloc/edit_profile_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../pages/profile_edit_page.dart';

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
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          
          // Navigate back
          Navigator.of(context).pop();
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