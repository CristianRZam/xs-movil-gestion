import 'package:app_movil_sistema/features/notification/domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.priority,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.read,
    super.referenceType,
    super.referenceId,
    super.metadata,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'GENERAL',
      priority: json['priority'] as String? ?? 'NORMAL',
      title: json['title'] as String? ?? 'Notificación',
      message: json['message'] as String? ?? '',
      referenceType: json['referenceType'] as String?,
      referenceId: (json['referenceId'] as num?)?.toInt(),
      metadata: json['metadata'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      read: json['read'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.tryParse(json['readAt'] as String),
    );
  }
}
