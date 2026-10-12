import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.code,
    required super.name,
    super.description,
    required super.categoryId,
    required super.nameCategory,
    required super.unitMeasureId,
    required super.nameUnitMeasure,
    required super.valuationMethodId,
    required super.nameValuationMethod,
    required super.manageVariants,
    required super.basePrice,
    super.promoPrice,
    required super.baseCost,
    required super.totalStock,
    required super.reservedStock,
    super.mainImageUrl,
    required super.active,
    required super.deleted,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final product = _$ProductModelFromJson(json);
    return ProductModel(
      id: product.id,
      code: product.code,
      name: product.name,
      description: product.description,
      categoryId: product.categoryId,
      nameCategory: product.nameCategory,
      unitMeasureId: product.unitMeasureId,
      nameUnitMeasure: product.nameUnitMeasure,
      valuationMethodId: product.valuationMethodId,
      nameValuationMethod: product.nameValuationMethod,
      manageVariants: product.manageVariants,
      basePrice: product.basePrice,
      promoPrice: product.promoPrice,
      baseCost: product.baseCost,
      totalStock: product.totalStock,
      reservedStock: product.reservedStock,
      mainImageUrl: json['mainImageUrl'] as String?,
      active: product.active,
      deleted: product.deleted,
    );
  }

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      categoryId: entity.categoryId,
      nameCategory: entity.nameCategory,
      unitMeasureId: entity.unitMeasureId,
      nameUnitMeasure: entity.nameUnitMeasure,
      valuationMethodId: entity.valuationMethodId,
      nameValuationMethod: entity.nameValuationMethod,
      manageVariants: entity.manageVariants,
      basePrice: entity.basePrice,
      promoPrice: entity.promoPrice,
      baseCost: entity.baseCost,
      totalStock: entity.totalStock,
      reservedStock: entity.reservedStock,
      mainImageUrl: entity.mainImageUrl,
      active: entity.active,
      deleted: entity.deleted,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      code: code,
      name: name,
      description: description,
      categoryId: categoryId,
      nameCategory: nameCategory,
      unitMeasureId: unitMeasureId,
      nameUnitMeasure: nameUnitMeasure,
      valuationMethodId: valuationMethodId,
      nameValuationMethod: nameValuationMethod,
      manageVariants: manageVariants,
      basePrice: basePrice,
      promoPrice: promoPrice,
      baseCost: baseCost,
      totalStock: totalStock,
      reservedStock: reservedStock,
      mainImageUrl: mainImageUrl,
      active: active,
      deleted: deleted,
    );
  }
}
