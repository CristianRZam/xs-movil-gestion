import 'package:app_movil_sistema/core/authorization/api_access_policy.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage = getIt<TokenStorage>();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': EnvConfig.apiKey,
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] ?? true;

          if (!requiresAuth) {
            return handler.next(options);
          }

          final token = await tokenStorage.getToken();

          if (token == null || token.isEmpty) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'code': 401,
                    'message': 'No autenticado. Inicie sesión.',
                  },
                ),
              ),
            );
          }

          final access = tokenStorage.access;
          if (!access.isAuthenticated) {
            await _endSession();
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'code': 401,
                    'message': 'Sesión expirada. Inicie sesión nuevamente.',
                  },
                ),
              ),
            );
          }

          if (!access.allows(
            ApiAccessPolicy.requiredFor(options.path, options.method),
          )) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 403,
                  data: {
                    'code': 403,
                    'message': 'No tienes acceso a esta operación.',
                  },
                ),
              ),
            );
          }

          // Adjuntar token si es válido
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (DioException e, handler) async {
          final requiresAuth = e.requestOptions.extra['requiresAuth'] ?? true;
          if (requiresAuth && e.response?.statusCode == 401) {
            await _endSession();
          }
          handler.reject(e);
        },
      ),
    );
  }

  Future<void> _endSession() async {
    if (getIt.isRegistered<SessionCoordinator>()) {
      await getIt<SessionCoordinator>().signOut();
      return;
    }
    await tokenStorage.deleteToken();
  }
}
