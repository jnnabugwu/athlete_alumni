import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:athlete_alumni/core/errors/exceptions.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/features/profile/data/datasources/profile_mock_data.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  /// Gets the profile of a specific athlete
  /// 
  /// Throws a [ServerException] for all error codes
  Future<Athlete> getProfile(String id);

  /// Updates the profile of an athlete
  /// 
  /// Throws a [ServerException] for all error codes
  Future<Athlete> updateProfile(Athlete athlete);

  /// Uploads a profile image for an athlete
  /// 
  /// Throws a [ServerException] for all error codes
  Future<String> uploadProfileImage(String athleteId, Uint8List imageBytes, String fileName);
  
  /// Gets the current authenticated user's ID
  /// 
  /// Returns null if not authenticated
  String? getCurrentUserId();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;
  
  /// Local storage key for athlete data - used for development fallback
  static const String _storageKey = 'athlete_alumni_mock_data';

  /// Flag to determine whether to use mock data or real Supabase database
  /// Set to false to use the real Supabase database
  static const bool _useMockData = false;

  ProfileRemoteDataSourceImpl({required this.supabaseClient});

  /// Gets the profile of a specific athlete from Supabase
  @override
  Future<Athlete> getProfile(String id) async {
    try {
      final bool useMockData = _useMockData; // Use the class constant
      
      // Use current authenticated user's ID if the ID is a temporary one
      final bool isTemporaryId = id.startsWith('user-') || 
                              id == 'unknown-user-id' ||
                              id == 'new-user';
                              
      // Get the current user's ID if the ID is temporary
      final String athleteId = isTemporaryId 
          ? getCurrentUserId() ?? id // Fallback to provided ID if not authenticated
          : id;
      
      debugPrint('ProfileRemoteDataSource: Getting profile for ID: $athleteId');
      
      if (useMockData) {
        // Development mode - use mock data
        await Future.delayed(const Duration(milliseconds: 800));
        final athlete = _getStoredAthleteById(athleteId) ?? 
                       ProfileMockData.getMockAthleteById(athleteId);
        
        if (athlete == null) {
          throw ServerException(message: 'Athlete not found', statusCode: 404);
        }
        
        return athlete;
      } else {
        // Production mode - use Supabase
        try {
          final response = await supabaseClient
              .from('athletes')
              .select()
              .eq('id', athleteId)
              .maybeSingle();
          
          if (response == null) {
            debugPrint('ProfileRemoteDataSource: No profile found for ID: $athleteId');
            throw ServerException(message: 'Athlete not found', statusCode: 404);
          }
          
          debugPrint('ProfileRemoteDataSource: Profile found: $response');
          return Athlete.fromJson(response);
        } catch (e) {
          debugPrint('ProfileRemoteDataSource: Error fetching profile from Supabase: $e');
          throw ServerException(
            message: 'Failed to fetch profile: ${e.toString()}', 
            statusCode: 500
          );
        }
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  /// Updates the profile of an athlete in Supabase
  @override
  Future<Athlete> updateProfile(Athlete athlete) async {
    try {
      final bool useMockData = _useMockData; // Use the class constant
      
      // Determine if this is a new or existing athlete
      final bool isTemporaryId = athlete.id.startsWith('user-') || 
                              athlete.id == 'unknown-user-id' ||
                              athlete.id == 'new-user';
      
      // For temporary IDs, get the actual authenticated user ID
      final String athleteId = isTemporaryId
          ? getCurrentUserId() ?? athlete.id // Fallback to temporary ID if not authenticated
          : athlete.id;
      
      debugPrint('ProfileRemoteDataSource: updateProfile - Original ID: ${athlete.id}, Using ID: $athleteId');
      
      if (isTemporaryId) {
        debugPrint('ProfileRemoteDataSource: Converting temporary ID to auth user ID: $athleteId');
      }
      
      // Create a copy of the athlete with the correct ID
      final Athlete athleteToSave = isTemporaryId
          ? athlete.copyWith(id: athleteId)
          : athlete;
      
      debugPrint('ProfileRemoteDataSource: Athlete data being saved: ${athleteToSave.toString()}');
      
      if (useMockData) {
        // Development mode - use localStorage
        await Future.delayed(const Duration(seconds: 1));
        
        // For development, save to localStorage
        _saveAthleteToStorage(athleteToSave);
        
        debugPrint('ProfileRemoteDataSource: Profile saved to localStorage: ${athleteToSave.id}');
        return athleteToSave;
      } else {
        // Production mode - use Supabase
        try {
          // Check if the athlete already exists
          final existingAthlete = await supabaseClient
              .from('athletes')
              .select()
              .eq('id', athleteId)
              .maybeSingle();
          
          debugPrint('ProfileRemoteDataSource: Existing athlete check result: ${existingAthlete != null ? "Found" : "Not found"}');
          
          Map<String, dynamic> athleteData = athleteToSave.toJson();
          debugPrint('ProfileRemoteDataSource: Athlete JSON before formatting: $athleteData');
          
          if (existingAthlete == null) {
            // Create a new athlete (INSERT)
            debugPrint('ProfileRemoteDataSource: Creating new athlete in Supabase: $athleteId');
            
            // Convert achievements and graduation year to proper format for Supabase
            final formattedData = _formatDataForSupabase(athleteData);
            debugPrint('ProfileRemoteDataSource: Formatted data for INSERT: $formattedData');
            
            // Check if any required fields are missing
            _validateRequiredFields(formattedData);
            
            // Insert the new athlete
            final response = await supabaseClient
                .from('athletes')
                .insert(formattedData)
                .select()
                .single();
            
            debugPrint('ProfileRemoteDataSource: New athlete created: ${response['id']}');
            debugPrint('ProfileRemoteDataSource: Full response: $response');
            return Athlete.fromJson(response);
          } else {
            // Update existing athlete (UPDATE)
            debugPrint('ProfileRemoteDataSource: Updating existing athlete in Supabase: $athleteId');
            
            // Convert achievements and graduation year to proper format for Supabase
            final formattedData = _formatDataForSupabase(athleteData);
            debugPrint('ProfileRemoteDataSource: Formatted data for UPDATE: $formattedData');
            
            // Check if any required fields are missing
            _validateRequiredFields(formattedData);
            
            // Update the athlete
            final response = await supabaseClient
                .from('athletes')
                .update(formattedData)
                .eq('id', athleteId)
                .select()
                .single();
            
            debugPrint('ProfileRemoteDataSource: Athlete updated: ${response['id']}');
            debugPrint('ProfileRemoteDataSource: Full response: $response');
            return Athlete.fromJson(response);
          }
        } catch (e) {
          debugPrint('ProfileRemoteDataSource: Error saving profile to Supabase: $e');
          throw ServerException(
            message: 'Failed to save profile: ${e.toString()}', 
            statusCode: 500
          );
        }
      }
    } catch (e) {
      debugPrint('ProfileRemoteDataSource: Error updating profile: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  /// Format data for Supabase compatibility
  Map<String, dynamic> _formatDataForSupabase(Map<String, dynamic> athleteData) {
    debugPrint('_formatDataForSupabase: Input athleteData: $athleteData');
    
    // Get auth user for username
    final currentUser = supabaseClient.auth.currentUser;
    String? username = null;
    
    if (currentUser != null && currentUser.userMetadata != null) {
      // Try to get username from user metadata
      username = currentUser.userMetadata!['username'] as String?;
      debugPrint('_formatDataForSupabase: Found username in metadata: $username');
    }
    
    // Create a result map with snake_case keys
    Map<String, dynamic> result = {
      'id': athleteData['id'],
      'full_name': athleteData['name'],
      'email': athleteData['email'],
      'username': username, // Add username from auth if available
      'athlete_status': athleteData['status']?.toString()?.split('.')?.last,
      'major': athleteData['major'],
      'career': athleteData['career'],
      'college': athleteData['university'],
      'sport': athleteData['sport'],
    };
    
    // Log field transformations
    debugPrint('_formatDataForSupabase: id = ${athleteData['id']}');
    debugPrint('_formatDataForSupabase: name -> full_name = ${athleteData['name']}');
    debugPrint('_formatDataForSupabase: email = ${athleteData['email']}');
    debugPrint('_formatDataForSupabase: username = $username');
    debugPrint('_formatDataForSupabase: status -> athlete_status = ${athleteData['status']?.toString()?.split('.')?.last}');
    debugPrint('_formatDataForSupabase: major = ${athleteData['major']}');
    debugPrint('_formatDataForSupabase: career = ${athleteData['career']}');
    debugPrint('_formatDataForSupabase: university -> college = ${athleteData['university']}');
    debugPrint('_formatDataForSupabase: sport = ${athleteData['sport']}');
    
    // If no username, use a default based on auth ID to avoid database errors
    if (username == null) {
      String defaultUsername = "user_${athleteData['id'].toString().substring(0, 8)}";
      result['username'] = defaultUsername;
      debugPrint('_formatDataForSupabase: No username found, using default: $defaultUsername');
    }
    
    // Only add profile_image_url if it exists
    if (athleteData['profileImageUrl'] != null) {
      result['profile_image_url'] = athleteData['profileImageUrl'];
      debugPrint('_formatDataForSupabase: profileImageUrl -> profile_image_url = ${athleteData['profileImageUrl']}');
    }
    
    // Only add achievements if it exists and is not empty
    if (athleteData['achievements'] != null && athleteData['achievements'] is List && (athleteData['achievements'] as List).isNotEmpty) {
      result['achievements'] = athleteData['achievements'];
      debugPrint('_formatDataForSupabase: achievements = ${athleteData['achievements']}');
    }
    
    // Only add graduation_year if it exists
    if (athleteData['graduationYear'] != null) {
      if (athleteData['graduationYear'] is DateTime) {
        result['graduation_year'] = (athleteData['graduationYear'] as DateTime).toIso8601String();
        debugPrint('_formatDataForSupabase: graduationYear -> graduation_year (DateTime) = ${(athleteData['graduationYear'] as DateTime).toIso8601String()}');
      } else if (athleteData['graduationYear'] is String) {
        result['graduation_year'] = athleteData['graduationYear'];
        debugPrint('_formatDataForSupabase: graduationYear -> graduation_year (String) = ${athleteData['graduationYear']}');
      }
    }
    
    // Remove any null values
    result.removeWhere((key, value) => value == null);
    
    debugPrint('_formatDataForSupabase: Final formatted data: $result');
    return result;
  }

  /// Uploads a profile image for an athlete to Supabase Storage
  @override
  Future<String> uploadProfileImage(String athleteId, Uint8List imageBytes, String fileName) async {
    try {
      final bool useMockData = _useMockData; // Use the class constant
      
      // Handle temporary IDs by getting the actual user ID
      final bool isTemporaryId = athleteId.startsWith('user-') || 
                              athleteId == 'unknown-user-id' ||
                              athleteId == 'new-user';
      
      final String actualAthleteId = isTemporaryId
          ? getCurrentUserId() ?? athleteId
          : athleteId;
      
      if (useMockData) {
        // Development mode - simulate upload
        await Future.delayed(const Duration(seconds: 2));
        
        // For mock purposes, generate a "fake" URL
        final randomId = DateTime.now().millisecondsSinceEpoch;
        final imageUrl = 'https://picsum.photos/id/$randomId/200/200';
        
        // Update the athlete's profile image in localStorage
        try {
          final athlete = await getProfile(actualAthleteId);
          final updatedAthlete = athlete.copyWith(profileImageUrl: imageUrl);
          await updateProfile(updatedAthlete);
        } catch (_) {
          // Ignore if athlete not found
        }
            
        return imageUrl;
      } else {
        // Production mode - use Supabase Storage
        try {
          debugPrint('ProfileRemoteDataSource: Uploading profile image for ID: $actualAthleteId');
          
          // Format the file path: profiles/user-id/filename
          final filePath = 'profiles/$actualAthleteId/$fileName';
          
          // Upload the image to Supabase Storage
          final response = await supabaseClient
              .storage
              .from('athlete_images') // Bucket name
              .uploadBinary(filePath, imageBytes, fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true
              ));
          
          // Get the public URL for the uploaded image
          final imageUrl = supabaseClient
              .storage
              .from('athlete_images')
              .getPublicUrl(filePath);
          
          debugPrint('ProfileRemoteDataSource: Image uploaded: $imageUrl');
          
          // Update the athlete's profile with the new image URL
          try {
            final athlete = await getProfile(actualAthleteId);
            final updatedAthlete = athlete.copyWith(profileImageUrl: imageUrl);
            await updateProfile(updatedAthlete);
          } catch (e) {
            debugPrint('ProfileRemoteDataSource: Error updating athlete with new image URL: $e');
            // Continue and return the URL even if we couldn't update the athlete
          }
          
          return imageUrl;
        } catch (e) {
          debugPrint('ProfileRemoteDataSource: Error uploading image to Supabase: $e');
          throw ServerException(
            message: 'Failed to upload image: ${e.toString()}', 
            statusCode: 500
          );
        }
      }
    } catch (e) {
      debugPrint('ProfileRemoteDataSource: Error in uploadProfileImage: $e');
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
  
  /// Gets the current authenticated user's ID
  @override
  String? getCurrentUserId() {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser != null) {
        debugPrint('ProfileRemoteDataSource: Current user ID: ${currentUser.id}');
        return currentUser.id;
      }
      debugPrint('ProfileRemoteDataSource: No authenticated user found');
      return null;
    } catch (e) {
      debugPrint('ProfileRemoteDataSource: Error getting current user ID: $e');
      return null;
    }
  }

  /// Helper method to save athlete data to localStorage (development only)
  void _saveAthleteToStorage(Athlete athlete) {
    try {
      // Get existing data
      final existingDataJson = html.window.localStorage[_storageKey];
      Map<String, dynamic> allData = {};
      
      if (existingDataJson != null) {
        allData = jsonDecode(existingDataJson) as Map<String, dynamic>;
      }
      
      // Convert athlete to a serializable format
      final athleteMap = athlete.toJson();
      
      // Update data for this athlete
      allData[athlete.id] = athleteMap;
      
      // Save back to localStorage
      html.window.localStorage[_storageKey] = jsonEncode(allData);
      
      debugPrint('ProfileRemoteDataSource: Athlete saved to localStorage: ${athlete.id}');
    } catch (e) {
      debugPrint('ProfileRemoteDataSource: Error saving athlete to storage: $e');
    }
  }

  /// Helper method to retrieve athlete data from localStorage (development only)
  Athlete? _getStoredAthleteById(String id) {
    try {
      final storedData = html.window.localStorage[_storageKey];
      if (storedData == null) return null;
      
      final allData = jsonDecode(storedData) as Map<String, dynamic>;
      if (!allData.containsKey(id)) return null;
      
      final athlete = Athlete.fromJson(allData[id] as Map<String, dynamic>);
      debugPrint('ProfileRemoteDataSource: Athlete loaded from localStorage: ${athlete.id}');
      return athlete;
    } catch (e) {
      debugPrint('ProfileRemoteDataSource: Error retrieving athlete from storage: $e');
      return null;
    }
  }

  // Helper method to validate required fields before database operations
  void _validateRequiredFields(Map<String, dynamic> data) {
    // Just check for required fields
    final requiredFields = ['id', 'full_name', 'email', 'athlete_status'];
    
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        debugPrint('WARNING: Required field missing: $field');
      }
    }
  }
} 