class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.parameterId,
    required this.name,
    required this.shortName,
    required this.orderNumber,
    required this.active,
  });

  final int id;
  final int parameterId;
  final String name;
  final String? shortName;
  final int orderNumber;
  final bool active;
}
