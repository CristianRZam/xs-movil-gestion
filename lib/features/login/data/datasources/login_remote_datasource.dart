import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract class LoginRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final ApiClient apiClient;

  LoginRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await apiClient.dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        extra: {'requiresAuth': false},
      ),
    );
    return AuthResponseModel.fromJson(response.data);
  }
}
