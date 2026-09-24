import 'package:app_movil_sistema/features/role/domain/entities/role.dart';

class AppRoleModel extends AppRole {
  const AppRoleModel({
    required super.id,
    required super.name,
    super.description,
    required super.active,
  });

  factory AppRoleModel.fromJson(Map<String, dynamic> json) => AppRoleModel(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    active: json['active'] as bool? ?? true,
  );
}

class AppPermissionModel extends AppPermission {
  const AppPermissionModel({
    required super.id,
    required super.name,
    super.description,
    super.module,
  });

  factory AppPermissionModel.fromJson(Map<String, dynamic> json) =>
      AppPermissionModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        module: json['module'] as String?,
      );
}

class RolePermissionsModel extends RolePermissions {
  const RolePermissionsModel({
    required super.role,
    required super.allPermissions,
    required super.assignedPermissionIds,
  });

  factory RolePermissionsModel.fromJson(Map<String, dynamic> json) {
    final assigned = (json['assignedPermissions'] as List<dynamic>? ?? const [])
        .map((item) => AppPermissionModel.fromJson(item as Map<String, dynamic>).id)
        .toSet();
    return RolePermissionsModel(
      role: AppRoleModel.fromJson(json['role'] as Map<String, dynamic>),
      allPermissions: (json['allPermissions'] as List<dynamic>? ?? const [])
          .map((item) => AppPermissionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      assignedPermissionIds: assigned,
    );
  }
}
