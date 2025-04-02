import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

/// Abstract class defining network connectivity checking functionality
abstract class NetworkInfo {
  /// Checks if the device has an internet connection
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo that actually performs connectivity checks
@Injectable(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl();

  /// Checks internet connectivity by attempting to reach Google's DNS server
  /// Returns true if connection was successful, false otherwise
  @override
  Future<bool> get isConnected async {
    try {
      // Try to reach Google's public DNS
      final response = await http.get(Uri.parse('https://8.8.8.8'))
          .timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      // If any error occurs during the request, consider it as no connection
      return false;
    }
  }
}

/// A more robust implementation that attempts multiple reliable endpoints
@Named('robustNetworkInfo')
@Injectable(as: NetworkInfo)
class RobustNetworkInfoImpl implements NetworkInfo {
  RobustNetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    final endpoints = [
      'https://www.google.com',
      'https://www.cloudflare.com',
      'https://www.apple.com',
    ];
    
    // Try multiple endpoints to ensure more reliable connectivity check
    for (final endpoint in endpoints) {
      try {
        final response = await http.get(Uri.parse(endpoint))
            .timeout(const Duration(seconds: 3));
            
        if (response.statusCode == 200) {
          return true;
        }
      } catch (_) {
        // Continue trying other endpoints if this one fails
        continue;
      }
    }
    
    return false;
  }
}

/// Web-specific implementation that always returns true for simplicity
@Named('webNetworkInfo')
@Injectable(as: NetworkInfo)
class WebNetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For web app development, we'll just return true for simplicity
    // In a real app, you could use navigator.onLine but it's not always reliable
    return Future.value(true);
  }
}