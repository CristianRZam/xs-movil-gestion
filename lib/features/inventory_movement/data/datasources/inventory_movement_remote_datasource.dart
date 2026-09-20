import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_create_request_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_detail_model.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/model/inventory_movement_model.dart';

abstract class InventoryMovementRemoteDataSource {

  Future<List<InventoryMovementDetailModel>> getInventoryMovements(
      int productId,
      );

  Future<InventoryMovementModel> createInventoryMovement(
      InventoryMovementCreateRequestModel request,
      );

}