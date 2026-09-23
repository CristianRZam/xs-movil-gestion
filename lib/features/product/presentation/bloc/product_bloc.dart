import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/create_inventory_movement_usecase.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_response.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/create_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_form_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/update_product_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_product_view_usecase.dart';

import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductViewUseCase getProductViewUseCase;
  final GetProductFormUseCase getProductFormUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final GetInventoryMovementsUseCase getInventoryMovementsUseCase;
  final CreateInventoryMovementUseCase createInventoryMovementUseCase;

  ProductBloc(
    this.getProductViewUseCase,
    this.getProductFormUseCase,
    this.createProductUseCase,
    this.updateProductUseCase,
    this.deleteProductUseCase,
    this.getInventoryMovementsUseCase,
    this.createInventoryMovementUseCase,
  ) : super(const ProductState()) {
    on<LoadProductView>(_loadProductView);

    on<FilterProductView>(_filterProductView);

    on<ClearProductFilter>(_clearFilter);

    on<LoadMoreProducts>(_loadMoreProducts);

    on<LoadProductForm>(_loadProductForm);

    on<ClearProductForm>(_clearProductForm);

    on<CreateProduct>(_createProduct);

    on<UpdateProduct>(_updateProduct);

    on<ClearSavedProduct>(_clearSavedProduct);

    on<DeleteProduct>(_deleteProduct);

    on<ClearDeletedProduct>(_clearDeletedProduct);

    on<LoadInventoryMovements>(_loadInventoryMovements);

    on<CreateInventoryMovement>(_createInventoryMovement);

    on<ClearInventoryMovements>(_clearInventoryMovements);

    on<ClearSavedInventoryMovement>(_clearSavedInventoryMovement);
  }

  Future<void> _loadProductView(
    LoadProductView event,
    Emitter<ProductState> emit,
  ) async {
    await _getProducts(event.request, emit);
  }

  Future<void> _filterProductView(
    FilterProductView event,
    Emitter<ProductState> emit,
  ) async {
    await _getProducts(event.request, emit);
  }

  Future<void> _clearFilter(
    ClearProductFilter event,
    Emitter<ProductState> emit,
  ) async {
    final request = ProductViewRequest(
      page: 0,
      size: EnvConfig.productPageSize,
    );

    await _getProducts(request, emit);
  }

  Future<void> _loadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final response = state.response;
    final request = state.currentRequest;
    if (response == null ||
        request == null ||
        response.products.length >= response.totalProducts ||
        state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    final nextRequest = request.copyWith(page: request.page + 1);
    final result = await getProductViewUseCase(nextRequest);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingMore: false,
          errorCode: failure.code,
          errorMessage: failure.message,
        ),
      ),
      (nextResponse) => emit(
        state.copyWith(
          isLoadingMore: false,
          currentRequest: nextRequest,
          response: _mergeResponses(response, nextResponse),
        ),
      ),
    );
  }

  Future<void> _getProducts(
    ProductViewRequest request,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await getProductViewUseCase(request);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            status: ProductStatus.success,
            response: response,
            currentRequest: request,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  ProductViewResponse _mergeResponses(
    ProductViewResponse current,
    ProductViewResponse next,
  ) {
    return ProductViewResponse(
      products: [...current.products, ...next.products],
      totalProducts: next.totalProducts,
      activeProducts: next.activeProducts,
      inactiveProducts: next.inactiveProducts,
      totalStock: next.totalStock,
      categories: next.categories,
      unitMeasures: next.unitMeasures,
      valuationMethods: next.valuationMethods,
    );
  }

  Future<void> _loadProductForm(
    LoadProductForm event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await getProductFormUseCase(event.request);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

      (response) {
        emit(
          state.copyWith(status: ProductStatus.success, formResponse: response),
        );
      },
    );
  }

  Future<void> _clearProductForm(
    ClearProductForm event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(formResponse: null));
  }

  Future<void> _createProduct(
    CreateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await createProductUseCase(event.request);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

      (product) {
        emit(state.copyWith(status: ProductStatus.success, product: product));
      },
    );
  }

  Future<void> _updateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await updateProductUseCase(event.request);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

      (product) {
        emit(state.copyWith(status: ProductStatus.success, product: product));
      },
    );
  }

  Future<void> _clearSavedProduct(
    ClearSavedProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(product: null));
  }

  Future<void> _deleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await deleteProductUseCase(event.id);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

      (deleted) {
        emit(state.copyWith(status: ProductStatus.success, deleted: deleted));
      },
    );
  }

  Future<void> _clearDeletedProduct(
    ClearDeletedProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(deleted: null));
  }

  Future<void> _loadInventoryMovements(
    LoadInventoryMovements event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await getInventoryMovementsUseCase(
      event.productId,
      page: 0,
      size: 20,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

      (movementPage) {
        emit(
          state.copyWith(
            status: ProductStatus.success,
            inventoryMovements: movementPage.movements,
          ),
        );
      },
    );
  }

  Future<void> _createInventoryMovement(
    CreateInventoryMovement event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    final result = await createInventoryMovementUseCase(event.request);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: ProductStatus.failure,
            errorCode: failure.code,
            errorMessage: failure.message,
          ),
        );
      },

      (movement) {
        emit(
          state.copyWith(
            status: ProductStatus.success,
            inventoryMovement: movement,
          ),
        );
      },
    );
  }

  Future<void> _clearInventoryMovements(
    ClearInventoryMovements event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(inventoryMovements: null));
  }

  Future<void> _clearSavedInventoryMovement(
    ClearSavedInventoryMovement event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(inventoryMovement: null));
  }
}
