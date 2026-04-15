import 'package:memoirly/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Stream<UserProfile> watchProfile();

  Future<void> saveProfile(UserProfile profile);
}
