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

  ProductViewRequest copyWith({
    String? code,
    String? name,
    String? description,
    List<int>? categories,
    List<int>? unitMeasures,
    List<int>? valuationMethods,
    bool? manageVariant,
    int? minimumStock,
    int? maximumStock,
    bool? status,
    int? page,
    int? size,
  }) {
    return ProductViewRequest(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      unitMeasures: unitMeasures ?? this.unitMeasures,
      valuationMethods: valuationMethods ?? this.valuationMethods,
      manageVariant: manageVariant ?? this.manageVariant,
      minimumStock: minimumStock ?? this.minimumStock,
      maximumStock: maximumStock ?? this.maximumStock,
      status: status ?? this.status,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }
}
