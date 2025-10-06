import 'package:equatable/equatable.dart';
import '../model/user_model.dart';

/// Authentication response containing user data and tokens
class AuthResponse extends Equatable {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;
  final String? refreshToken;
  final bool? isNewUser;

  const AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.refreshToken,
    this.isNewUser,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: data?['user'] != null ? UserModel.fromJson(data!['user']) : null,
      token: data?['token'],
      refreshToken: data?['refreshToken'],
      isNewUser: data?['isNewUser'],
    );
  }

  @override
  List<Object?> get props => [
    success,
    message,
    user,
    token,
    refreshToken,
    isNewUser,
  ];
}

/// Google check response for step 1 of Google authentication
class GoogleCheckResponse extends Equatable {
  final bool success;
  final String message;
  final bool userExists;
  final UserModel? user;
  final String? token;
  final String? refreshToken;
  final String? email;
  final String? googleId;

  const GoogleCheckResponse({
    required this.success,
    required this.message,
    required this.userExists,
    this.user,
    this.token,
    this.refreshToken,
    this.email,
    this.googleId,
  });

  factory GoogleCheckResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return GoogleCheckResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userExists: data?['userExists'] ?? false,
      user: data?['user'] != null ? UserModel.fromJson(data!['user']) : null,
      token: data?['token'],
      refreshToken: data?['refreshToken'],
      email: data?['email'],
      googleId: data?['googleId'],
    );
  }

  @override
  List<Object?> get props => [
    success,
    message,
    userExists,
    user,
    token,
    refreshToken,
    email,
    googleId,
  ];
}

/// Token response for refresh token operation
class TokenResponse extends Equatable {
  final bool success;
  final String message;
  final String? token;
  final String? refreshToken;

  const TokenResponse({
    required this.success,
    required this.message,
    this.token,
    this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return TokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: data?['token'],
      refreshToken: data?['refreshToken'],
    );
  }

  @override
  List<Object?> get props => [success, message, token, refreshToken];
}

/// Email check response
class EmailCheckResponse extends Equatable {
  final bool success;
  final String message;
  final bool exists;
  final String email;

  const EmailCheckResponse({
    required this.success,
    required this.message,
    required this.exists,
    required this.email,
  });

  factory EmailCheckResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return EmailCheckResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      exists: data?['exists'] ?? false,
      email: data?['email'] ?? '',
    );
  }

  @override
  List<Object?> get props => [success, message, exists, email];
}

/// Profile response
class ProfileResponse extends Equatable {
  final bool success;
  final String message;
  final UserModel? user;

  const ProfileResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: data?['user'] != null ? UserModel.fromJson(data!['user']) : null,
    );
  }

  @override
  List<Object?> get props => [success, message, user];
}
