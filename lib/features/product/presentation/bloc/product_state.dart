import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/entities/inventory_movement_detail.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_form_response.dart';

import '../../domain/entities/product_view_response.dart';
import '../../domain/entities/product_view_request.dart';

enum ProductStatus {
  initial,
  loading,
  success,
  failure,
}

class ProductState {
  final ProductStatus status;
  final ProductViewResponse? response;
  final ProductFormResponse? formResponse;
  final int? errorCode;
  final String? errorMessage;
  final Product? product;
  final bool? deleted;
  final List<InventoryMovementDetail>? inventoryMovements;
  final InventoryMovement? inventoryMovement;
  final ProductViewRequest? currentRequest;
  final bool isLoadingMore;

  const ProductState({
    this.status = ProductStatus.initial,
    this.response,
    this.formResponse,
    this.errorCode,
    this.errorMessage,
    this.product,
    this.deleted,
    this.inventoryMovements,
    this.inventoryMovement,
    this.currentRequest,
    this.isLoadingMore = false,
  });

  ProductState copyWith({
    ProductStatus? status,
    ProductViewResponse? response,
    Object? formResponse = _sentinel,
    int? errorCode,
    String? errorMessage,
    Object? product = _sentinel,
    Object? deleted = _sentinel,
    Object? inventoryMovements = _sentinel,
    Object? inventoryMovement = _sentinel,
    Object? currentRequest = _sentinel,
    bool? isLoadingMore,
  }) {
    return ProductState(
      status: status ?? this.status,
      response: response ?? this.response,
      formResponse: identical(formResponse, _sentinel)
          ? this.formResponse
          : formResponse as ProductFormResponse?,
      product: identical(product, _sentinel)
          ? this.product
          : product as Product?,
      deleted: identical(deleted, _sentinel)
          ? this.deleted
          : deleted as bool?,
      inventoryMovements: identical(
        inventoryMovements,
        _sentinel,
      )
          ? this.inventoryMovements
          : inventoryMovements as List<InventoryMovementDetail>?,

      inventoryMovement: identical(
        inventoryMovement,
        _sentinel,
      )
          ? this.inventoryMovement
          : inventoryMovement as InventoryMovement?,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      currentRequest: identical(currentRequest, _sentinel)
          ? this.currentRequest
          : currentRequest as ProductViewRequest?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  static const _sentinel = Object();
}
