import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/authorization/api_access_policy.dart';

String token(Map<String, Object?> claims) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'HS256'})}.${encode(claims)}.signature';
}

Map<String, Object?> claims(List<String> roles) => {
  'roles': roles,
  'exp':
      DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
      1000,
  'active': true,
};

void main() {
  late AccessControl access;
  setUp(() => access = AccessControl());
  tearDown(() => access.dispose());

  test('SUPER_ADMIN has every capability with multiple roles', () {
    access.updateToken(token(claims(['CASHIER', 'SUPER_ADMIN'])));
    expect(AppCapability.values.every(access.allows), isTrue);
  });

  test(
    'other roles only have operational access, ignoring permissions for now',
    () {
      access.updateToken(
        token({
          ...claims(['ADMIN']),
          'permissions': ['ALL', '*'],
        }),
      );
      expect(access.allows(AppCapability.operate), isTrue);
      for (final capability in AppCapability.values.where(
        (c) => c != AppCapability.operate,
      )) {
        expect(access.allows(capability), isFalse);
      }
    },
  );

  test('invalid, expired, inactive and roleless tokens fail closed', () {
    for (final value in [
      null,
      '',
      'malformed',
      token(claims([])),
      token({
        ...claims(['SUPER_ADMIN']),
        'exp': 1,
      }),
      token({
        ...claims(['SUPER_ADMIN']),
        'exp': null,
      }),
      token({
        ...claims(['SUPER_ADMIN']),
        'active': false,
      }),
      token({
        ...claims(['SUPER_ADMIN']),
        'roles': 'SUPER_ADMIN',
      }),
    ]) {
      access.updateToken(value);
      expect(AppCapability.values.any(access.allows), isFalse);
    }
  });

  test('logout and account changes remove previous privileges', () {
    access.updateToken(token(claims(['SUPER_ADMIN'])));
    access.updateToken(token(claims(['CASHIER'])));
    expect(access.allows(AppCapability.manageInventory), isFalse);
    access.clear();
    expect(access.isAuthenticated, isFalse);
    expect(access.allows(AppCapability.operate), isFalse);
  });

  test(
    'future permission mode requires all codes and denies unmapped actions',
    () {
      final futureAccess = AccessControl(
        mode: AuthorizationMode.permissions,
        permissionRequirements: const {
          AppCapability.manageInventory: {'READ', 'WRITE'},
        },
      );
      addTearDown(futureAccess.dispose);
      futureAccess.updateToken(
        token({
          ...claims(['CASHIER']),
          'permissions': ['READ'],
        }),
      );
      expect(futureAccess.allows(AppCapability.manageInventory), isFalse);
      futureAccess.updateToken(
        token({
          ...claims(['CASHIER']),
          'permissions': ['READ', 'WRITE'],
        }),
      );
      expect(futureAccess.allows(AppCapability.manageInventory), isTrue);
      expect(futureAccess.allows(AppCapability.reports), isFalse);
    },
  );

  test(
    'API blocks restricted operations but permits product search and sales',
    () {
      access.updateToken(token(claims(['CASHIER'])));
      for (final entry in {
        '/product/create': 'POST',
        '/product/update': 'PUT',
        '/product/delete/1': 'DELETE',
        '/product/init-form': 'POST',
        '/inventory-movement/create': 'POST',
        '/inventory-counts/current': 'GET',
        '/inventory-counts/1/close': 'PUT',
        '/reports/sales/pdf': 'POST',
        '/orders/1': 'DELETE',
      }.entries) {
        expect(
          access.allows(ApiAccessPolicy.requiredFor(entry.key, entry.value)),
          isFalse,
          reason: entry.key,
        );
      }
      for (final entry in {
        '/dashboard': 'GET',
        '/product/init': 'POST',
        '/inventory-movement/product/1': 'GET',
        '/orders': 'POST',
        '/orders/1/status': 'PUT',
        '/sales': 'POST',
        '/cash-session/open': 'POST',
        '/cash-session/close/1': 'PUT',
      }.entries) {
        expect(
          access.allows(ApiAccessPolicy.requiredFor(entry.key, entry.value)),
          isTrue,
          reason: entry.key,
        );
      }
    },
  );
}
