import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;

// NOTE: To fix the redirect_uri_mismatch error:
// 1. Go to Google Cloud Console: https://console.cloud.google.com/
// 2. Navigate to APIs & Services > Credentials
// 3. Find your OAuth 2.0 Client ID and click Edit
// 4. Under "Authorized redirect URIs", add these URIs:
//    - http://localhost
//    - http://localhost:3000
//    - https://your-domain.com (for production)
//    - The exact URI printed in the debug console when attempting sign-in
// 5. Click Save and wait a few minutes for changes to propagate

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // The CLIENT_ID from the Google Cloud Console
    clientId: kIsWeb ? '735463188812-jk93h4mn6l9pmphkm9vvggg7q4egpaai.apps.googleusercontent.com' : null,
    scopes: ['email', 'profile', 'openid'],
  );
  
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign In process');
      
      // For Web platform, use a different approach since signIn() is being deprecated
      if (kIsWeb) {
        return await _webSignIn();
      }
      
      // For mobile platforms, use the standard approach
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
      
      debugPrint('ID Token: ${idToken != null ? 'Present' : 'Not present'}');
      debugPrint('Access Token: ${accessToken != null ? 'Present' : 'Not present'}');
      
      if (idToken == null) {
        debugPrint('No ID Token found - this is likely due to browser cookie settings or missing gapi client');
        throw Exception('No ID Token found. Please ensure third-party cookies are enabled in your browser settings.');
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
  
  /// Web-specific Google Sign In approach using Supabase's OAuth flow
  Future<AuthResponse?> _webSignIn() async {
    try {
      debugPrint('Using Web-specific Google Sign In approach');
      
      // For web, we should use Supabase's OAuth provider directly
      // This will handle the redirect and token exchange properly
      
      // IMPORTANT: Use a redirect URI that's EXACTLY the same as what's configured in Google Cloud Console
      // Dynamic port-based localhost URIs won't work reliably with Google OAuth
      // Instead, use one of the standard URIs you've configured in Google Cloud Console
      const String redirectUri = 'http://localhost';  // Use exactly what's in your Google Cloud Console
      
      debugPrint('Using hard-coded redirect URI: $redirectUri');
      
      // Use Supabase's built-in OAuth flow for Google
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUri,
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );
      
      debugPrint('Supabase OAuth initiated successfully');
      
      // At this point, the user will be redirected to Google's login page,
      // and then back to your app. The session will be handled by Supabase's auth state listener.
      return null;
    } catch (e) {
      debugPrint('Error in web sign-in: $e');
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