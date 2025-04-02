import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:athlete_alumni/core/errors/exceptions.dart';
import 'package:athlete_alumni/core/models/athlete.dart';
import 'package:athlete_alumni/features/profile/data/datasources/profile_mock_data.dart';
import 'package:injectable/injectable.dart';

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
}

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl();

  /// Local storage key for athlete data
  static const String _storageKey = 'athlete_alumni_mock_data';

  /// Gets the profile of a specific athlete
  /// 
  /// Currently using mock data for development
  @override
  Future<Athlete> getProfile(String id) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get mock data from localStorage if it exists, otherwise use default mock data
      final athlete = _getStoredAthleteById(id) ?? ProfileMockData.getMockAthleteById(id);
      
      if (athlete == null) {
        throw ServerException(message: 'Athlete not found', statusCode: 404);
      }
      
      return athlete;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  /// Updates the profile of an athlete
  /// 
  /// Currently using mock data stored in localStorage for development
  @override
  Future<Athlete> updateProfile(Athlete athlete) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update in localStorage
      _saveAthleteToStorage(athlete);
      
      return athlete;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  /// Uploads a profile image for an athlete
  /// 
  /// In this mock implementation, it returns a random URL
  @override
  Future<String> uploadProfileImage(String athleteId, Uint8List imageBytes, String fileName) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real implementation, we would upload the image to a server
      // For mock purposes, generate a "fake" URL
      final randomId = DateTime.now().millisecondsSinceEpoch;
      final imageUrl = 'https://picsum.photos/id/$randomId/200/200';
      
      // Update the athlete's profile image in localStorage
      final athlete = await getProfile(athleteId);
      final updatedAthlete = athlete.copyWith(profileImageUrl: imageUrl);
      await updateProfile(updatedAthlete);
          
      return imageUrl;
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  /// Helper method to save athlete data to localStorage
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
    } catch (e) {
      print('Error saving athlete to storage: $e');
    }
  }

  /// Helper method to retrieve athlete data from localStorage
  Athlete? _getStoredAthleteById(String id) {
    try {
      final storedData = html.window.localStorage[_storageKey];
      if (storedData == null) return null;
      
      final allData = jsonDecode(storedData) as Map<String, dynamic>;
      if (!allData.containsKey(id)) return null;
      
      return Athlete.fromJson(allData[id] as Map<String, dynamic>);
    } catch (e) {
      print('Error retrieving athlete from storage: $e');
      return null;
    }
  }
} 