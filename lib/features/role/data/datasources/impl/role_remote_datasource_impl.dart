import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/role/data/datasources/role_remote_datasource.dart';
import 'package:app_movil_sistema/features/role/data/models/role_model.dart';
import 'package:dio/dio.dart';

class RoleRemoteDataSourceImpl implements RoleRemoteDataSource {
  RoleRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<AppRoleModel>> getRoles() async {
    final response = await _client.dio.post('/role/init', data: const {});
    final api = ApiResponse<List<AppRoleModel>>.fromJson(response.data, (json) {
      final data = json as Map<String, dynamic>;
      return (data['roles'] as List<dynamic>? ?? const [])
          .map((item) => AppRoleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
    if (!api.success || api.data == null) throw _error(response, api.message);
    return api.data!;
  }

  @override
  Future<RolePermissionsModel> getRolePermissions(int roleId) async {
    final response = await _client.dio.get('/permission/get-by-role/$roleId');
    final api = ApiResponse<RolePermissionsModel>.fromJson(
      response.data,
      (json) => RolePermissionsModel.fromJson(json as Map<String, dynamic>),
    );
    if (!api.success || api.data == null) throw _error(response, api.message);
    return api.data!;
  }

  @override
  Future<void> updateRolePermissions({
    required int roleId,
    required Set<int> permissionIds,
  }) async {
    final response = await _client.dio.put(
      '/permission/update-permission-by-role',
      data: {'roleId': roleId, 'permissionIds': permissionIds.toList()},
    );
    final api = ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool? ?? false,
    );
    if (!api.success) throw _error(response, api.message);
  }

  DioException _error(Response response, String message) => DioException(
    requestOptions: response.requestOptions,
    response: response,
    error: message,
  );
}
