import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/datasources/inventory_movement_remote_datasource.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_create_request_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_page_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_model.dart';
import 'package:dio/dio.dart';

class InventoryMovementRemoteDataSourceImpl
    implements InventoryMovementRemoteDataSource {
  final ApiClient apiClient;

  InventoryMovementRemoteDataSourceImpl(this.apiClient);

  @override
  Future<InventoryMovementPageModel> getInventoryMovements(
    int productId, {
    required int page,
    required int size,
  }) async {
    final response = await apiClient.dio.get(
      '/inventory-movement/product/$productId',
      queryParameters: {'page': page, 'size': size},
    );

    final apiResponse = ApiResponse<InventoryMovementPageModel>.fromJson(
      response.data,
      (json) =>
          InventoryMovementPageModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    return apiResponse.data!;
  }

  @override
  Future<InventoryMovementModel> createInventoryMovement(
    InventoryMovementCreateRequestModel request,
  ) async {
    final response = await apiClient.dio.post(
      '/inventory-movement/create',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<InventoryMovementModel>.fromJson(
      response.data,
      (json) => InventoryMovementModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    return apiResponse.data!;
  }
}
