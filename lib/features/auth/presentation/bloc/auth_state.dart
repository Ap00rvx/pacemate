part of 'auth_bloc.dart';

/// Authentication states
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  googleSignupRequired, // New state for when Google user needs to complete signup
}

/// Data needed for Google signup step
class GoogleSignupData extends Equatable {
  final String email;
  final String googleId;

  const GoogleSignupData({required this.email, required this.googleId});

  @override
  List<Object?> get props => [email, googleId];
}

/// Authentication state
class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final ProfileModel? profile;
  final String? message;
  final bool isNewUser;
  final GoogleSignupData? googleSignupData;
  final bool? emailExists;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.profile,
    this.message,
    this.isNewUser = false,
    this.googleSignupData,
    this.emailExists,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? message,
    bool? isNewUser,
    ProfileModel? profile,
    GoogleSignupData? googleSignupData,
    bool? emailExists,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
      isNewUser: isNewUser ?? this.isNewUser,
      googleSignupData: googleSignupData,
      emailExists: emailExists,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    message,
    isNewUser,
    googleSignupData,
    emailExists,
  ];
}
