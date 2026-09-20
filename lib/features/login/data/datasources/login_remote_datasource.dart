import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/auth_response_model.dart';

abstract class LoginRemoteDataSource {
  Future<AuthResponseModel> login(String email,String password,);
}

class LoginRemoteDataSourceImpl
    implements LoginRemoteDataSource {
  final ApiClient apiClient;

  LoginRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password,) async {
    final response = await apiClient.dio.post('/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        extra: {
          'requiresAuth': false,
        },
      ),
    );

    final apiResponse = ApiResponse<AuthResponseModel>.fromJson(
      response.data,
          (json) => AuthResponseModel.fromJson(
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
}