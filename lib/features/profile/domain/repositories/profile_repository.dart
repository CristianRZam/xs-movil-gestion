import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, void>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmationPassword,
  });
}
