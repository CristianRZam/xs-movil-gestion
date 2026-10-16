class Parameter {
  final int id;
  final int parameterId;
  final int? parentParameterId;
  final String name;
  final String shortName;
  final int orderNumber;
  final bool active;

  const Parameter({
    required this.id,
    required this.parameterId,
    required this.parentParameterId,
    required this.name,
    required this.shortName,
    this.orderNumber = 0,
    required this.active,
  });
}
