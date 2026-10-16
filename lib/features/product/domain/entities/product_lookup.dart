class ProductLookup {
  const ProductLookup({
    required this.id,
    required this.name,
    required this.code,
    required this.active,
    required this.deleted,
  });

  final int id;
  final String name;
  final String code;
  final bool active;
  final bool deleted;

  factory ProductLookup.fromJson(Map<String, dynamic> json) => ProductLookup(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String? ?? '',
    code: json['code'] as String? ?? '',
    active: json['active'] as bool? ?? false,
    deleted: json['deleted'] as bool? ?? false,
  );
}
