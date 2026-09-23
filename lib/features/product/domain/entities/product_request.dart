class ProductRequest {
  final int? id;

  final String code;
  final String name;
  final String description;

  final int categoryId;
  final int unitMeasureId;
  final int valuationMethodId;

  final double basePrice;
  final double? promoPrice;
  final double baseCost;

  const ProductRequest({
    this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.unitMeasureId,
    required this.valuationMethodId,
    required this.basePrice,
    this.promoPrice,
    required this.baseCost,
  });
}
