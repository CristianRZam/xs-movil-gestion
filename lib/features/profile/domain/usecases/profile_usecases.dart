import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/profile/domain/entities/user_profile.dart';
import 'package:app_movil_sistema/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Either<Failure, UserProfile>> call() => _repository.getProfile();
}

class UpdateProfilePasswordUseCase {
  const UpdateProfilePasswordUseCase(this._repository);
  final ProfileRepository _repository;
  Future<Either<Failure, void>> call({
    required String oldPassword,
    required String newPassword,
    required String confirmationPassword,
  }) => _repository.updatePassword(
    oldPassword: oldPassword,
    newPassword: newPassword,
    confirmationPassword: confirmationPassword,
  );
}
