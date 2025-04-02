import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Failure caused by a server error
class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

/// Failure caused by network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

/// Failure caused by cache-related issues
class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

/// Failure that occurs when data is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);
}

/// Failure that occurs for general, unexpected errors
class GeneralFailure extends Failure {
  const GeneralFailure({required String message}) : super(message: message);
}
