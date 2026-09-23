import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_create_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_request.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_request.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_view_request.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductView extends ProductEvent {
  final ProductViewRequest request;

  const LoadProductView(this.request);

  @override
  List<Object?> get props => [request];
}

class FilterProductView extends ProductEvent {
  final ProductViewRequest request;

  const FilterProductView(this.request);

  @override
  List<Object?> get props => [request];
}

class ClearProductFilter extends ProductEvent {
  const ClearProductFilter();
}

class LoadProductForm extends ProductEvent {
  final ProductFormRequest request;

  const LoadProductForm(this.request);

  @override
  List<Object?> get props => [request];
}

class ClearProductForm extends ProductEvent {
  const ClearProductForm();
}

class ClearProductError extends ProductEvent {
  const ClearProductError();
}

class CreateProduct extends ProductEvent {
  final ProductRequest request;

  const CreateProduct(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateProduct extends ProductEvent {
  final ProductRequest request;

  const UpdateProduct(this.request);

  @override
  List<Object?> get props => [request];
}

class ClearSavedProduct extends ProductEvent {
  const ClearSavedProduct();
}

class DeleteProduct extends ProductEvent {
  final int id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateProductStatus extends ProductEvent {
  const UpdateProductStatus(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

class ClearDeletedProduct extends ProductEvent {
  const ClearDeletedProduct();
}

class ClearUpdatedProductStatus extends ProductEvent {
  const ClearUpdatedProductStatus();
}

class LoadInventoryMovements extends ProductEvent {
  final int productId;

  const LoadInventoryMovements(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearInventoryMovements extends ProductEvent {
  const ClearInventoryMovements();
}

class CreateInventoryMovement extends ProductEvent {
  final InventoryMovementCreateRequest request;

  const CreateInventoryMovement(this.request);

  @override
  List<Object?> get props => [request];
}

class ClearSavedInventoryMovement extends ProductEvent {
  const ClearSavedInventoryMovement();
}

class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}
