import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime lastSignInAt;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.imageUrl,
    required this.createdAt,
    required this.lastSignInAt,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        imageUrl,
        createdAt,
        lastSignInAt,
        isEmailVerified,
      ];
}
