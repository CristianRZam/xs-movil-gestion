import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: EnvConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': EnvConfig.apiKey,
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) {
          handler.reject(e);
        },
      ),
    );
  }
}
