import 'package:app_movil_sistema/features/inventory_count/domain/entities/inventory_count.dart';

enum InventoryCountStatus { initial, loading, success, failure }

class InventoryCountState {
  final InventoryCountStatus status;
  final InventoryCount? session;
  final List<InventoryCountItem> items;
  final String? error;
  const InventoryCountState({
    this.status = InventoryCountStatus.initial,
    this.session,
    this.items = const [],
    this.error,
  });
  InventoryCountState copyWith({
    InventoryCountStatus? status,
    InventoryCount? session,
    List<InventoryCountItem>? items,
    String? error,
  }) => InventoryCountState(
    status: status ?? this.status,
    session: session ?? this.session,
    items: items ?? this.items,
    error: error,
  );
}
