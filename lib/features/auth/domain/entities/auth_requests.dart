import 'package:equatable/equatable.dart';

/// Request model for user login
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  List<Object?> get props => [email, password];
}

/// Request model for user signup
class SignupRequest extends Equatable {
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

  const SignupRequest({
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

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullname,
      'email': email,
      'password': password,
      'dob': dob,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      if (location != null) 'location': location,
      if (avatar != null) 'avatar': avatar,
    };
  }

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

/// Request model for Google check (Step 1)
class GoogleCheckRequest extends Equatable {
  final String googleId;
  final String email;

  const GoogleCheckRequest({required this.googleId, required this.email});

  Map<String, dynamic> toJson() {
    return {'googleId': googleId, 'email': email};
  }

  @override
  List<Object?> get props => [googleId, email];
}

/// Request model for Google signup (Step 2)
class GoogleSignupRequest extends Equatable {
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

  const GoogleSignupRequest({
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

  Map<String, dynamic> toJson() {
    return {
      'googleId': googleId,
      'email': email,
      'fullname': fullname,
      if (avatar != null) 'avatar': avatar,
      'dob': dob,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      if (location != null) 'location': location,
    };
  }

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

/// Request model for profile update
class UpdateProfileRequest extends Equatable {
  final String? fullname;
  final String? location;
  final String? avatar;
  final String? dob; // Date of birth in YYYY-MM-DD format
  final String? gender;
  final int? age;
  final double? height;
  final double? weight;

  const UpdateProfileRequest({
    this.fullname,
    this.location,
    this.avatar,
    this.dob,
    this.gender,
    this.age,
    this.height,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (fullname != null) json['fullname'] = fullname;
    if (location != null) json['location'] = location;
    if (avatar != null) json['avatar'] = avatar;
    if (dob != null) json['dob'] = dob;
    if (gender != null) json['gender'] = gender;
    if (age != null) json['age'] = age;
    if (height != null) json['height'] = height;
    if (weight != null) json['weight'] = weight;
    return json;
  }

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

/// Request model for token refresh
class RefreshTokenRequest extends Equatable {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }

  @override
  List<Object?> get props => [refreshToken];
}
