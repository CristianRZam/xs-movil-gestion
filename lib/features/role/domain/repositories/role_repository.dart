import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/features/role/domain/entities/role.dart';
import 'package:dartz/dartz.dart';

abstract class RoleRepository {
  Future<Either<Failure, List<AppRole>>> getRoles();
  Future<Either<Failure, RolePermissions>> getRolePermissions(int roleId);
  Future<Either<Failure, void>> updateRolePermissions({
    required int roleId,
    required Set<int> permissionIds,
  });
}
