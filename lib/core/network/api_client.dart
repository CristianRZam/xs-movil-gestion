import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage = TokenStorage();

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
                    'message': 'No autenticado. Inicie sesión.'
                  },
                ),
              ),
            );
          }

          if (JwtDecoder.isExpired(token)) {
            await tokenStorage.deleteToken();
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'code': 401,
                    'message': 'Sesión expirada. Inicie sesión nuevamente.'
                  },
                ),
              ),
            );
          }

          // Adjuntar token si es válido
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
        onError: (DioException e, handler) {
          handler.reject(e);
        },
      ),
    );
  }
}
