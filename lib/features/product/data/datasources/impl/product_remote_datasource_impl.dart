import 'dart:convert';

import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/product/data/datasources/product_remote_datasource.dart';
import 'package:app_movil_sistema/features/product/data/models/product_form_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_form_response_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_save_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_view_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_view_response_model.dart';
import 'package:dio/dio.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ProductViewResponseModel> getProductView(
    ProductViewRequestModel request,
  ) async {
    final response = await apiClient.dio.post(
      '/product/init',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<ProductViewResponseModel>.fromJson(
      response.data,
      (json) => ProductViewResponseModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: apiResponse.message,
      );
    }

    if (apiResponse.data == null) {
      throw Exception('No se recibieron datos');
    }

    return apiResponse.data!;
  }

  @override
  Future<ProductFormResponseModel> getProductForm(
    ProductFormRequestModel request,
  ) async {
    final response = await apiClient.dio.post(
      '/product/init-form',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<ProductFormResponseModel>.fromJson(
      response.data,
      (json) => ProductFormResponseModel.fromJson(json as Map<String, dynamic>),
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
  Future<ProductModel> createProduct(ProductSaveRequestModel request) async {
    final formData = await _buildFormData(request);

    final response = await apiClient.dio.post(
      '/product/create',
      data: formData,
    );

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      response.data,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
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
  Future<ProductModel> updateProduct(ProductSaveRequestModel request) async {
    final formData = await _buildFormData(request, includeImagesToKeep: true);

    final response = await apiClient.dio.put('/product/update', data: formData);

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      response.data,
      (json) => ProductModel.fromJson(json as Map<String, dynamic>),
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

  Future<FormData> _buildFormData(
    ProductSaveRequestModel request, {
    bool includeImagesToKeep = false,
  }) async {
    final formData = FormData.fromMap({
      'product': MultipartFile.fromString(
        request.product.toJsonString(),
        contentType: DioMediaType('application', 'json'),
      ),
    });

    for (final image in request.newImages) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(image.path, filename: image.fileName),
        ),
      );
    }

    if (includeImagesToKeep) {
      final imagesToKeepJson = request.imagesToKeep
          .map(
            (image) => {
              'id': image.id,
              'imageUrl': image.imageUrl,
              'altText': image.altText,
              'isMain': image.isMain,
              'orderNumber': image.orderNumber,
            },
          )
          .toList();
      formData.files.add(
        MapEntry(
          'imagesToKeep',
          MultipartFile.fromString(
            jsonEncode(imagesToKeepJson),
            contentType: DioMediaType('application', 'json'),
          ),
        ),
      );
    }

    if (request.mainImageKey != null) {
      formData.files.add(
        MapEntry(
          'mainImageKey',
          MultipartFile.fromString(
            jsonEncode(request.mainImageKey),
            contentType: DioMediaType('application', 'json'),
          ),
        ),
      );
    }

    return formData;
  }

  @override
  Future<bool> deleteProduct(int id) async {
    final response = await apiClient.dio.delete('/product/delete/$id');

    final apiResponse = ApiResponse<bool>.fromJson(
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

    return apiResponse.data!;
  }

  @override
  Future<bool> updateProductStatus(int id) async {
    final response = await apiClient.dio.put(
      '/product/update-status',
      data: id,
    );
    final apiResponse = ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool? ?? false,
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
