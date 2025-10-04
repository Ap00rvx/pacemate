import 'package:equatable/equatable.dart';

import '../../domain/entities/user_profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.message,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
  }) => ProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    message: message,
  );

  @override
  List<Object?> get props => [status, profile, message];
}
