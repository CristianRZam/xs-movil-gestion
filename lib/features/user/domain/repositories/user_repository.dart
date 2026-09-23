import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, List<AppUser>>> getUsers(UserFilter filter);
  Future<Either<Failure, UserFormData>> getFormData([int? id]);
  Future<Either<Failure, AppUser>> create(UserRequest request);
  Future<Either<Failure, AppUser>> update(UserRequest request);
  Future<Either<Failure, void>> updateStatus(int id);
}
