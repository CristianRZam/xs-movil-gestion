import 'dart:convert';
import 'dart:typed_data';

import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/features/dashboard/data/datasources/impl/dashboard_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:app_movil_sistema/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:app_movil_sistema/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:app_movil_sistema/features/home/presentation/pages/home_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'access_control_test.dart' show claims, token;

class SummaryRepository implements DashboardRepository {
  SummaryRepository(this.summary);

  DashboardSummary summary;
  int calls = 0;

  @override
  Future<Either<Failure, DashboardSummary>> getSummary() async {
    calls++;
    return Right(summary);
  }
}

class DashboardAdapter implements HttpClientAdapter {
  DashboardAdapter(this.scope);

  final String? scope;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode({
        'status': 200,
        'success': true,
        'message': 'OK',
        'data': {
          'scope': scope,
          'summaryDate': '2026-09-22',
          'todaySales': 150.5,
          'todaySalesCount': 2,
          'averageSale': 75.25,
          'todayOrders': 3,
          'weeklySales': [],
          'topProducts': [
            {'productId': 1, 'productName': 'Producto', 'quantity': 4},
          ],
          'paymentMethods': [
            {'method': 'CASH', 'total': 150.5},
          ],
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AccessControl access;
  late TokenStorage storage;

  setUp(() {
    access = AccessControl(
      permissionRequirements: const {
        AppCapability.dashboard: {'VIEW_DASHBOARD'},
      },
    );
    storage = TokenStorage(access);
    getIt.registerSingleton<AccessControl>(access);
    getIt.registerSingleton<TokenStorage>(storage);
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.loadFromString(envString: 'BASE_URL=https://example.invalid');
  });

  tearDown(() async {
    access.dispose();
    await getIt.reset();
  });

  test(
    'dashboard response is consumed without sending an owner or scope',
    () async {
      await storage.saveToken(token(claims(['VIEW_DASHBOARD'])));
      final client = ApiClient();
      final adapter = DashboardAdapter(null);
      client.dio.httpClientAdapter = adapter;
      addTearDown(() => client.dio.close());

      final summary = await DashboardRemoteDataSourceImpl(client).getSummary();

      expect(summary.todaySales, 150.5);
      expect(summary.todaySalesCount, 2);
      expect(summary.averageSale, 75.25);
      expect(summary.summaryDate, DateTime(2026, 9, 22));
      expect(summary.topProducts.single.quantity, 4);
      expect(summary.paymentMethods.single.total, 150.5);
      expect(adapter.request!.path, '/dashboard');
      expect(adapter.request!.queryParameters, isEmpty);
      expect(adapter.request!.data, isNull);
    },
  );

  test(
    'dashboard response does not depend on a scope field',
    () async {
      await storage.saveToken(token(claims(['VIEW_DASHBOARD'])));
      final client = ApiClient();
      client.dio.httpClientAdapter = DashboardAdapter(null);
      addTearDown(() => client.dio.close());

      final summary = await DashboardRemoteDataSourceImpl(client).getSummary();
      expect(summary.todaySales, 150.5);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets('dashboard fits a small screen in $brightness', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      access.updateToken(token(claims(['VIEW_DASHBOARD'])));
      final repository = SummaryRepository(
        DashboardSummary(
          summaryDate: DateTime(2026, 9, 22),
          todaySales: 0,
          todayOrders: 0,
          weeklySales: const [],
          topProducts: const [],
          paymentMethods: const [],
        ),
      );
      getIt.registerSingleton<GetDashboardSummaryUseCase>(
        GetDashboardSummaryUseCase(repository),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Resumen de tu negocio'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Actualizar'));
      await tester.pumpAndSettle();
      expect(repository.calls, 2);
      access.clear();
    });
  }

  testWidgets('user without dashboard permission sees the access message', (
    tester,
  ) async {
    access.updateToken(token(claims(['VIEW_PRODUCT'])));
    final repository = SummaryRepository(
      const DashboardSummary(
        todaySales: 999999,
        todayOrders: 999,
        weeklySales: [],
        topProducts: [],
        paymentMethods: [],
      ),
    );
    getIt.registerSingleton<GetDashboardSummaryUseCase>(
      GetDashboardSummaryUseCase(repository),
    );
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(
      find.text('No tienes permiso para visualizar el dashboard.'),
      findsOneWidget,
    );
    expect(find.text('Resumen de tu negocio'), findsNothing);
    expect(find.textContaining('999999'), findsNothing);
    expect(repository.calls, 0);
    access.clear();
  });
}
