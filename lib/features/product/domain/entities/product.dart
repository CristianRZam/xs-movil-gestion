
class Product {

  final int id;
  final String code;
  final String name;
  final String? description;
  final int categoryId;
  final String nameCategory;
  final int unitMeasureId;
  final String nameUnitMeasure;
  final int valuationMethodId;
  final String nameValuationMethod;
  final bool manageVariants;
  final double basePrice;
  final double? promoPrice;
  final double baseCost;
  final int totalStock;
  final bool active;
  final bool deleted;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.categoryId,
    required this.nameCategory,
    required this.unitMeasureId,
    required this.nameUnitMeasure,
    required this.valuationMethodId,
    required this.nameValuationMethod,
    required this.manageVariants,
    required this.basePrice,
    this.promoPrice,
    required this.baseCost,
    required this.totalStock,
    required this.active,
    required this.deleted,
  });

}