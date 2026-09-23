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
    required super.active,
    required super.deleted,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

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
      active: active,
      deleted: deleted,
    );
  }
}
