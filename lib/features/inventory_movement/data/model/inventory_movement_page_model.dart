import '../../domain/entities/inventory_movement_page.dart';
import 'inventory_movement_detail_model.dart';

class InventoryMovementPageModel {
  const InventoryMovementPageModel({
    required this.movements,
    required this.totalElements,
    required this.page,
    required this.size,
    required this.hasMore,
  });

  final List<InventoryMovementDetailModel> movements;
  final int totalElements;
  final int page;
  final int size;
  final bool hasMore;

  factory InventoryMovementPageModel.fromJson(Map<String, dynamic> json) {
    return InventoryMovementPageModel(
      movements: (json['movements'] as List<dynamic>? ?? const [])
          .map(
            (item) => InventoryMovementDetailModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      totalElements: (json['totalElements'] as num? ?? 0).toInt(),
      page: (json['page'] as num? ?? 0).toInt(),
      size: (json['size'] as num? ?? 0).toInt(),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  InventoryMovementPage toEntity() => InventoryMovementPage(
    movements: movements.map((movement) => movement.toEntity()).toList(),
    totalElements: totalElements,
    page: page,
    size: size,
    hasMore: hasMore,
  );
}
