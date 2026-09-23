import 'package:app_movil_sistema/features/profile/data/models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmationPassword,
  });
}
