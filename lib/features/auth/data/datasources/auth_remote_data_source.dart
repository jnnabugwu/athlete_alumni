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
    String? fullName,
    String? username,
    String? college,
    AthleteStatus? athleteStatus,
  });

  Future<void> signOut();
  
  Future<bool> isSignedIn();
  
  Future<Athlete?> getCurrentAthlete();
  
  Future<void> sendPasswordResetEmail(String email);
  
  Future<void> resetPassword(String password, String token);
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
      
      // Store user metadata if not already present
      try {
        if (response.user!.userMetadata == null || response.user!.userMetadata!.isEmpty) {
          debugPrint('📝 Updating user metadata for future profile creation');
          // Update user metadata with at least email
          await supabaseClient.auth.updateUser(UserAttributes(
            data: {
              'email': email,
              'login_count': 1,
              'last_login': DateTime.now().toIso8601String(),
            }
          ));
        } else {
          debugPrint('📝 User already has metadata: ${response.user!.userMetadata}');
          // Update login count
          final currentCount = response.user!.userMetadata!['login_count'] ?? 0;
          await supabaseClient.auth.updateUser(UserAttributes(
            data: {
              'login_count': currentCount + 1,
              'last_login': DateTime.now().toIso8601String(),
            }
          ));
        }
      } catch (metaError) {
        // Don't fail login due to metadata issues
        debugPrint('⚠️ Could not update user metadata: $metaError');
      }
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
    String? fullName,
    String? username,
    String? college,
    AthleteStatus? athleteStatus,
  }) async {
    try {
      debugPrint('📝 STEP 1: Attempting registration with email: $email');
      if (fullName != null) debugPrint('Name: $fullName');
      if (college != null) debugPrint('College: $college');
      if (athleteStatus != null) debugPrint('Status: ${athleteStatus.name}');
      
      // Step 1: Create auth user with very detailed error handling
      AuthResponse? authResponse;
      String? userId;
      try {
        debugPrint('🔑 STEP 2: Creating Supabase auth user...');
        authResponse = await supabaseClient.auth.signUp(
          email: email,
          password: password,
          data: {
            'email': email,
            'full_name': fullName,
            'username': username,
            'college': college,
            'athlete_status': athleteStatus?.name,
            'registration_date': DateTime.now().toIso8601String(),
          }
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
        throw AuthException('Auth user creation failed: ${authError.toString()}');
      }
      
      // Note: We're not creating the athlete profile here anymore
      // That will be done later when the user completes their profile
      debugPrint('✅ STEP 5: Auth user created successfully. Profile will be created later.');
      
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
      
      debugPrint('🔍 Checking for athlete profile for user ID: ${user.id} and email: ${user.email}');

      try {
        // Try to get existing athlete profile
        final response = await supabaseClient
            .from('athletes')
            .select()
            .eq('id', user.id)
            .maybeSingle();
            
        if (response != null) {
          debugPrint('✅ Found existing athlete profile');
          return Athlete.fromJson(response);
        }
        
        // No profile found, try to create one from auth metadata
        debugPrint('⚠️ No athlete profile found, attempting to create one from auth metadata');
        
        // Get user metadata
        final metadata = user.userMetadata;
        
        // Extract available fields from metadata
        final String? fullName = metadata?['full_name'] as String?;
        String? username = metadata?['username'] as String?;
        final String? college = metadata?['college'] as String?;
        final String? athleteStatusStr = metadata?['athlete_status'] as String?;
        
        // Generate a default username if none is found
        if (username == null || username.isEmpty) {
          debugPrint('⚠️ No username found, generating default username');
          // Use email prefix or a random string as username
          username = user.email?.split('@').first ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
          
          // Ensure it's unique by adding a timestamp
          username = '${username}_${DateTime.now().millisecondsSinceEpoch % 10000}';
          
          debugPrint('📝 Generated username: $username');
          
          // Try to update the metadata with the generated username
          try {
            await supabaseClient.auth.updateUser(UserAttributes(
              data: {
                'username': username,
              }
            ));
          } catch (e) {
            debugPrint('⚠️ Could not update user metadata with generated username: $e');
          }
        }
        
        // Create minimal athlete data
        final athleteData = {
          'id': user.id,
          'email': user.email,
          'full_name': fullName ?? user.email?.split('@').first ?? 'User',
          'username': username,
          'college': college,
          'athlete_status': athleteStatusStr ?? 'current',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        debugPrint('📋 Creating athlete profile from metadata: $athleteData');
        
        // Try to create the profile
        try {
          final insertResponse = await supabaseClient
              .from('athletes')
              .insert(athleteData)
              .select()
              .maybeSingle();
              
          if (insertResponse != null) {
            debugPrint('✅ Created athlete profile from metadata');
            return Athlete.fromJson(insertResponse);
          }
        } catch (insertError) {
          debugPrint('❌ Error creating athlete profile: $insertError');
        }
        
        // If we get here, we couldn't create a profile
        return null;
      } catch (e) {
        debugPrint('❌ Error in getCurrentAthlete: $e');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in getCurrentAthlete: $e');
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

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('🔑 Sending password reset email to: $email');
      
      // Get the app's base URL - in a real app, this should be configured
      // based on your deployment environment
      String baseUrl = kDebugMode ? 'http://localhost:3000' : 'https://adak-14f54.web.app';
      
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: '$baseUrl/password-reset/recovery', // This URL should match your route structure
      );
      debugPrint('✅ Password reset email sent successfully');
      debugPrint('📧 Reset link will redirect to: $baseUrl/password-reset/recovery');
    } catch (e) {
      debugPrint('❌ Failed to send password reset email: $e');
      throw AuthException('Failed to send password reset email: ${e.toString()}');
    }
  }
  
  @override
  Future<void> resetPassword(String password, String token) async {
    try {
      debugPrint('🔑 Resetting password with token');
      
      // If we have a token, we should update the user's password with that token
      // Otherwise, we assume the user is already authenticated (from the reset link click)
      if (token.isNotEmpty) {
        // Process with token from URL
        await supabaseClient.auth.verifyOTP(
          token: token,
          type: OtpType.recovery,
        );
      }
      
      // Once authenticated or verified, update the password
      await supabaseClient.auth.updateUser(
        UserAttributes(password: password),
      );
      
      debugPrint('✅ Password reset successfully');
    } catch (e) {
      debugPrint('❌ Failed to reset password: $e');
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }
}
