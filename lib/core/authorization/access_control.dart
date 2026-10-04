import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Stable capabilities shared by navigation, widgets and API operations.
enum AppCapability {
  operate,
  viewProducts,
  viewProductMovements,
  manageProducts,
  createProducts,
  deleteProducts,
  createProductInventoryEntry,
  createProductWaste,
  adjustProductInventory,
  viewCashSession,
  openCashSession,
  closeCashSession,
  viewCashSessionHistory,
  viewCashSessionSales,
  viewInventoryCount,
  createInventoryCount,
  reviewInventoryCount,
  closeInventoryCount,
  viewInventoryCountHistory,
  viewOrders,
  createOrders,
  editOrders,
  updateOrderStatus,
  viewSales,
  createSales,
  // Conservada para compatibilidad de pruebas y flujos aún no migrados.
  manageInventory,
  manageCategories,
  manageUsers,
  manageRoles,
  assignRolePermissions,
  inventoryCount,
  reports,
  dashboard,
  deleteOrders,
  notifications,
  cancelSales,
}

/// JWT claims only drive client UX. The API must enforce authorization itself.
class AccessControl extends ChangeNotifier {
  AccessControl({this.permissionRequirements = const {}});

  /// Roles are profile metadata outside this service; permissions are the only
  /// access source used for navigation, widgets and API requests.
  final Map<AppCapability, Set<String>> permissionRequirements;
  Set<String> _permissions = {};
  DateTime? _expiresAt;
  Timer? _expiryTimer;

  bool get isAuthenticated =>
      _expiresAt != null && DateTime.now().isBefore(_expiresAt!);

  bool hasPermission(String permission) =>
      isAuthenticated && _permissions.contains(permission);

  bool hasAllPermissions(Iterable<String> permissions) =>
      isAuthenticated &&
      permissions.isNotEmpty &&
      permissions.every(_permissions.contains);

  bool hasAnyPermission(Iterable<String> permissions) =>
      isAuthenticated && permissions.any(_permissions.contains);

  bool allows(AppCapability capability) {
    if (!isAuthenticated || _permissions.isEmpty) return false;
    if (capability == AppCapability.operate) return true;
    final required = permissionRequirements[capability];
    // Capacidades aún no vinculadas a un permiso del backend quedan libres
    // durante la implementación progresiva de la matriz de permisos.
    return required == null || required.isEmpty || hasAllPermissions(required);
  }

  void updateToken(String? token) {
    _expiryTimer?.cancel();
    _permissions = {};
    _expiresAt = null;
    try {
      final claims = JwtDecoder.decode(token ?? '');
      final expiry = claims['exp'];
      if (expiry is num && expiry.isFinite && claims['active'] != false) {
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          (expiry * 1000).toInt(),
        );
        if (expiresAt.isAfter(DateTime.now())) {
          _permissions = _strings(claims['permissions']);
          _expiresAt = expiresAt;
          _expiryTimer = Timer(expiresAt.difference(DateTime.now()), clear);
        }
      }
    } catch (_) {
      // Malformed or missing tokens never grant access.
    }
    notifyListeners();
  }

  Set<String> _strings(Object? value) => value is List
      ? value.whereType<String>().where((v) => v.isNotEmpty).toSet()
      : <String>{};

  void clear() => updateToken(null);

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
