import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:js' as js;
import 'dart:async';

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
  // Use a lazily initialized singleton pattern for GoogleSignIn
  static GoogleSignIn? _instance;
  
  // Get the GoogleSignIn instance, creating it if it doesn't exist
  GoogleSignIn get _googleSignIn {
    _instance ??= GoogleSignIn(
      // The CLIENT_ID from the Google Cloud Console
      clientId: kIsWeb ? '735463188812-jk93h4mn6l9pmphkm9vvggg7q4egpaai.apps.googleusercontent.com' : null,
      scopes: ['email', 'profile', 'openid'],
    );
    return _instance!;
  }
  
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  /// Check if we were redirected from OAuth and handle the session
  Future<bool> checkForRedirectSession() async {
    if (kIsWeb) {
      try {
        debugPrint('🧪 Checking for OAuth redirect...');
        
        // Get the current URL
        final url = Uri.base.toString();
        
        // Check for auth-related parameters in the URL
        final hasAuthParams = url.contains('access_token=') || 
                            url.contains('refresh_token=') || 
                            url.contains('code=');
        
        if (hasAuthParams) {
          debugPrint('🔗 Found URL with auth parameters: $url');
          
          // Simple approach: Just let Supabase handle the auth parameters
          try {
            // 1. Let Supabase handle the URL parsing
            await _supabaseClient.auth.getSessionFromUrl(Uri.parse(url));
            
            // 2. Clear the URL
            _cleanUrl();
            
            // 3. Verify we have a session
            final hasSession = _supabaseClient.auth.currentSession != null;
            
            if (hasSession) {
              final user = _supabaseClient.auth.currentUser;
              debugPrint('✅ Successfully established auth session. User: ${user?.email}');
              return true;
            } else {
              debugPrint('❌ Failed to establish auth session despite valid URL parameters');
              return false;
            }
          } catch (e) {
            debugPrint('❌ Error handling auth URL: $e');
            return false;
          }
        }
        
        // No auth parameters in URL, check if we have a session anyway
        final currentSession = _supabaseClient.auth.currentSession;
        if (currentSession != null) {
          debugPrint('✅ No redirect detected, but found existing session for: ${currentSession.user.email}');
          return true;
        }
        
        debugPrint('❌ No auth parameters in URL and no existing session');
        return false;
      } catch (e) {
        debugPrint('❌ Error in checkForRedirectSession: $e');
        return false;
      }
    }
    return false;
  }
  
  /// Clean the URL by removing auth parameters
  void _cleanUrl() {
    if (kIsWeb) {
      try {
        // Get just the path portion of the current URL
        final cleanUrl = Uri.base.origin + Uri.base.path;
        js.context['history'].callMethod('replaceState', [null, '', cleanUrl]);
        debugPrint('🧹 URL cleaned: $cleanUrl');
      } catch (e) {
        debugPrint('❌ Error cleaning URL: $e');
      }
    }
  }
  
  /// Utility method to extract access token from URL
  String _extractTokenFromUrl(String url) {
    final uri = Uri.parse(url);
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];
    
    debugPrint('🔑 URL contains access_token: ${accessToken != null}');
    debugPrint('🔑 URL contains refresh_token: ${refreshToken != null}');
    
    if (accessToken != null) {
      return accessToken;
    }
    
    // For OAuth redirects, the token might be in the fragment
    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final params = Uri.splitQueryString(fragment);
      return params['access_token'] ?? '';
    }
    
    return '';
  }
  
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
      
      // Get the current origin for our app to redirect back to
      String redirectUrl;
      final origin = Uri.base.origin;
      
      // For production environments, we should use the actual deployed URL
      // This checks if we're running on localhost
      if (origin.contains('localhost')) {
        // Development environment
        redirectUrl = '$origin/';
        debugPrint('📱 DEVELOPMENT: Using localhost redirect: $redirectUrl');
      } else {
        // Production environment - use explicit production URL
        // Replace this with your actual production URL
        final productionUrl = origin;
        redirectUrl = '$productionUrl/';
        debugPrint('🌎 PRODUCTION: Using production redirect: $redirectUrl');
      }
      
      debugPrint('Will redirect back to: $redirectUrl');
      
      // Use Supabase's built-in OAuth flow for Google
      final response = await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        // Specify where to redirect after Supabase completes the authentication 
        redirectTo: redirectUrl,
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );
      
      debugPrint('Supabase OAuth initiated successfully');
      
      // At this point, the user will be redirected to Google's login page,
      // and then back to your app via Supabase. The session will be handled by Supabase.
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
  
  /// Utility method to diagnose authentication issues
  Future<void> debugAuthState() async {
    try {
      debugPrint('🔍 AUTH DIAGNOSTICS 🔍');
      
      // Check current session
      final currentSession = _supabaseClient.auth.currentSession;
      debugPrint('👤 Has current session: ${currentSession != null}');
      
      if (currentSession != null) {
        debugPrint('📧 User email: ${currentSession.user.email ?? 'Not available'}');
        debugPrint('🆔 User ID: ${currentSession.user.id}');
        debugPrint('⏰ Session expires at: ${currentSession.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(currentSession.expiresAt! * 1000) : 'Unknown'}');
        
        // Check for access and refresh tokens
        debugPrint('🔑 Access token present: ${currentSession.accessToken.isNotEmpty}');
        debugPrint('🔄 Refresh token present: ${currentSession.refreshToken?.isNotEmpty ?? false}');
      }
      
      // Check current user
      final currentUser = _supabaseClient.auth.currentUser;
      debugPrint('👤 Has current user: ${currentUser != null}');
      
      if (currentUser != null) {
        debugPrint('📧 User email: ${currentUser.email ?? 'Not available'}');
        debugPrint('🆔 User ID: ${currentUser.id}');
        debugPrint('✅ Email confirmed: ${currentUser.emailConfirmedAt != null}');
        debugPrint('📱 Phone confirmed: ${currentUser.phoneConfirmedAt != null}');
      }
      
      // Check if these match
      if (currentSession != null && currentUser != null) {
        final sessionMatchesUser = currentSession.user.id == currentUser.id;
        debugPrint('🔄 Session user matches current user: $sessionMatchesUser');
      }
      
      debugPrint('🔍 END AUTH DIAGNOSTICS 🔍');
    } catch (e) {
      debugPrint('❌ Error in debugAuthState: $e');
    }
  }
} 