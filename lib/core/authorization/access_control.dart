import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Stable capabilities shared by navigation, widgets and API operations.
enum AppCapability {
  operate,
  viewProducts,
  manageProducts,
  createProducts,
  deleteProducts,
  manageCategories,
  manageUsers,
  manageRoles,
  assignRolePermissions,
  manageInventory,
  inventoryCount,
  reports,
  dashboard,
  deleteOrders,
  notifications,
  cancelSales,
}

enum AuthorizationMode { roles, permissions }

/// JWT claims only drive client UX. The API must enforce authorization itself.
class AccessControl extends ChangeNotifier {
  AccessControl({
    this.mode = AuthorizationMode.roles,
    this.permissionRequirements = const {},
  });

  final AuthorizationMode mode;
  // Populate with the backend's permission codes when enabling permission mode.
  // Unmapped capabilities are denied in that mode; all listed codes are required.
  final Map<AppCapability, Set<String>> permissionRequirements;
  Set<String> _roles = {};
  Set<String> _permissions = {};
  DateTime? _expiresAt;
  Timer? _expiryTimer;

  bool get isAuthenticated =>
      _expiresAt != null && DateTime.now().isBefore(_expiresAt!);

  bool allows(AppCapability capability) {
    if (!isAuthenticated || _roles.isEmpty) return false;
    if (_roles.contains('SUPER_ADMIN')) return true;
    if (capability == AppCapability.operate) return true;
    if (mode == AuthorizationMode.roles) {
      return false;
    }
    final required = permissionRequirements[capability];
    return required != null &&
        required.isNotEmpty &&
        required.every(_permissions.contains);
  }

  void updateToken(String? token) {
    _expiryTimer?.cancel();
    _roles = {};
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
          _roles = _strings(claims['roles']);
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
