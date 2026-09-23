import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_movil_sistema/features/user/data/models/user_model.dart';
import 'package:app_movil_sistema/features/user/domain/entities/app_user.dart';
import 'package:dio/dio.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._client);
  final ApiClient _client;
  @override
  Future<List<UserModel>> getUsers(UserFilter filter) async {
    final response = await _client.dio.post(
      '/user/init',
      data: {
        if (filter.query?.trim().isNotEmpty == true) ...{
          'username': filter.query!.trim(),
          'fullName': filter.query!.trim(),
          'email': filter.query!.trim(),
        },
        if (filter.status != null) 'status': filter.status,
        if (filter.typeDocument != null) 'typeDocuments': [filter.typeDocument],
        'page': filter.page,
        'size': filter.size,
      },
    );
    final api = ApiResponse<List<UserModel>>.fromJson(response.data, (json) {
      final data = json as Map<String, dynamic>;
      return (data['users'] as List<dynamic>? ?? const [])
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    if (!api.success || api.data == null) throw _error(response, api.message);
    return api.data!;
  }

  @override
  Future<UserFormDataModel> getFormData([int? id]) async {
    final response = await _client.dio.post(
      '/user/init-form',
      data: {'id': id},
    );
    final api = ApiResponse<UserFormDataModel>.fromJson(
      response.data,
      (json) => UserFormDataModel.fromJson(json as Map<String, dynamic>),
    );
    if (!api.success || api.data == null) throw _error(response, api.message);
    return api.data!;
  }

  @override
  Future<UserModel> create(UserRequest request) =>
      _save('/user/create', request, false);
  @override
  Future<UserModel> update(UserRequest request) =>
      _save('/user/update', request, true);
  Future<UserModel> _save(String path, UserRequest request, bool update) async {
    final response = update
        ? await _client.dio.put(path, data: _body(request))
        : await _client.dio.post(path, data: _body(request));
    final api = ApiResponse<UserModel>.fromJson(
      response.data,
      (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (!api.success || api.data == null) throw _error(response, api.message);
    return api.data!;
  }

  Map<String, dynamic> _body(UserRequest r) => {
    if (r.id != null) 'id': r.id,
    'username': r.username.trim(),
    'email': r.email.trim(),
    'typeDocument': r.typeDocument,
    'document': r.document.trim(),
    'fullName': r.fullName.trim(),
    if (r.phone?.trim().isNotEmpty == true) 'phone': r.phone!.trim(),
    if (r.address?.trim().isNotEmpty == true) 'address': r.address!.trim(),
    'roleIds': r.roleIds,
  };
  @override
  Future<void> updateStatus(int id) async {
    final response = await _client.dio.put('/user/update-status', data: id);
    final api = ApiResponse<bool>.fromJson(
      response.data,
      (json) => json as bool,
    );
    if (!api.success) throw _error(response, api.message);
  }

  DioException _error(Response response, String message) => DioException(
    requestOptions: response.requestOptions,
    response: response,
    error: message,
  );
}
