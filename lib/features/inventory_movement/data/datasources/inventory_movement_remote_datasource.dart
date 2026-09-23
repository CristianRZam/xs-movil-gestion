import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_create_request_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_page_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_model.dart';

abstract class InventoryMovementRemoteDataSource {
  Future<InventoryMovementPageModel> getInventoryMovements(
    int productId, {
    required int page,
    required int size,
  });

  Future<InventoryMovementModel> createInventoryMovement(
    InventoryMovementCreateRequestModel request,
  );
}
