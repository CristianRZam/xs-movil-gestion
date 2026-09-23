class CategoryCreateRequest {
  const CategoryCreateRequest({
    required this.name,
    required this.shortName,
    required this.orderNumber,
  });

  final String name;
  final String? shortName;
  final int orderNumber;
}
