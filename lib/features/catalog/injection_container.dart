import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/catalog_repository_impl.dart';
import 'domain/repositories/catalog_repository.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'presentation/bloc/catalog_bloc.dart';

final sl = GetIt.instance;

Future<void> initCatalogModule({void Function()? onUnauthenticated}) async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient(secureStorage: sl(), onUnauthenticated: onUnauthenticated).dio,
    );
  }

  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerFactory(() => CatalogBloc(getProductsUseCase: sl()));
}