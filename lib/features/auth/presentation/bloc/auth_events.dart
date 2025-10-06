part of 'auth_bloc.dart';

/// Base class for all auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check initial authentication status
class InitialAuthEvent extends AuthEvent {
  const InitialAuthEvent();
}

/// Event to login user
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign up user
class SignupEvent extends AuthEvent {
  final String fullname;
  final String email;
  final String password;
  final String dob; // Date of birth in YYYY-MM-DD format
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String? location;
  final String? avatar;

  const SignupEvent({
    required this.fullname,
    required this.email,
    required this.password,
    required this.dob,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    this.location,
    this.avatar,
  });

  @override
  List<Object?> get props => [
    fullname,
    email,
    password,
    dob,
    gender,
    age,
    height,
    weight,
    location,
    avatar,
  ];
}

/// Event for Google check (Step 1 of Google auth)
class GoogleCheckEvent extends AuthEvent {
  final String googleId;
  final String email;

  const GoogleCheckEvent({required this.googleId, required this.email});

  @override
  List<Object?> get props => [googleId, email];
}

/// Event for Google signup (Step 2 of Google auth)
class GoogleSignupEvent extends AuthEvent {
  final String googleId;
  final String email;
  final String fullname;
  final String? avatar;
  final String dob; // Date of birth in YYYY-MM-DD format
  final String gender;
  final int age;
  final double height;
  final double weight;
  final String? location;

  const GoogleSignupEvent({
    required this.googleId,
    required this.email,
    required this.fullname,
    this.avatar,
    required this.dob,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    this.location,
  });

  @override
  List<Object?> get props => [
    googleId,
    email,
    fullname,
    avatar,
    dob,
    gender,
    age,
    height,
    weight,
    location,
  ];
}

/// Event to get user profile
class GetProfileEvent extends AuthEvent {
  const GetProfileEvent();
}

/// Event to update user profile
class UpdateProfileEvent extends AuthEvent {
  final String? fullname;
  final String? location;
  final String? avatar;
  final String? dob; // Date of birth in YYYY-MM-DD format
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;

  const UpdateProfileEvent({
    this.fullname,
    this.location,
    this.avatar,
    this.dob,
    this.gender,
    this.age,
    this.height,
    this.weight,
  });

  @override
  List<Object?> get props => [
    fullname,
    location,
    avatar,
    dob,
    gender,
    age,
    height,
    weight,
  ];
}

/// Event to check if email exists
class CheckEmailExistsEvent extends AuthEvent {
  final String email;

  const CheckEmailExistsEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to refresh access token
class RefreshTokenEvent extends AuthEvent {
  final String refreshToken;

  const RefreshTokenEvent({required this.refreshToken});

  @override
  List<Object?> get props => [refreshToken];
}

/// Event to logout user
class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

/// Event to clear error state
class ClearErrorEvent extends AuthEvent {
  const ClearErrorEvent();
}
