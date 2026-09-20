import 'package:app_movil_sistema/features/cash_session/domain/entities/cash_session.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cash_session_model.g.dart';

@JsonSerializable()
class CashSessionModel extends CashSession {

  const CashSessionModel({
    required super.id,
    required super.cashRegisterId,
    required super.openedBy,
    super.openedByName,
    required super.openedAt,
    required super.openingAmount,
    super.closedBy,
    super.closedByName,
    super.closedAt,
    super.expectedAmount,
    super.closingAmount,
    super.difference,
    required super.status,
    super.openingComment,
    super.closingComment,
    super.createdBy,
    super.createdAt,
    super.modifiedBy,
    super.modifiedAt,
    required super.deleted,
  });

  factory CashSessionModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$CashSessionModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CashSessionModelToJson(this);

  factory CashSessionModel.fromEntity(
      CashSession entity,
      ) {
    return CashSessionModel(
      id: entity.id,
      cashRegisterId: entity.cashRegisterId,
      openedBy: entity.openedBy,
      openedByName: entity.openedByName,
      openedAt: entity.openedAt,
      openingAmount: entity.openingAmount,
      closedBy: entity.closedBy,
      closedByName: entity.closedByName,
      closedAt: entity.closedAt,
      expectedAmount: entity.expectedAmount,
      closingAmount: entity.closingAmount,
      difference: entity.difference,
      status: entity.status,
      openingComment: entity.openingComment,
      closingComment: entity.closingComment,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      modifiedBy: entity.modifiedBy,
      modifiedAt: entity.modifiedAt,
      deleted: entity.deleted,
    );
  }

  CashSession toEntity() {
    return CashSession(
      id: id,
      cashRegisterId: cashRegisterId,
      openedBy: openedBy,
      openedByName: openedByName,
      openedAt: openedAt,
      openingAmount: openingAmount,
      closedBy: closedBy,
      closedByName: closedByName,
      closedAt: closedAt,
      expectedAmount: expectedAmount,
      closingAmount: closingAmount,
      difference: difference,
      status: status,
      openingComment: openingComment,
      closingComment: closingComment,
      createdBy: createdBy,
      createdAt: createdAt,
      modifiedBy: modifiedBy,
      modifiedAt: modifiedAt,

      deleted: deleted,
    );
  }
}