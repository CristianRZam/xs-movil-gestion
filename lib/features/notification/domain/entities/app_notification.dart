import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.read,
    this.referenceType,
    this.referenceId,
    this.metadata,
    this.readAt,
  });

  final int id;
  final String type;
  final String priority;
  final String title;
  final String message;
  final String? referenceType;
  final int? referenceId;
  final String? metadata;
  final DateTime createdAt;
  final bool read;
  final DateTime? readAt;

  @override
  List<Object?> get props => [
    id,
    type,
    priority,
    title,
    message,
    referenceType,
    referenceId,
    metadata,
    createdAt,
    read,
    readAt,
  ];
}
