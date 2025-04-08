import 'package:athlete_alumni/core/utils/typedef.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/models/athlete.dart';
import '../../../../core/errors/failures.dart';

class GetProfileUseCase {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
ResultFuture<Athlete> call(String userId) async {
    try {
      debugPrint('GetProfileUseCase: Attempting to get profile for user ID: $userId');
      
      // First, try to get by ID
      var response = await _supabaseClient
          .from('athletes')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      // If not found and ID looks like a temp ID, check current user
      if (response == null && (userId.startsWith('user-') || userId == 'unknown-user-id')) {
        final currentUser = _supabaseClient.auth.currentUser;
        
        if (currentUser != null) {
          debugPrint('GetProfileUseCase: Using current user ID instead: ${currentUser.id}');
          
          // Try to find by auth user ID
          response = await _supabaseClient
              .from('athletes')
              .select()
              .eq('id', currentUser.id)
              .maybeSingle();
              
          // If still not found and we have email (Google Sign-In case), try by email
          if (response == null && currentUser.email != null) {
            debugPrint('GetProfileUseCase: Trying to find profile by email: ${currentUser.email}');
            
            response = await _supabaseClient
                .from('athletes')
                .select()
                .eq('email', currentUser.email.toString())
                .maybeSingle();
          }
        }
      }
      
      if (response != null) {
        debugPrint('GetProfileUseCase: Found profile data: $response');
        return Right(Athlete.fromJson(response));
      } else {
        debugPrint('GetProfileUseCase: No profile found for user ID: $userId');
        return const Left(ServerFailure(message: 'Profile not found'));
      }
    } catch (e) {
      debugPrint('GetProfileUseCase: Error getting profile: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }
} 