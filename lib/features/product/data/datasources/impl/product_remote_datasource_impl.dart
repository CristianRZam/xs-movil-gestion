import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/product/data/datasources/product_remote_datasource.dart';
import 'package:app_movil_sistema/features/product/data/models/product_form_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_form_response_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_view_request_model.dart';
import 'package:app_movil_sistema/features/product/data/models/product_view_response_model.dart';
import 'package:dio/dio.dart';




class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {

  final ApiClient apiClient;

  ProductRemoteDataSourceImpl(this.apiClient,);

  @override
  Future<ProductViewResponseModel> getProductView(ProductViewRequestModel request,) async {

    final response = await apiClient.dio.post('/product/init', data: request.toJson(),);

    final apiResponse = ApiResponse<ProductViewResponseModel>.fromJson(
      response.data,
          (json) => ProductViewResponseModel.fromJson(
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
        'No se recibieron datos',
      );

    }

    return apiResponse.data!;

  }

  @override
  Future<ProductFormResponseModel> getProductForm(
      ProductFormRequestModel request,
      ) async {

    final response = await apiClient.dio.post('/product/init-form', data: request.toJson(),);

    final apiResponse =
    ApiResponse<ProductFormResponseModel>.fromJson(
      response.data,
          (json) => ProductFormResponseModel.fromJson(
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

    return apiResponse.data!;
  }

  @override
  Future<ProductModel> createProduct(ProductRequestModel request,) async {

    final formData = FormData.fromMap({
      'product': MultipartFile.fromString(
        request.toJsonString(),
        contentType: DioMediaType(
          'application',
          'json',
        ),
      ),
    });

    final response = await apiClient.dio.post('/product/create',data: formData,);

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      response.data,
          (json) => ProductModel.fromJson(
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

    return apiResponse.data!;
  }

  @override
  Future<ProductModel> updateProduct(ProductRequestModel request,) async {

    final formData = FormData.fromMap({
      'product': MultipartFile.fromString(
        request.toJsonString(),
        contentType: DioMediaType(
          'application',
          'json',
        ),
      ),
    });

    final response = await apiClient.dio.put('/product/update',data: formData,);

    final apiResponse = ApiResponse<ProductModel>.fromJson(
      response.data,
          (json) => ProductModel.fromJson(
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

    return apiResponse.data!;
  }

  @override
  Future<bool> deleteProduct(int id) async {
    final response = await apiClient.dio.delete('/product/delete/$id',);

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

}