import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';
import 'package:app_movil_sistema/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';

class GetUsersUseCase {
  GetUsersUseCase(this._repo);
  final UserRepository _repo;
  Future<Either<Failure, List<AppUser>>> call(UserFilter filter) =>
      _repo.getUsers(filter);
}

class GetUserFormUseCase {
  GetUserFormUseCase(this._repo);
  final UserRepository _repo;
  Future<Either<Failure, UserFormData>> call([int? id]) =>
      _repo.getFormData(id);
}

class CreateUserUseCase {
  CreateUserUseCase(this._repo);
  final UserRepository _repo;
  Future<Either<Failure, AppUser>> call(UserRequest request) =>
      _repo.create(request);
}

class UpdateUserUseCase {
  UpdateUserUseCase(this._repo);
  final UserRepository _repo;
  Future<Either<Failure, AppUser>> call(UserRequest request) =>
      _repo.update(request);
}

class UpdateUserStatusUseCase {
  UpdateUserStatusUseCase(this._repo);
  final UserRepository _repo;
  Future<Either<Failure, void>> call(int id) => _repo.updateStatus(id);
}
