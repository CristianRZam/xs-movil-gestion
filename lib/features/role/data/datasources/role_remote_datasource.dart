import 'package:app_movil_sistema/features/role/data/models/role_model.dart';

import 'package:app_movil_sistema/features/role/domain/entities/role.dart';

abstract class RoleRemoteDataSource {
  Future<List<AppRoleModel>> getRoles();
  Future<AppRoleModel> create(RoleRequest request);
  Future<AppRoleModel> update(RoleRequest request);
  Future<void> updateStatus(int id);
  Future<RolePermissionsModel> getRolePermissions(int roleId);
  Future<void> updateRolePermissions({
    required int roleId,
    required Set<int> permissionIds,
  });
}
