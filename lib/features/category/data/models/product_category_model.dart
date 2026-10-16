import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({
    required super.id,
    required super.parameterId,
    required super.name,
    required super.shortName,
    required super.orderNumber,
    required super.active,
    super.parentParameterId,
    super.type,
    super.code,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) =>
      ProductCategoryModel(
        id: (json['id'] as num).toInt(),
        parameterId: (json['parameterId'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        shortName: json['shortName'] as String?,
        orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
        active: json['active'] as bool? ?? false,
        parentParameterId: (json['parentParameterId'] as num?)?.toInt(),
        type: (json['type'] as num?)?.toInt() ?? 2,
        code: json['code'] as String? ?? 'CATEGORIA_PRODUCTO',
      );

  ProductCategory toEntity() => ProductCategory(
    id: id,
    parameterId: parameterId,
    name: name,
    shortName: shortName,
    orderNumber: orderNumber,
    active: active,
    parentParameterId: parentParameterId,
    type: type,
    code: code,
  );
}
