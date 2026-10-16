import 'dart:convert';

import 'package:app_movil_sistema/features/category/domain/entities/category_update_request.dart';

class CategoryUpdateRequestModel extends CategoryUpdateRequest {
  const CategoryUpdateRequestModel({
    required super.category,
    required super.name,
    required super.shortName,
    required super.orderNumber,
  });

  factory CategoryUpdateRequestModel.fromEntity(CategoryUpdateRequest entity) =>
      CategoryUpdateRequestModel(
        category: entity.category,
        name: entity.name,
        shortName: entity.shortName,
        orderNumber: entity.orderNumber,
      );

  Map<String, dynamic> toJson() => {
    'id': category.id,
    'parameterId': category.parameterId,
    'parentParameterId': category.parentParameterId,
    'type': category.type,
    'name': name.trim(),
    'shortName': shortName?.trim() ?? '',
    'orderNumber': orderNumber,
  };

  String toJsonString() => jsonEncode(toJson());
}
