import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
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
import 'package:app_movil_sistema/features/product/domain/usecases/update_product_status_usecase.dart';
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
import 'package:app_movil_sistema/features/order/data/datasources/impl/order_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/order/data/datasources/order_remote_datasource.dart';
import 'package:app_movil_sistema/features/order/data/repositories/order_repository_impl.dart';
import 'package:app_movil_sistema/features/sale/data/datasources/sale_remote_datasource.dart';
import 'package:app_movil_sistema/features/sale/data/datasources/impl/sale_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:app_movil_sistema/features/sale/domain/repositories/sale_repository.dart';
import 'package:app_movil_sistema/features/sale/domain/usecases/sale_usecases.dart';
import 'package:app_movil_sistema/features/order/domain/repositories/order_repository.dart';
import 'package:app_movil_sistema/features/order/domain/usecases/order_usecases.dart';
import 'package:app_movil_sistema/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:app_movil_sistema/features/dashboard/data/datasources/impl/dashboard_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:app_movil_sistema/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:app_movil_sistema/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:app_movil_sistema/features/notification/data/datasources/impl/notification_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:app_movil_sistema/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:app_movil_sistema/features/notification/domain/repositories/notification_repository.dart';
import 'package:app_movil_sistema/features/notification/domain/usecases/notification_usecases.dart';
import 'package:app_movil_sistema/features/notification/presentation/bloc/notification_cubit.dart';
import 'package:app_movil_sistema/features/profile/data/datasources/impl/profile_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:app_movil_sistema/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:app_movil_sistema/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_movil_sistema/features/profile/domain/usecases/profile_usecases.dart';
import 'package:app_movil_sistema/features/category/data/datasources/category_remote_datasource.dart';
import 'package:app_movil_sistema/features/category/data/datasources/impl/category_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/category/data/repositories/category_repository_impl.dart';
import 'package:app_movil_sistema/features/category/domain/repositories/category_repository.dart';
import 'package:app_movil_sistema/features/category/domain/usecases/category_usecases.dart';
import 'package:app_movil_sistema/features/user/data/datasources/impl/user_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/user/data/datasources/user_remote_datasource.dart';
import 'package:app_movil_sistema/features/user/data/repositories/user_repository_impl.dart';
import 'package:app_movil_sistema/features/user/domain/repositories/user_repository.dart';
import 'package:app_movil_sistema/features/user/domain/usecases/user_usecases.dart';
import 'package:app_movil_sistema/features/role/data/datasources/impl/role_remote_datasource_impl.dart';
import 'package:app_movil_sistema/features/role/data/datasources/role_remote_datasource.dart';
import 'package:app_movil_sistema/features/role/data/repositories/role_repository_impl.dart';
import 'package:app_movil_sistema/features/role/domain/repositories/role_repository.dart';
import 'package:app_movil_sistema/features/role/domain/usecases/role_usecases.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<AccessControl>(
    () => AccessControl(
      mode: AuthorizationMode.permissions,
      permissionRequirements: const {
        AppCapability.dashboard: {'VIEW_DASHBOARD'},
        AppCapability.viewProducts: {'VIEW_PRODUCT'},
        AppCapability.manageProducts: {'EDIT_PRODUCT'},
        AppCapability.createProducts: {'CREATE_PRODUCT'},
        AppCapability.deleteProducts: {'DELETE_PRODUCT'},
        AppCapability.manageCategories: {'VIEW_PARAMETER'},
        AppCapability.manageUsers: {'VIEW_USER'},
        AppCapability.manageRoles: {'VIEW_ROLE', 'VIEW_PERMISSION'},
        AppCapability.assignRolePermissions: {'ASSIGN_PERMISSION'},
      },
    ),
  );
  // ============================
  // Servicios base
  // ============================

  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorage(getIt<AccessControl>()),
  );

  getIt.registerLazySingleton<SessionCoordinator>(
    () => SessionCoordinator(getIt<AccessControl>(), getIt<TokenStorage>()),
  );

  // ============================
  // LOGIN
  // ============================

  /// DataSource
  getIt.registerLazySingleton<LoginRemoteDataSource>(
    () => LoginRemoteDataSourceImpl(getIt<ApiClient>()),
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
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  // ============================
  // PRODUCTOS
  // ============================

  /// DataSource
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  /// Repository
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
  );

  /// UseCase
  getIt.registerFactory<GetProductViewUseCase>(
    () => GetProductViewUseCase(getIt<ProductRepository>()),
  );

  getIt.registerFactory<GetProductFormUseCase>(
    () => GetProductFormUseCase(getIt<ProductRepository>()),
  );

  getIt.registerFactory<CreateProductUseCase>(
    () => CreateProductUseCase(getIt<ProductRepository>()),
  );

  getIt.registerFactory<UpdateProductUseCase>(
    () => UpdateProductUseCase(getIt<ProductRepository>()),
  );

  getIt.registerFactory<UpdateProductStatusUseCase>(
    () => UpdateProductStatusUseCase(getIt<ProductRepository>()),
  );

  getIt.registerFactory<DeleteProductUseCase>(
    () => DeleteProductUseCase(getIt<ProductRepository>()),
  );

  // ============================
  // INVENTORY MOVEMENTS
  // ============================

  /// DataSource
  getIt.registerLazySingleton<InventoryMovementRemoteDataSource>(
    () => InventoryMovementRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  /// Repository
  getIt.registerLazySingleton<InventoryMovementRepository>(
    () => InventoryMovementRepositoryImpl(
      getIt<InventoryMovementRemoteDataSource>(),
    ),
  );

  /// UseCase
  getIt.registerFactory<GetInventoryMovementsUseCase>(
    () => GetInventoryMovementsUseCase(getIt<InventoryMovementRepository>()),
  );

  getIt.registerFactory<CreateInventoryMovementUseCase>(
    () => CreateInventoryMovementUseCase(getIt<InventoryMovementRepository>()),
  );

  // ============================
  // CASH SESSION
  // ============================

  /// DataSource
  getIt.registerLazySingleton<CashSessionRemoteDataSource>(
    () => CashSessionRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  /// Repository
  getIt.registerLazySingleton<CashSessionRepository>(
    () => CashSessionRepositoryImpl(getIt<CashSessionRemoteDataSource>()),
  );

  /// UseCase
  getIt.registerFactory<OpenCashSessionUseCase>(
    () => OpenCashSessionUseCase(getIt<CashSessionRepository>()),
  );

  getIt.registerFactory<GetCurrentCashSessionUseCase>(
    () => GetCurrentCashSessionUseCase(getIt<CashSessionRepository>()),
  );

  getIt.registerFactory<ExistsOpenCashSessionUseCase>(
    () => ExistsOpenCashSessionUseCase(getIt<CashSessionRepository>()),
  );

  getIt.registerFactory<CloseCashSessionUseCase>(
    () => CloseCashSessionUseCase(getIt<CashSessionRepository>()),
  );

  getIt.registerFactory<GetCashSessionHistoryUseCase>(
    () => GetCashSessionHistoryUseCase(getIt<CashSessionRepository>()),
  );

  // ============================
  // ORDERS
  // ============================
  getIt.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderRemoteDataSource>()),
  );

  getIt.registerFactory<GetOrdersUseCase>(
    () => GetOrdersUseCase(getIt<OrderRepository>()),
  );
  getIt.registerFactory<CreateOrderUseCase>(
    () => CreateOrderUseCase(getIt<OrderRepository>()),
  );
  getIt.registerFactory<UpdateOrderUseCase>(
    () => UpdateOrderUseCase(getIt<OrderRepository>()),
  );
  getIt.registerFactory<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(getIt<OrderRepository>()),
  );
  getIt.registerFactory<DeleteOrderUseCase>(
    () => DeleteOrderUseCase(getIt<OrderRepository>()),
  );

  // ============================
  // SALES
  // ============================
  getIt.registerLazySingleton<SaleRemoteDataSource>(
    () => SaleRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(getIt<SaleRemoteDataSource>()),
  );
  getIt.registerFactory<GetSalesUseCase>(
    () => GetSalesUseCase(getIt<SaleRepository>()),
  );
  getIt.registerFactory<CreateSaleUseCase>(
    () => CreateSaleUseCase(getIt<SaleRepository>()),
  );
  getIt.registerFactory<CancelSaleUseCase>(
    () => CancelSaleUseCase(getIt<SaleRepository>()),
  );
  getIt.registerFactory<GetCashSessionSalesSummaryUseCase>(
    () => GetCashSessionSalesSummaryUseCase(getIt<SaleRepository>()),
  );

  // ============================
  // DASHBOARD
  // ============================
  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()),
  );
  getIt.registerFactory<GetDashboardSummaryUseCase>(
    () => GetDashboardSummaryUseCase(getIt<DashboardRepository>()),
  );

  // ============================
  // NOTIFICATIONS
  // ============================
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt<NotificationRemoteDataSource>()),
  );
  getIt.registerFactory<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<GetUnreadNotificationCountUseCase>(
    () => GetUnreadNotificationCountUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<GetNotificationVisibleDaysUseCase>(
    () => GetNotificationVisibleDaysUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<MarkAllNotificationsAsReadUseCase>(
    () => MarkAllNotificationsAsReadUseCase(getIt<NotificationRepository>()),
  );

  // ============================
  // PROFILE
  // ============================
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );
  getIt.registerFactory<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerFactory<UpdateProfilePasswordUseCase>(
    () => UpdateProfilePasswordUseCase(getIt<ProfileRepository>()),
  );

  // ============================
  // CATEGORIAS DE PRODUCTOS
  // ============================
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<CategoryRemoteDataSource>()),
  );
  getIt.registerFactory<GetCategoriesUseCase>(
    () => GetCategoriesUseCase(getIt<CategoryRepository>()),
  );
  getIt.registerFactory<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(getIt<CategoryRepository>()),
  );
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
  );
  getIt.registerFactory<GetUsersUseCase>(
    () => GetUsersUseCase(getIt<UserRepository>()),
  );
  getIt.registerFactory<GetUserFormUseCase>(
    () => GetUserFormUseCase(getIt<UserRepository>()),
  );
  getIt.registerFactory<CreateUserUseCase>(
    () => CreateUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerFactory<UpdateUserUseCase>(
    () => UpdateUserUseCase(getIt<UserRepository>()),
  );
  getIt.registerFactory<UpdateUserStatusUseCase>(
    () => UpdateUserStatusUseCase(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<RoleRemoteDataSource>(
    () => RoleRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<RoleRepository>(
    () => RoleRepositoryImpl(getIt<RoleRemoteDataSource>()),
  );
  getIt.registerFactory<GetRolesUseCase>(
    () => GetRolesUseCase(getIt<RoleRepository>()),
  );
  getIt.registerFactory<GetRolePermissionsUseCase>(
    () => GetRolePermissionsUseCase(getIt<RoleRepository>()),
  );
  getIt.registerFactory<UpdateRolePermissionsUseCase>(
    () => UpdateRolePermissionsUseCase(getIt<RoleRepository>()),
  );
  getIt.registerLazySingleton<NotificationCubit>(
    () => NotificationCubit(
      getIt<GetNotificationsUseCase>(),
      getIt<GetUnreadNotificationCountUseCase>(),
      getIt<GetNotificationVisibleDaysUseCase>(),
      getIt<MarkNotificationAsReadUseCase>(),
      getIt<MarkAllNotificationsAsReadUseCase>(),
    ),
  );
}
