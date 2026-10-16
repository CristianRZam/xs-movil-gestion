class ProductCategory {
  const ProductCategory({
    required this.id,
    required this.parameterId,
    required this.name,
    required this.shortName,
    required this.orderNumber,
    required this.active,
    this.parentParameterId,
    this.type = 2,
    this.code = 'CATEGORIA_PRODUCTO',
  });

  final int id;
  final int parameterId;
  final String name;
  final String? shortName;
  final int orderNumber;
  final bool active;
  final int? parentParameterId;
  final int type;
  final String code;
}
