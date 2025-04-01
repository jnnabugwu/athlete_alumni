import 'package:equatable/equatable.dart';

/// Base class for exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final int statusCode;

  AppException({required this.message, required this.statusCode});

  @override
  String toString() => '$runtimeType: $message (status code: $statusCode)';
}

/// Exception thrown when there is a server error
class ServerException extends AppException {
  ServerException({required String message, required int statusCode}) 
      : super(message: message, statusCode: statusCode);
}

class CacheException extends Equatable implements Exception {
  const CacheException({required this.message, this.statusCode = 500});

  final String message;
  final int statusCode;

  @override
  List<dynamic> get props => [message, statusCode];
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
} 