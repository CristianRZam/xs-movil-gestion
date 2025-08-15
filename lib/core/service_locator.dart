import 'package:get_it/get_it.dart';
import 'package:app_movil_sistema/core/network/api_client.dart';
import 'package:app_movil_sistema/core/storage/token_storage.dart';
import 'package:app_movil_sistema/features/login/data/datasources/login_remote_datasource.dart';
import 'package:app_movil_sistema/features/login/data/repositories/auth_repository_impl.dart';
import 'package:app_movil_sistema/features/login/domain/usecases/login_usecase.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // Servicios base
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  // Data sources
  getIt.registerLazySingleton<LoginRemoteDataSource>(
        () => LoginRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repositorios
  getIt.registerLazySingleton<AuthRepositoryImpl>(
        () => AuthRepositoryImpl(
      getIt<LoginRemoteDataSource>(),
      getIt<TokenStorage>(),
    ),
  );

  // Casos de uso
  getIt.registerFactory<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepositoryImpl>()),
  );
}
