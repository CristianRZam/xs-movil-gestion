import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/network/api_response.dart';
import 'package:app_movil_sistema/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:app_movil_sistema/features/notification/data/models/notification_model.dart';
import 'package:app_movil_sistema/features/notification/domain/entities/notification_filter.dart';
import 'package:dio/dio.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<NotificationModel>> getNotifications(
    NotificationFilter filter,
  ) async {
    final response = await _apiClient.dio.get(
      '/notifications',
      queryParameters: {
        if (filter.type != null) 'type': filter.type,
        if (filter.priority != null) 'priority': filter.priority,
        if (filter.read != null) 'read': filter.read,
        if (filter.fromDate != null) 'fromDate': _formatDate(filter.fromDate!),
        if (filter.toDate != null) 'toDate': _formatDate(filter.toDate!),
        if (filter.search != null && filter.search!.trim().isNotEmpty)
          'search': filter.search!.trim(),
      },
    );
    final api = ApiResponse<List<NotificationModel>>.fromJson(response.data, (
      json,
    ) {
      return (json as List<dynamic>? ?? [])
          .map(
            (item) => NotificationModel.fromJson(item as Map<String, dynamic>),
          )
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
  Future<int> getVisibleDays() async {
    final response = await _apiClient.dio.get('/notifications/configuration');
    final api = ApiResponse<int>.fromJson(
      response.data,
      (json) => (json as Map<String, dynamic>?)?['visibleDays'] as int? ?? 7,
    );
    if (!api.success || api.data == null)
      throw _apiError(response, api.message);
    return api.data!;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    final response = await _apiClient.dio.put(
      '/notifications/$notificationId/read',
    );
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

  String _formatDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
