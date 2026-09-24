import 'package:app_movil_sistema/features/role/data/models/role_model.dart';

abstract class RoleRemoteDataSource {
  Future<List<AppRoleModel>> getRoles();
  Future<RolePermissionsModel> getRolePermissions(int roleId);
  Future<void> updateRolePermissions({
    required int roleId,
    required Set<int> permissionIds,
  });
}
