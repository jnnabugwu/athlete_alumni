import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.imageUrl,
    required super.createdAt,
    required super.lastSignInAt,
    required super.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSignInAt: DateTime.parse(json['last_sign_in_at'] as String),
      isEmailVerified: json['is_email_verified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt.toIso8601String(),
      'is_email_verified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? lastSignInAt,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  // Create an empty user for testing/mock data
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      fullName: '',
      imageUrl: null,
      createdAt: DateTime.now(),
      lastSignInAt: DateTime.now(),
      isEmailVerified: false,
    );
  }

  // Create a mock user for development
  factory UserModel.mock() {
    return UserModel(
      id: 'mock-user-id',
      email: 'mock@example.com',
      fullName: 'Mock User',
      imageUrl: 'https://picsum.photos/200',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      lastSignInAt: DateTime.now(),
      isEmailVerified: true,
    );
  }
}
