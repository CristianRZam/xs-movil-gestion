import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/usecases/sale_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SaleStatus { initial, loading, success, failure }

enum SaleDateFilter { all, today, week, month, custom }

class SaleState {
  final SaleStatus status;
  final List<Sale> sales;
  final List<Product> products;
  final bool? cashOpen;
  final String? error;
  final bool saved;
  final bool cancelled;
  final bool cancellationRestoredOrder;
  final int totalProducts;
  final bool isLoadingMoreProducts;
  final int salesPage;
  final bool hasMoreSales;
  final bool isLoadingMoreSales;
  final SaleDateFilter dateFilter;
  final DateTime? fromDate;
  final DateTime? toDate;

  const SaleState({
    this.status = SaleStatus.initial,
    this.sales = const [],
    this.products = const [],
    this.cashOpen,
    this.error,
    this.saved = false,
    this.cancelled = false,
    this.cancellationRestoredOrder = false,
    this.totalProducts = 0,
    this.isLoadingMoreProducts = false,
    this.salesPage = 0,
    this.hasMoreSales = false,
    this.isLoadingMoreSales = false,
    this.dateFilter = SaleDateFilter.all,
    this.fromDate,
    this.toDate,
  });

  bool get hasMoreProducts => products.length < totalProducts;

  SaleState copyWith({
    SaleStatus? status,
    List<Sale>? sales,
    List<Product>? products,
    Object? cashOpen = _sentinel,
    Object? error = _sentinel,
    bool? saved,
    bool? cancelled,
    bool? cancellationRestoredOrder,
    int? totalProducts,
    bool? isLoadingMoreProducts,
    int? salesPage,
    bool? hasMoreSales,
    bool? isLoadingMoreSales,
    SaleDateFilter? dateFilter,
    Object? fromDate = _sentinel,
    Object? toDate = _sentinel,
  }) => SaleState(
    status: status ?? this.status,
    sales: sales ?? this.sales,
    products: products ?? this.products,
    cashOpen: identical(cashOpen, _sentinel)
        ? this.cashOpen
        : cashOpen as bool?,
    error: identical(error, _sentinel) ? this.error : error as String?,
    saved: saved ?? this.saved,
    cancelled: cancelled ?? this.cancelled,
    cancellationRestoredOrder:
        cancellationRestoredOrder ?? this.cancellationRestoredOrder,
    totalProducts: totalProducts ?? this.totalProducts,
    isLoadingMoreProducts: isLoadingMoreProducts ?? this.isLoadingMoreProducts,
    salesPage: salesPage ?? this.salesPage,
    hasMoreSales: hasMoreSales ?? this.hasMoreSales,
    isLoadingMoreSales: isLoadingMoreSales ?? this.isLoadingMoreSales,
    dateFilter: dateFilter ?? this.dateFilter,
    fromDate: identical(fromDate, _sentinel)
        ? this.fromDate
        : fromDate as DateTime?,
    toDate: identical(toDate, _sentinel) ? this.toDate : toDate as DateTime?,
  );

  static const _sentinel = Object();
}

class LoadSales {
  const LoadSales({
    this.filter = SaleDateFilter.all,
    this.fromDate,
    this.toDate,
  });
  final SaleDateFilter filter;
  final DateTime? fromDate;
  final DateTime? toDate;
}

class LoadMoreSales {
  const LoadMoreSales();
}

class LoadMoreSaleProducts {
  const LoadMoreSaleProducts();
}

class SearchSaleProducts {
  const SearchSaleProducts(this.query);
  final String query;
}

class SaveSale {
  const SaveSale(this.sale);
  final Sale sale;
}

class CancelSale {
  const CancelSale(this.saleId, this.reason, {required this.restoredOrder});
  final int saleId;
  final String reason;
  final bool restoredOrder;
}

class ClearSaleMessage {
  const ClearSaleMessage();
}

class SaleBloc extends Bloc<Object, SaleState> {
  SaleBloc(
    this.getSales,
    this.createSale,
    this.cancelSale,
    this.getProducts,
    this.existsCash,
  ) : super(const SaleState()) {
    on<LoadSales>(_load);
    on<LoadMoreSales>(_loadMoreSales);
    on<LoadMoreSaleProducts>(_loadMoreProducts);
    on<SearchSaleProducts>(_searchProducts);
    on<SaveSale>(_save);
    on<CancelSale>(_cancel);
    on<ClearSaleMessage>(
      (_, emit) => emit(
        state.copyWith(
          error: null,
          saved: false,
          cancelled: false,
          cancellationRestoredOrder: false,
        ),
      ),
    );
  }

  final GetSalesUseCase getSales;
  final CreateSaleUseCase createSale;
  final CancelSaleUseCase cancelSale;
  final GetProductViewUseCase getProducts;
  final ExistsOpenCashSessionUseCase existsCash;

  Future<void> _load(LoadSales event, Emitter<SaleState> emit) async {
    emit(state.copyWith(status: SaleStatus.loading, error: null));
    final sales = await getSales(
      page: 0,
      size: EnvConfig.salesAndOrdersPageSize,
      from: event.fromDate,
      to: event.toDate,
    );
    final products = await getProducts(
      ProductViewRequest(
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );
    final cash = await existsCash();
    sales.fold(
      (failure) => emit(
        state.copyWith(status: SaleStatus.failure, error: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: SaleStatus.success,
          sales: page.sales,
          salesPage: page.page,
          hasMoreSales: page.hasMore,
          isLoadingMoreSales: false,
          dateFilter: event.filter,
          fromDate: event.fromDate,
          toDate: event.toDate,
          products: products.fold(
            (_) => state.products,
            (value) => value.products,
          ),
          totalProducts: products.fold(
            (_) => state.totalProducts,
            (value) => value.totalProducts,
          ),
          cashOpen: cash.fold((_) => false, (value) => value),
        ),
      ),
    );
  }

  Future<void> _loadMoreSales(
    LoadMoreSales event,
    Emitter<SaleState> emit,
  ) async {
    if (!state.hasMoreSales || state.isLoadingMoreSales) return;
    emit(state.copyWith(isLoadingMoreSales: true));
    final result = await getSales(
      page: state.salesPage + 1,
      size: EnvConfig.salesAndOrdersPageSize,
      from: state.fromDate,
      to: state.toDate,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMoreSales: false, error: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          sales: [...state.sales, ...page.sales],
          salesPage: page.page,
          hasMoreSales: page.hasMore,
          isLoadingMoreSales: false,
        ),
      ),
    );
  }

  Future<void> _loadMoreProducts(
    LoadMoreSaleProducts event,
    Emitter<SaleState> emit,
  ) async {
    if (!state.hasMoreProducts || state.isLoadingMoreProducts) return;
    emit(state.copyWith(isLoadingMoreProducts: true));
    final page = state.products.length ~/ EnvConfig.productPageSize;
    final result = await getProducts(
      ProductViewRequest(
        page: page,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoadingMoreProducts: false, error: failure.message),
      ),
      (response) => emit(
        state.copyWith(
          products: [...state.products, ...response.products],
          totalProducts: response.totalProducts,
          isLoadingMoreProducts: false,
        ),
      ),
    );
  }

  Future<void> _searchProducts(
    SearchSaleProducts event,
    Emitter<SaleState> emit,
  ) async {
    final result = await getProducts(
      ProductViewRequest(
        name: event.query.isEmpty ? null : event.query,
        page: 0,
        size: EnvConfig.productPageSize,
        status: true,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (response) => emit(
        state.copyWith(
          products: response.products,
          totalProducts: response.totalProducts,
        ),
      ),
    );
  }

  Future<void> _save(SaveSale event, Emitter<SaleState> emit) async {
    emit(state.copyWith(status: SaleStatus.loading));
    final result = await createSale(event.sale);
    result.fold(
      (failure) => emit(
        state.copyWith(status: SaleStatus.failure, error: failure.message),
      ),
      (_) {
        emit(state.copyWith(saved: true));
        add(
          LoadSales(
            filter: state.dateFilter,
            fromDate: state.fromDate,
            toDate: state.toDate,
          ),
        );
      },
    );
  }

  Future<void> _cancel(CancelSale event, Emitter<SaleState> emit) async {
    emit(state.copyWith(status: SaleStatus.loading, error: null));
    final result = await cancelSale(event.saleId, event.reason);
    result.fold(
      (failure) => emit(
        state.copyWith(status: SaleStatus.failure, error: failure.message),
      ),
      (_) {
        emit(
          state.copyWith(
            cancelled: true,
            cancellationRestoredOrder: event.restoredOrder,
          ),
        );
        add(
          LoadSales(
            filter: state.dateFilter,
            fromDate: state.fromDate,
            toDate: state.toDate,
          ),
        );
      },
    );
  }
}
