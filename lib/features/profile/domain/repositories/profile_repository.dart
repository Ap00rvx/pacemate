import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> fetchProfile();
}
