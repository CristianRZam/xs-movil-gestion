import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'access_control_test.dart' show claims, token;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AccessControl access;
  late TokenStorage storage;
  late SessionCoordinator session;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    access = AccessControl();
    storage = TokenStorage(access);
    session = SessionCoordinator(access, storage);
  });

  tearDown(() {
    session.dispose();
    access.dispose();
  });

  testWidgets('expired session clears storage and returns to login', (tester) async {
    final expiresAt = DateTime.now().add(const Duration(seconds: 2));
    await storage.saveToken(
      token({
        ...claims(['SUPER_ADMIN']),
        'exp': expiresAt.millisecondsSinceEpoch ~/ 1000,
      }),
    );
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: session.navigatorKey,
        routes: {
          SessionCoordinator.loginRoute: (_) => const Scaffold(
            body: Text('Login'),
          ),
        },
        home: const Scaffold(body: Text('Panel privado')),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
    expect(await storage.getToken(), isNull);
  });
}
