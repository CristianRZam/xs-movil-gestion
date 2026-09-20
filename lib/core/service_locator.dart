import 'package:app_movil_sistema/features/cash_session/data/datasources/cash_session_remote_datasource.dart';
import 'package:app_movil_sistema/features/cash_session/data/datasources/impl/cash_session_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/cash_session/data/repositories/cash_session_repository_impl.dart';
import 'package:app_movil_sistema/features/cash_session/domain/repositories/cash_session_repository.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/close_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/exists_open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/get_cash_session_history_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/get_current_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/cash_session/domain/usecases/open_cash_session_usecase.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/datasources/impl/inventory_movement_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/datasources/inventory_movement_remote_datasource.dart';
import 'package:app_movil_sistema/features/inventory_movement/data/repositories/inventory_movement_repository_impl.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/repositories/inventory_movement_repository.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/create_inventory_movement_usecase.dart';
import 'package:app_movil_sistema/features/inventory_movement/domain/usecases/get_inventory_movements_usecase.dart';
import 'package:app_movil_sistema/features/product/data/datasources/impl/product_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/create_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_form_usecase.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/update_product_usecase.dart';
import 'package:get_it/get_it.dart';

import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';

/// LOGIN
import 'package:app_movil_sistema/features/login/data/datasources/login_remote_datasource.dart';
import 'package:app_movil_sistema/features/login/data/repositories/auth_repository_impl.dart';
import 'package:app_movil_sistema/features/login/domain/repositories/auth_respository.dart';
import 'package:app_movil_sistema/features/login/domain/usecases/login_usecase.dart';

/// PRODUCT
import 'package:app_movil_sistema/features/product/data/datasources/product_remote_datasource.dart';
import 'package:app_movil_sistema/features/product/data/repositories/product_repository_impl.dart';
import 'package:app_movil_sistema/features/product/domain/repositories/product_repository.dart';
import 'package:app_movil_sistema/features/product/domain/usecases/get_product_view_usecase.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // ============================
  // Servicios base
  // ============================

  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(),
  );

  getIt.registerLazySingleton<TokenStorage>(
        () => TokenStorage(),
  );

  // ============================
  // LOGIN
  // ============================

  /// DataSource
  getIt.registerLazySingleton<LoginRemoteDataSource>(
        () => LoginRemoteDataSourceImpl(
      getIt<ApiClient>(),
    ),
  );

  /// Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<LoginRemoteDataSource>(),
      getIt<TokenStorage>(),
    ),
  );

  /// UseCase
  getIt.registerFactory<LoginUseCase>(
        () => LoginUseCase(
      getIt<AuthRepository>(),
    ),
  );

  // ============================
  // PRODUCTOS
  // ============================

  /// DataSource
  getIt.registerLazySingleton<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(
      getIt<ApiClient>(),
    ),
  );

  /// Repository
  getIt.registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(
      getIt<ProductRemoteDataSource>(),
    ),
  );

  /// UseCase
  getIt.registerFactory<GetProductViewUseCase>(
        () => GetProductViewUseCase(
      getIt<ProductRepository>(),
    ),
  );

  getIt.registerFactory<GetProductFormUseCase>(
        () => GetProductFormUseCase(
      getIt<ProductRepository>(),
    ),
  );

  getIt.registerFactory<CreateProductUseCase>(
        () => CreateProductUseCase(
      getIt<ProductRepository>(),
    ),
  );

  getIt.registerFactory<UpdateProductUseCase>(
        () => UpdateProductUseCase(
      getIt<ProductRepository>(),
    ),
  );

  getIt.registerFactory<DeleteProductUseCase>(
        () => DeleteProductUseCase(
      getIt<ProductRepository>(),
    ),
  );

  // ============================
  // INVENTORY MOVEMENTS
  // ============================

  /// DataSource
  getIt.registerLazySingleton<InventoryMovementRemoteDataSource>(
        () => InventoryMovementRemoteDataSourceImpl(
      getIt<ApiClient>(),
    ),
  );

  /// Repository
  getIt.registerLazySingleton<InventoryMovementRepository>(
        () => InventoryMovementRepositoryImpl(
      getIt<InventoryMovementRemoteDataSource>(),
    ),
  );

  /// UseCase
  getIt.registerFactory<GetInventoryMovementsUseCase>(
        () => GetInventoryMovementsUseCase(
      getIt<InventoryMovementRepository>(),
    ),
  );

  getIt.registerFactory<CreateInventoryMovementUseCase>(
        () => CreateInventoryMovementUseCase(
      getIt<InventoryMovementRepository>(),
    ),
  );


  // ============================
// CASH SESSION
// ============================

  /// DataSource
  getIt.registerLazySingleton<CashSessionRemoteDataSource>(
        () => CashSessionRemoteDataSourceImpl(
      getIt<ApiClient>(),
    ),
  );

  /// Repository
  getIt.registerLazySingleton<CashSessionRepository>(
        () => CashSessionRepositoryImpl(
      getIt<CashSessionRemoteDataSource>(),
    ),
  );

  /// UseCase
  getIt.registerFactory<OpenCashSessionUseCase>(
        () => OpenCashSessionUseCase(
      getIt<CashSessionRepository>(),
    ),
  );

  getIt.registerFactory<GetCurrentCashSessionUseCase>(
        () => GetCurrentCashSessionUseCase(
      getIt<CashSessionRepository>(),
    ),
  );

  getIt.registerFactory<ExistsOpenCashSessionUseCase>(
        () => ExistsOpenCashSessionUseCase(
      getIt<CashSessionRepository>(),
    ),
  );

  getIt.registerFactory<CloseCashSessionUseCase>(
        () => CloseCashSessionUseCase(
      getIt<CashSessionRepository>(),
    ),
  );

  getIt.registerFactory<GetCashSessionHistoryUseCase>(
        () => GetCashSessionHistoryUseCase(
      getIt<CashSessionRepository>(),
    ),
  );
}