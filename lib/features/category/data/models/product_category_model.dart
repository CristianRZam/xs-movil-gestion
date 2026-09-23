import 'package:app_movil_sistema/features/category/domain/entities/product_category.dart';

class ProductCategoryModel extends ProductCategory {
  const ProductCategoryModel({
    required super.id,
    required super.parameterId,
    required super.name,
    required super.shortName,
    required super.orderNumber,
    required super.active,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) =>
      ProductCategoryModel(
        id: (json['id'] as num).toInt(),
        parameterId: (json['parameterId'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        shortName: json['shortName'] as String?,
        orderNumber: (json['orderNumber'] as num?)?.toInt() ?? 0,
        active: json['active'] as bool? ?? false,
      );

  ProductCategory toEntity() => ProductCategory(
    id: id,
    parameterId: parameterId,
    name: name,
    shortName: shortName,
    orderNumber: orderNumber,
    active: active,
  );
}
