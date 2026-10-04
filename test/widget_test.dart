import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/authorization/access_widgets.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/routes/routes.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/presentation/widgets/product_card.dart';
import 'access_control_test.dart' show token, claims;

void main() {
  const product = Product(
    id: 1, code: 'P1', name: 'Producto', categoryId: 1,
    nameCategory: 'General', unitMeasureId: 1, nameUnitMeasure: 'Unidad',
    valuationMethodId: 1, nameValuationMethod: 'Promedio',
    manageVariants: false, basePrice: 10, baseCost: 5, totalStock: 10,
    reservedStock: 0, active: true, deleted: false,
  );
  late AccessControl access;
  setUp(() {
    access = AccessControl(
      permissionRequirements: const {
        AppCapability.viewProductMovements: {'VIEW_PRODUCT_MOVEMENT'},
        AppCapability.createProductInventoryEntry: {
          'CREATE_PRODUCT_INVENTORY_ENTRY',
        },
        AppCapability.createProductWaste: {'CREATE_PRODUCT_WASTE'},
        AppCapability.adjustProductInventory: {'ADJUST_PRODUCT_INVENTORY'},
        AppCapability.manageProducts: {'EDIT_PRODUCT'},
        AppCapability.deleteProducts: {'DELETE_PRODUCT'},
        AppCapability.manageInventory: {'MANAGE_INVENTORY'},
        AppCapability.reports: {'VIEW_REPORT'},
        AppCapability.viewInventoryCount: {'VIEW_INVENTORY_COUNT'},
      },
    );
    getIt.registerSingleton<AccessControl>(access);
  });
  tearDown(() async {
    await getIt.reset();
    access.dispose();
  });

  testWidgets('product menu uses product permissions only', (tester) async {
    access.updateToken(token(claims(['VIEW_PRODUCT_MOVEMENT'])));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: ProductCard(product: product),
    )));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Movimientos'), findsOneWidget);
    for (final action in [
      'Agregar inventario',
      'Registrar merma',
      'Ajustar inventario',
      'Editar',
      'Eliminar',
    ]) {
      expect(find.text(action), findsNothing);
    }
    await tester.tapAt(const Offset(1, 1));
    await tester.pumpAndSettle();
    access.updateToken(token(claims([
      'VIEW_PRODUCT_MOVEMENT',
      'CREATE_PRODUCT_INVENTORY_ENTRY',
      'CREATE_PRODUCT_WASTE',
      'ADJUST_PRODUCT_INVENTORY',
      'EDIT_PRODUCT',
      'DELETE_PRODUCT',
    ])));
    await tester.pump();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    for (final action in [
      'Movimientos',
      'Agregar inventario',
      'Registrar merma',
      'Ajustar inventario',
      'Editar',
      'Eliminar',
    ]) {
      expect(find.text(action), findsOneWidget);
    }
    access.clear();
  });

  testWidgets(
    'guard does not build denied screens and reacts to permission changes',
    (tester) async {
      access.updateToken(token(claims(['VIEW_PRODUCT'])));
      var builds = 0;
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: AccessGuard(
          capability: AppCapability.manageInventory,
          builder: (_) {
            builds++;
            return const Text('Inventario');
          },
        ),
      )));
      expect(builds, 0);
      expect(find.text('Acceso restringido'), findsOneWidget);
      access.updateToken(token(claims(['MANAGE_INVENTORY'])));
      await tester.pump();
      expect(find.text('Inventario'), findsOneWidget);
      access.clear();
      await tester.pump();
      expect(find.text('Inventario'), findsNothing);
    },
  );

  testWidgets('direct report and count routes are denied before loading data', (
    tester,
  ) async {
    access.updateToken(token(claims(['VIEW_PRODUCT'])));
    for (final route in [AppRoutes.reports, AppRoutes.inventoryCount]) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(route),
          home: Builder(builder: AppRoutes.routes[route]!),
        ),
      );
      expect(find.text('Acceso restringido'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    access.clear();
  });

  testWidgets('token expiry revokes an already open screen', (tester) async {
    access.updateToken(token(claims(['VIEW_REPORT'])));
    await tester.pumpWidget(
      MaterialApp(
        home: AccessGuard(
          capability: AppCapability.reports,
          builder: (_) => const Text('Reportes privados'),
        ),
      ),
    );
    expect(find.text('Reportes privados'), findsOneWidget);
    await tester.pump(const Duration(hours: 1, seconds: 1));
    expect(find.text('Reportes privados'), findsNothing);
    expect(find.text('Acceso restringido'), findsOneWidget);
  });

  testWidgets('visibility removes privileged buttons after logout', (
    tester,
  ) async {
    access.updateToken(token(claims(['MANAGE_INVENTORY'])));
    await tester.pumpWidget(
      const MaterialApp(
        home: AccessVisibility(
          capability: AppCapability.manageInventory,
          child: Text('Agregar inventario'),
        ),
      ),
    );
    expect(find.text('Agregar inventario'), findsOneWidget);
    access.clear();
    await tester.pump();
    expect(find.text('Agregar inventario'), findsNothing);
  });
}
