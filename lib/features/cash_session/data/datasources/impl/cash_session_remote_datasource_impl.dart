import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/features/cash_session/data/datasources/cash_session_remote_datasource.dart';
import 'package:app_movil_sistema/features/cash_session/data/models/cash_session_close_request_model.dart';
import 'package:app_movil_sistema/features/cash_session/data/models/cash_session_model.dart';
import 'package:dio/dio.dart';

class CashSessionRemoteDataSourceImpl
    implements CashSessionRemoteDataSource {

  final ApiClient apiClient;

  CashSessionRemoteDataSourceImpl(this.apiClient,);

  @override
  Future<CashSessionModel> openSession(CashSessionModel request,) async {

    final response = await apiClient.dio.post('/cash-session/open',
      data: request.toJson(),
    );

    final apiResponse =
    ApiResponse<CashSessionModel>.fromJson(
      response.data, (json) => CashSessionModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    if (apiResponse.data == null) {
      throw Exception(
        'No se recibieron datos de la sesión de caja',
      );
    }

    return apiResponse.data!;
  }

  @override
  Future<CashSessionModel> getCurrentSession() async {

    final response = await apiClient.dio.get('/cash-session/current',);

    final apiResponse =
    ApiResponse<CashSessionModel>.fromJson(
      response.data, (json) => CashSessionModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    if (apiResponse.data == null) {
      throw Exception(
        'No existe una sesión de caja abierta',
      );
    }

    return apiResponse.data!;
  }

  @override
  Future<bool> existsOpenSession() async {

    final response = await apiClient.dio.get('/cash-session/exists-open',);

    final apiResponse =
    ApiResponse<bool>.fromJson(
      response.data,
          (json) => json as bool,
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    if (apiResponse.data == null) {
      throw Exception(
        'No se recibió el estado de la sesión de caja',
      );
    }

    return apiResponse.data!;
  }

  @override
  Future<CashSessionModel> closeSession(
      CashSessionCloseRequestModel request,
      ) async {

    final response = await apiClient.dio.put('/cash-session/close/${request.id}',
      queryParameters: request.toQueryParameters(),
    );

    final apiResponse =
    ApiResponse<CashSessionModel>.fromJson(
      response.data,
          (json) => CashSessionModel.fromJson(
        json as Map<String, dynamic>,
      ),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    if (apiResponse.data == null) {
      throw Exception(
        'No se recibieron datos del cierre de caja',
      );
    }

    return apiResponse.data!;
  }


  @override
  Future<List<CashSessionModel>> getHistory() async {

    final response = await apiClient.dio.get(
      '/cash-session/history',
      queryParameters: {
        'page': 0,
        'size': EnvConfig.cashSessionHistoryPageSize,
      },
    );

    final apiResponse =
    ApiResponse<List<CashSessionModel>>.fromJson(
      response.data,
          (json) {
        // El backend devuelve PageResponseDTO: items, totalElements, page,
        // size y hasMore. La pantalla actual consume la primera página.
        final page = json as Map<String, dynamic>;
        final list = page['items'] as List<dynamic>? ?? const [];

        return list
            .map(
              (item) => CashSessionModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
            .toList();
      },
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    return apiResponse.data ?? [];
  }
}
