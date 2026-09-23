import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:app_movil_sistema/features/notification/data/models/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.dio.get('/notifications');
    final api = ApiResponse<List<NotificationModel>>.fromJson(response.data,
        (json) {
      return (json as List<dynamic>? ?? [])
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
    if (!api.success || api.data == null) {
      throw _apiError(response, api.message);
    }
    return api.data!;
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.dio.get('/notifications/unread-count');
    final api = ApiResponse<int>.fromJson(response.data, (json) {
      final data = json as Map<String, dynamic>?;
      return (data?['unreadCount'] as num?)?.toInt() ?? 0;
    });
    if (!api.success || api.data == null) {
      throw _apiError(response, api.message);
    }
    return api.data!;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    final response = await _apiClient.dio.put('/notifications/$notificationId/read');
    _ensureSuccess(response);
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await _apiClient.dio.put('/notifications/read-all');
    _ensureSuccess(response);
  }

  void _ensureSuccess(Response<dynamic> response) {
    final api = ApiResponse<Object?>.fromJson(response.data, (_) => null);
    if (!api.success) {
      throw _apiError(response, api.message);
    }
  }

  DioException _apiError(Response<dynamic> response, String message) {
    return DioException(
      requestOptions: response.requestOptions,
      response: response,
      error: message,
    );
  }
}
