import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/category/data/datasources/category_remote_datasource.dart';
import 'package:app_movil_sistema/features/category/data/models/category_create_request_model.dart';
import 'package:app_movil_sistema/features/category/data/models/product_category_model.dart';
import 'package:dio/dio.dart';

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  CategoryRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<List<ProductCategoryModel>> getCategories({String? search}) async {
    final response = await _apiClient.dio.post(
      '/parameter/init',
      data: {
        'code': 'CATEGORIA_PRODUCTO',
        'type': 2,
        if (search?.trim().isNotEmpty == true) 'name': search!.trim(),
        'page': 0,
        'size': 50,
      },
    );
    final api = ApiResponse<List<ProductCategoryModel>>.fromJson(
      response.data,
      (json) {
        final data = json as Map<String, dynamic>? ?? const {};
        return (data['parameters'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  ProductCategoryModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
    if (!api.success || api.data == null) {
      throw _error(response, api.message);
    }
    return api.data!;
  }

  @override
  Future<ProductCategoryModel> createCategory(
    CategoryCreateRequestModel request,
  ) async {
    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        request.toJsonString(),
        contentType: DioMediaType('application', 'json'),
      ),
    });
    final response = await _apiClient.dio.post(
      '/parameter/create',
      data: formData,
    );
    final api = ApiResponse<ProductCategoryModel>.fromJson(
      response.data,
      (json) => ProductCategoryModel.fromJson(json as Map<String, dynamic>),
    );
    if (!api.success || api.data == null) {
      throw _error(response, api.message);
    }
    return api.data!;
  }

  DioException _error(Response<dynamic> response, String message) =>
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: message,
      );
}
