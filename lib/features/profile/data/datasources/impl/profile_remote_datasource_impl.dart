import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_movil_sistema/features/profile/data/models/user_profile_model.dart';
import 'package:dio/dio.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserProfileModel> getProfile() async {
    final response = await _apiClient.dio.get('/profile/init');
    final api = ApiResponse<UserProfileModel>.fromJson(response.data, (json) {
      final data = json as Map<String, dynamic>? ?? const {};
      return UserProfileModel.fromJson(
        data['user'] as Map<String, dynamic>? ?? const {},
      );
    });
    if (!api.success || api.data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
    return api.data!;
  }

  @override
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmationPassword,
  }) async {
    final response = await _apiClient.dio.put(
      '/profile/update-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmationPassword': confirmationPassword,
      },
    );
    final api = ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool? ?? false,
    );
    if (!api.success) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
