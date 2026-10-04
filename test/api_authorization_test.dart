import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'access_control_test.dart' show token, claims;

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
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
  late ApiClient client;
  late RecordingAdapter adapter;
  setUp(() {
    dotenv.loadFromString(
      envString: 'BASE_URL=https://example.invalid\nAPI_KEY=test',
    );
    FlutterSecureStorage.setMockInitialValues({});
    access = AccessControl();
    storage = TokenStorage(access);
    getIt.registerSingleton<TokenStorage>(storage);
    client = ApiClient();
    adapter = RecordingAdapter();
    client.dio.httpClientAdapter = adapter;
  });
  tearDown(() async {
    client.dio.close();
    access.dispose();
    await getIt.reset();
  });

  test(
    'the server remains the authority for inventory mutations',
    () async {
      await storage.saveToken(token(claims(['VIEW_PRODUCT'])));
      await client.dio.post('/inventory-movement/create', data: {});
      expect(adapter.requests, hasLength(1));
      await client.dio.post('/product/init', data: {});
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.first.headers['Authorization'],
        startsWith('Bearer '),
      );
    },
  );

  test(
    'an authenticated user can send a request and logout prevents subsequent requests',
    () async {
      await storage.saveToken(
        token(claims(['CREATE_PRODUCT_INVENTORY_ENTRY'])),
      );
      await client.dio.post('/inventory-movement/create', data: {});
      expect(adapter.requests, hasLength(1));
      await storage.deleteToken();
      await expectLater(
        client.dio.post('/inventory-movement/create', data: {}),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(adapter.requests, hasLength(1));
      expect(access.allows(AppCapability.manageInventory), isFalse);
    },
  );
}
