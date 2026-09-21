// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashSessionModel _$CashSessionModelFromJson(Map<String, dynamic> json) =>
    CashSessionModel(
      id: (json['id'] as num).toInt(),
      cashRegisterId: (json['cashRegisterId'] as num).toInt(),
      openedBy: (json['openedBy'] as num).toInt(),
      openedByName: json['openedByName'] as String?,
      openedAt: DateTime.parse(json['openedAt'] as String),
      openingAmount: (json['openingAmount'] as num).toDouble(),
      closedBy: (json['closedBy'] as num?)?.toInt(),
      closedByName: json['closedByName'] as String?,
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      expectedAmount: (json['expectedAmount'] as num?)?.toDouble(),
      closingAmount: (json['closingAmount'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      status: json['status'] as String,
      openingComment: json['openingComment'] as String?,
      closingComment: json['closingComment'] as String?,
      createdBy: (json['createdBy'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      modifiedBy: (json['modifiedBy'] as num?)?.toInt(),
      modifiedAt: json['modifiedAt'] == null
          ? null
          : DateTime.parse(json['modifiedAt'] as String),
      deleted: json['deleted'] as bool,
    );

Map<String, dynamic> _$CashSessionModelToJson(CashSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cashRegisterId': instance.cashRegisterId,
      'openedBy': instance.openedBy,
      'openedByName': instance.openedByName,
      'openedAt': instance.openedAt.toIso8601String(),
      'openingAmount': instance.openingAmount,
      'closedBy': instance.closedBy,
      'closedByName': instance.closedByName,
      'closedAt': instance.closedAt?.toIso8601String(),
      'expectedAmount': instance.expectedAmount,
      'closingAmount': instance.closingAmount,
      'difference': instance.difference,
      'status': instance.status,
      'openingComment': instance.openingComment,
      'closingComment': instance.closingComment,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'modifiedBy': instance.modifiedBy,
      'modifiedAt': instance.modifiedAt?.toIso8601String(),
      'deleted': instance.deleted,
    };
