import 'dart:convert';

import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/authorization/api_access_policy.dart';
import 'package:flutter_test/flutter_test.dart';

String token(Map<String, Object?> claims) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256'})}.${encode(claims)}.signature';
}

Map<String, Object?> claims(List<String> permissions) => {
  // Los roles son información de perfil: no intervienen en autorización.
  'roles': ['EMPLEADO'],
  'permissions': permissions,
  'exp':
      DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
      1000,
  'active': true,
};

void main() {
  late AccessControl access;

  setUp(
    () => access = AccessControl(
      permissionRequirements: const {
        AppCapability.viewProducts: {'VIEW_PRODUCT'},
        AppCapability.viewProductMovements: {'VIEW_PRODUCT_MOVEMENT'},
        AppCapability.manageInventory: {'EDIT_PRODUCT'},
      },
    ),
  );
  tearDown(() => access.dispose());

  test('roles do not grant access without permissions', () {
    access.updateToken(token(claims([])));
    expect(access.allows(AppCapability.viewProducts), isFalse);
    expect(access.allows(AppCapability.operate), isFalse);
  });

  test('permissions grant only their mapped capabilities', () {
    access.updateToken(token(claims(['VIEW_PRODUCT'])));
    expect(access.allows(AppCapability.viewProducts), isTrue);
    expect(access.allows(AppCapability.viewProductMovements), isFalse);
    expect(access.hasPermission('VIEW_PRODUCT'), isTrue);
    expect(access.hasAnyPermission(['EDIT_PRODUCT', 'VIEW_PRODUCT']), isTrue);
  });

  test('a capability requiring multiple permissions requires all of them', () {
    final protected = AccessControl(
      permissionRequirements: const {
        AppCapability.manageInventory: {'READ', 'WRITE'},
      },
    );
    addTearDown(protected.dispose);
    protected.updateToken(token(claims(['READ'])));
    expect(protected.allows(AppCapability.manageInventory), isFalse);
    protected.updateToken(token(claims(['READ', 'WRITE'])));
    expect(protected.allows(AppCapability.manageInventory), isTrue);
  });

  test('inventory movement history is mapped to its view permission', () {
    access.updateToken(token(claims(['VIEW_PRODUCT_MOVEMENT'])));
    expect(
      ApiAccessPolicy.requiredFor('/inventory-movement/product/1', 'GET'),
      AppCapability.operate,
    );
    expect(access.allows(AppCapability.viewProductMovements), isTrue);
  });

  test('unmapped capabilities remain available during progressive rollout', () {
    access.updateToken(token(claims(['VIEW_PRODUCT'])));
    expect(access.allows(AppCapability.reports), isTrue);
  });

  test('expired, inactive and malformed tokens fail closed', () {
    for (final value in [
      null,
      'malformed',
      token({
        ...claims(['VIEW_PRODUCT']),
        'exp': 1,
      }),
      token({
        ...claims(['VIEW_PRODUCT']),
        'active': false,
      }),
    ]) {
      access.updateToken(value);
      expect(AppCapability.values.any(access.allows), isFalse);
    }
  });
}
