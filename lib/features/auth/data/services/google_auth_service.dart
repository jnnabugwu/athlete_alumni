import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // The CLIENT_ID from the Google Cloud Console
    clientId: kIsWeb ? '735463188812-jk93h4mn6l9pmphkm9vvggg7q4egpaai.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile'],
  );
  
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign In process');
      
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('User canceled the sign-in flow');
        return null; // User canceled the sign-in flow
      }
      
      debugPrint('Google User signed in: ${googleUser.email}');
      
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Get ID token and access token
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      
      if (idToken == null) {
        debugPrint('No ID Token found');
        throw Exception('No ID Token found');
      }
      
      debugPrint('ID Token obtained, signing in with Supabase');
      
      // Use Supabase OAuth sign in with Google credentials
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      debugPrint('Supabase auth response received: User ID: ${response.user?.id}');
      
      return response;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabaseClient.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
} 