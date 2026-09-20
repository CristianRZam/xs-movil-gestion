class ProductViewRequest {
  final String? code;
  final String? name;
  final String? description;

  final List<int> categories;
  final List<int> unitMeasures;
  final List<int> valuationMethods;

  final bool? manageVariant;
  final int? minimumStock;
  final int? maximumStock;
  final bool? status;

  final int page;
  final int size;

  const ProductViewRequest({
    this.code,
    this.name,
    this.description,
    this.categories = const [],
    this.unitMeasures = const [],
    this.valuationMethods = const [],
    this.manageVariant,
    this.minimumStock,
    this.maximumStock,
    this.status,
    this.page = 0,
    this.size = 5,
  });
}