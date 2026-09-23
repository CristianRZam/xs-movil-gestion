import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/core/config/env_config.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product.dart';
import 'package:app_movil_sistema/features/product/domain/entities/product_view_request.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';
import 'package:app_movil_sistema/features/sale/domain/entities/sale.dart';
import 'package:app_movil_sistema/features/sale/domain/usecases/sale_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SaleStatus { initial, loading, success, failure }
class SaleState {
  final SaleStatus status; final List<Sale> sales; final List<Product> products; final bool? cashOpen; final String? error; final bool saved; final int totalProducts; final bool isLoadingMoreProducts;
  const SaleState({this.status = SaleStatus.initial, this.sales = const [], this.products = const [], this.cashOpen, this.error, this.saved = false, this.totalProducts = 0, this.isLoadingMoreProducts = false});
  bool get hasMoreProducts => products.length < totalProducts;
  SaleState copyWith({SaleStatus? status, List<Sale>? sales, List<Product>? products, bool? cashOpen, String? error, bool? saved, int? totalProducts, bool? isLoadingMoreProducts}) => SaleState(status: status ?? this.status, sales: sales ?? this.sales, products: products ?? this.products, cashOpen: cashOpen ?? this.cashOpen, error: error, saved: saved ?? this.saved, totalProducts: totalProducts ?? this.totalProducts, isLoadingMoreProducts: isLoadingMoreProducts ?? this.isLoadingMoreProducts);
}
class LoadSales { const LoadSales(); }
class LoadMoreSaleProducts { const LoadMoreSaleProducts(); }
class SearchSaleProducts { final String query; const SearchSaleProducts(this.query); }
class SaveSale { final Sale sale; const SaveSale(this.sale); }
class ClearSaleMessage { const ClearSaleMessage(); }

class SaleBloc extends Bloc<Object, SaleState> {
  final GetSalesUseCase getSales; final CreateSaleUseCase createSale; final GetProductViewUseCase getProducts; final ExistsOpenCashSessionUseCase existsCash;
  SaleBloc(this.getSales, this.createSale, this.getProducts, this.existsCash) : super(const SaleState()) { on<LoadSales>(_load); on<LoadMoreSaleProducts>(_loadMoreProducts); on<SearchSaleProducts>(_searchProducts); on<SaveSale>(_save); on<ClearSaleMessage>((_, emit) => emit(state.copyWith(error: null, saved: false))); }
  Future<void> _load(LoadSales event, Emitter<SaleState> emit) async { emit(state.copyWith(status: SaleStatus.loading)); final sales = await getSales(); final products = await getProducts(ProductViewRequest(page: 0, size: EnvConfig.productPageSize, status: true)); final cash = await existsCash(); emit(SaleState(status: SaleStatus.success, sales: sales.fold((f) => state.sales, (v) => v), products: products.fold((f) => state.products, (v) => v.products), totalProducts: products.fold((_) => state.totalProducts, (v) => v.totalProducts), cashOpen: cash.fold((_) => false, (v) => v))); }
  Future<void> _loadMoreProducts(LoadMoreSaleProducts event, Emitter<SaleState> emit) async { if (!state.hasMoreProducts || state.isLoadingMoreProducts) return; emit(state.copyWith(isLoadingMoreProducts: true)); final page = state.products.length ~/ EnvConfig.productPageSize; final result = await getProducts(ProductViewRequest(page: page, size: EnvConfig.productPageSize, status: true)); result.fold((failure) => emit(state.copyWith(isLoadingMoreProducts: false, error: failure.message)), (response) => emit(state.copyWith(products: [...state.products, ...response.products], totalProducts: response.totalProducts, isLoadingMoreProducts: false))); }
  Future<void> _searchProducts(SearchSaleProducts event, Emitter<SaleState> emit) async { final result = await getProducts(ProductViewRequest(name: event.query.isEmpty ? null : event.query, page: 0, size: EnvConfig.productPageSize, status: true)); result.fold((failure) => emit(state.copyWith(error: failure.message)), (response) => emit(state.copyWith(products: response.products, totalProducts: response.totalProducts))); }
  Future<void> _save(SaveSale event, Emitter<SaleState> emit) async { emit(state.copyWith(status: SaleStatus.loading)); final result = await createSale(event.sale); await result.fold((f) async => emit(state.copyWith(status: SaleStatus.failure, error: f.message)), (_) async { final sales = await getSales(); final products = await getProducts(ProductViewRequest(page: 0, size: EnvConfig.productPageSize, status: true)); emit(state.copyWith(status: SaleStatus.success, sales: sales.fold((_) => state.sales, (v) => v), products: products.fold((_) => state.products, (v) => v.products), totalProducts: products.fold((_) => state.totalProducts, (v) => v.totalProducts), saved: true)); }); }
}
