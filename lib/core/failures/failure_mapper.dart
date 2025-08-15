import 'package:app_movil_sistema/core/failures/failure.dart';
import 'package:dio/dio.dart';

class FailureMapper {
  static Failure fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(code: error.response?.statusCode);

      case DioExceptionType.connectionError:
        return NetworkFailure(code: error.response?.statusCode);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final data = error.response?.data;

        int? businessCode;
        String message = 'Error desconocido';

        if (data is Map) {
          if (data.containsKey('code') && data['code'] is int) {
            businessCode = data['code'];
          }
          if (data.containsKey('message') && data['message'] is String) {
            message = data['message'];
          }
        }

        if (statusCode == 401) {
          return AuthFailure(message, code: businessCode ?? statusCode);
        }

        return ServerFailure(
          message,
          code: businessCode ?? statusCode,
        );

      default:
        return UnexpectedFailure(code: error.response?.statusCode);
    }
  }
}
