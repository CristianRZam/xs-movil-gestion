import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:app_movil_sistema/features/role/domain/repositories/role_repository.dart';
import 'package:dartz/dartz.dart';

class GetRolesUseCase {
  const GetRolesUseCase(this._repository);
  final RoleRepository _repository;
  Future<Either<Failure, List<AppRole>>> call() => _repository.getRoles();
}

class GetRolePermissionsUseCase {
  const GetRolePermissionsUseCase(this._repository);
  final RoleRepository _repository;
  Future<Either<Failure, RolePermissions>> call(int roleId) =>
      _repository.getRolePermissions(roleId);
}

class UpdateRolePermissionsUseCase {
  const UpdateRolePermissionsUseCase(this._repository);
  final RoleRepository _repository;
  Future<Either<Failure, void>> call({
    required int roleId,
    required Set<int> permissionIds,
  }) => _repository.updateRolePermissions(
    roleId: roleId,
    permissionIds: permissionIds,
  );
}
