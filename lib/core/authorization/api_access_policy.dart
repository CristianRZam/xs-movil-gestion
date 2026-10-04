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
    if (resource == 'dashboard' &&
        segments.length == 1 &&
        method.toUpperCase() == 'GET') {
      return AppCapability.dashboard;
    }
    if (resource == 'dashboard') return AppCapability.dashboard;
    if (resource == 'inventory-counts') {
      final verb = method.toUpperCase();
      if (verb == 'POST' && segments.length == 1) {
        return AppCapability.createInventoryCount;
      }
      if (verb == 'PUT' && segments.length >= 3 && segments[2] == 'review') {
        return AppCapability.reviewInventoryCount;
      }
      if (verb == 'PUT' && segments.length >= 3 && segments[2] == 'close') {
        return AppCapability.closeInventoryCount;
      }
      if (verb == 'GET' &&
          segments.length >= 2 &&
          segments[1] == 'current') {
        return AppCapability.viewInventoryCount;
      }
      if (verb == 'GET' && segments.length == 1) {
        return AppCapability.viewInventoryCountHistory;
      }
      return AppCapability.viewInventoryCount;
    }
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
      if (segments.length == 2 && segments[1] == 'init' && verb == 'POST') {
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
    if (resource == 'inventory-movement') {
      if (method.toUpperCase() == 'GET' &&
          segments.length >= 2 &&
          segments[1] == 'product') {
        return AppCapability.viewProductMovements;
      }
      return AppCapability.operate;
    }
    if (resource == 'cash-session') {
      final verb = method.toUpperCase();
      if (verb == 'GET' &&
          segments.length >= 2 &&
          segments[1] == 'exists-open') {
        return AppCapability.operate;
      }
      if (verb == 'POST' && segments.length >= 2 && segments[1] == 'open') {
        return AppCapability.openCashSession;
      }
      if (verb == 'PUT' && segments.length >= 2 && segments[1] == 'close') {
        return AppCapability.closeCashSession;
      }
      if (verb == 'GET' && segments.length >= 2 && segments[1] == 'history') {
        return AppCapability.viewCashSessionHistory;
      }
      return AppCapability.viewCashSession;
    }
    if (resource == 'sales' &&
        segments.length >= 2 &&
        segments[1] == 'cash-session') {
      return AppCapability.viewCashSessionSales;
    }
    if (resource == 'sales') {
      final verb = method.toUpperCase();
      if (verb == 'GET') return AppCapability.viewSales;
      if (verb == 'POST' && segments.length >= 3 && segments[2] == 'cancel') {
        return AppCapability.cancelSales;
      }
      if (verb == 'POST' && segments.length == 1) {
        return AppCapability.createSales;
      }
    }
    if (resource == 'orders') {
      final verb = method.toUpperCase();
      if (verb == 'GET') return AppCapability.viewOrders;
      if (verb == 'POST' && segments.length == 1) {
        return AppCapability.createOrders;
      }
      if (verb == 'PUT' && segments.length >= 3 && segments[2] == 'status') {
        return AppCapability.updateOrderStatus;
      }
      if (verb == 'PUT') return AppCapability.editOrders;
      if (verb == 'DELETE') return AppCapability.deleteOrders;
    }
    return AppCapability.operate;
  }
}
