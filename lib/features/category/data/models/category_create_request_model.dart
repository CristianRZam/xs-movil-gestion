import 'dart:convert';

import 'package:app_movil_sistema/features/category/domain/entities/category_create_request.dart';

class CategoryCreateRequestModel extends CategoryCreateRequest {
  const CategoryCreateRequestModel({
    required super.name,
    required super.shortName,
    required super.orderNumber,
  });

  factory CategoryCreateRequestModel.fromEntity(CategoryCreateRequest entity) =>
      CategoryCreateRequestModel(
        name: entity.name,
        shortName: entity.shortName,
        orderNumber: entity.orderNumber,
      );

  Map<String, dynamic> toJson() => {
    'code': 'CATEGORIA_PRODUCTO',
    'type': 2,
    'name': name.trim(),
    if (shortName?.trim().isNotEmpty == true) 'shortName': shortName!.trim(),
    'orderNumber': orderNumber,
  };

  String toJsonString() => jsonEncode(toJson());
}
