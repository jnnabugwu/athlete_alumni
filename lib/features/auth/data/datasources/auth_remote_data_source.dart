import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:flutter/foundation.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/core/errors/exceptions.dart';


abstract class AuthRemoteDataSource {
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String college,
    required AthleteStatus athleteStatus,
  });

  Future<void> signOut();
  
  Future<bool> isSignedIn();
  
  Future<Athlete?> getCurrentAthlete();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting login with email: $email');
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        debugPrint('❌ Login failed: User is null');
        throw const AuthException('Failed to sign in');
      }
      
      debugPrint('✅ Login successful: User ID ${response.user!.id}');
    } on AuthException catch (e) {
      debugPrint('❌ AuthException during login: ${e.message}');
      throw AuthException(e.message);
    } catch (e) {
      debugPrint('❌ Unexpected error during login: $e');
      throw AuthException('Authentication error: ${e.toString()}');
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String college,
    required AthleteStatus athleteStatus,
  }) async {
    try {
      debugPrint('📝 STEP 1: Attempting registration with email: $email, name: $fullName');
      
      // Step 1: Create auth user with very detailed error handling
      AuthResponse? authResponse;
      String? userId;
      try {
        debugPrint('🔑 STEP 2: Creating Supabase auth user...');
        authResponse = await supabaseClient.auth.signUp(
          email: email,
          password: password,
        );
        
        // Detailed logging of the auth response
        debugPrint('📄 STEP 3: Auth response details:');
        debugPrint('- Session exists: ${authResponse.session != null}');
        debugPrint('- User exists: ${authResponse.user != null}');
        
        if (authResponse.user == null) {
          debugPrint('❌ STEP 3a: Registration failed: User is null');
          throw const AuthException('Failed to create account - user is null');
        }
        
        userId = authResponse.user!.id;
        debugPrint('✅ STEP 4: Auth user created with ID: $userId');
        
      } catch (authError) {
        debugPrint('❌ STEP ERROR: Auth creation failed: $authError');
        debugPrint('❌ Error type: ${authError.runtimeType}');
        debugPrint('❌ Error message: ${authResponse.toString()}');
        throw AuthException('Auth user creation failed: ${authError.toString()}');
      }
      
      // Step 2: Only proceed to profile creation if we have a valid user
      if (userId != null) {
        debugPrint('📊 STEP 5: Creating athlete profile in database');
        try {
          // Create athlete data
          final athleteData = {
            'id': userId,
            'email': email,
            'full_name': fullName,
            'username': username,
            'college': college,
            'athlete_status': athleteStatus.name,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          debugPrint('📋 STEP 6: Athlete data prepared: $athleteData');
          
          // Attempt to insert profile data with explicit timeout
          try {
            debugPrint('⏱️ STEP 7: Inserting profile data with 10-second timeout');
            await supabaseClient.from('athletes')
                .insert(athleteData)
                .timeout(const Duration(seconds: 10));
            debugPrint('✅ STEP 8: Athlete profile created successfully');
          } catch (profileError) {
            debugPrint('⚠️ STEP ERROR: Database error creating athlete profile: $profileError');
            debugPrint('⚠️ Error type: ${profileError.runtimeType}');
            
            // Don't rethrow - still allow auth to succeed
            // Mark user as needing profile completion later
            try {
              debugPrint('🔄 STEP 9: Setting metadata flag for profile creation needed');
              await supabaseClient.auth.updateUser(UserAttributes(
                data: {'profile_pending': true}
              ));
              debugPrint('✅ STEP 10: User metadata updated to indicate profile pending');
            } catch (metaError) {
              debugPrint('⚠️ STEP ERROR: Could not set profile metadata: $metaError');
            }
          }
        } catch (wrapperError) {
          debugPrint('⚠️ STEP ERROR: Outer wrapper error in profile creation: $wrapperError');
          // Still don't fail the auth process
        }
      }
      
      // If we've made it this far, consider the registration successful
      // even if the profile wasn't created
      debugPrint('✅ STEP FINAL: Registration completed successfully');
      
    } catch (e) {
      debugPrint('❌ MAIN ERROR: Unexpected error during registration: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      if (e.toString().contains('JSON')) {
        debugPrint('🔍 This appears to be a JSON parsing error. Check Supabase credentials and connection.');
      } else if (e.toString().contains('network')) {
        debugPrint('🔍 This appears to be a network error. Check internet connection.');
      }
      
      throw AuthException('Registration error: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw const AuthException('Failed to sign out');
    }
  }

  @override
  Future<bool> isSignedIn() async {
    return supabaseClient.auth.currentUser != null;
  }

  @override
  Future<Athlete?> getCurrentAthlete() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      final response = await supabaseClient
          .from('athletes')
          .select()
          .eq('id', user.id)
          .single();

      return Athlete.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Add a method to test connection
  Future<bool> testConnection() async {
    try {
      debugPrint('🔍 Testing Supabase connection...');
      
      // Try a simple query that doesn't require auth
      final response = await supabaseClient.from('_test_connection')
          .select('*')
          .limit(1)
          .maybeSingle();
      
      debugPrint('✅ Connection test received response (even if error): $response');
      return true;
    } catch (e) {
      // Log the error details to help diagnose
      debugPrint('❌ Connection test error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      if (e.toString().contains('network')) {
        debugPrint('🌐 This appears to be a network connectivity issue');
      } else if (e.toString().contains('permission')) {
        debugPrint('🔒 This appears to be a permissions issue');
      }
      
      return false;
    }
  }
}
