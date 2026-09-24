import 'access_control.dart';

/// Maps existing API operations to the same capabilities used by the UI.
/// POST /product/init is a query, not a product mutation.
class ApiAccessPolicy {
  static AppCapability requiredFor(String path, String method) {
    final segments = Uri.parse(
      path,
    ).path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return AppCapability.operate;
    final resource = segments.first;
    if (resource == 'reports') return AppCapability.reports;
    if (resource == 'notifications') return AppCapability.notifications;
    // The backend selects GLOBAL or PERSONAL from the authenticated user.
    if (resource == 'dashboard' &&
        segments.length == 1 &&
        method.toUpperCase() == 'GET') {
      return AppCapability.operate;
    }
    if (resource == 'dashboard') return AppCapability.dashboard;
    if (resource == 'inventory-counts') return AppCapability.inventoryCount;
    if (resource == 'parameter') return AppCapability.manageCategories;
    if (resource == 'user') return AppCapability.manageUsers;
    if (resource == 'role') return AppCapability.manageRoles;
    if (resource == 'permission') {
      return method.toUpperCase() == 'PUT'
          ? AppCapability.assignRolePermissions
          : AppCapability.manageRoles;
    }
    if (resource == 'product') {
      final verb = method.toUpperCase();
      if (segments.length == 2 &&
          segments[1] == 'init' &&
          verb == 'POST') {
        return AppCapability.viewProducts;
      }
      if (segments.length == 2 && segments[1] == 'create') {
        return AppCapability.createProducts;
      }
      if (segments.length >= 2 && segments[1] == 'delete') {
        return AppCapability.deleteProducts;
      }
      if (segments.length == 2 &&
          (segments[1] == 'update' || segments[1] == 'update-status')) {
        return AppCapability.manageProducts;
      }
      if (segments.length == 2 &&
          segments[1] == 'init-form' &&
          verb == 'POST') {
        return AppCapability.createProducts;
      }
    }
    if (resource == 'inventory-movement' && method.toUpperCase() != 'GET') {
      return AppCapability.manageInventory;
    }
    if (resource == 'orders' && method.toUpperCase() == 'DELETE') {
      return AppCapability.deleteOrders;
    }
    return AppCapability.operate;
  }
}
