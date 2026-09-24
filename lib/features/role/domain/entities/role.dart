class AppRole {
  const AppRole({
    required this.id,
    required this.name,
    this.description,
    required this.active,
  });

  final int id;
  final String name;
  final String? description;
  final bool active;
}

class AppPermission {
  const AppPermission({
    required this.id,
    required this.name,
    this.description,
    this.module,
  });

  final int id;
  final String name;
  final String? description;
  final String? module;
}

class RolePermissions {
  const RolePermissions({
    required this.role,
    required this.allPermissions,
    required this.assignedPermissionIds,
  });

  final AppRole role;
  final List<AppPermission> allPermissions;
  final Set<int> assignedPermissionIds;
}
