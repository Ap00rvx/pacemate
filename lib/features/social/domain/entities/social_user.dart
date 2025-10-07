import 'package:equatable/equatable.dart';

class SocialUser extends Equatable {
  final String id;
  final String fullname;
  final String? avatar; // nullable
  final String? location;

  const SocialUser({
    required this.id,
    required this.fullname,
    this.avatar,
    this.location,
  });

  @override
  List<Object?> get props => [id, fullname, avatar, location];
}

class ViewProfile extends Equatable {
  final SocialUser user;
  final bool isFriend;

  const ViewProfile({required this.user, required this.isFriend});

  @override
  List<Object?> get props => [user, isFriend];
}
