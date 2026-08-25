import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/cafe_remote_datasource.dart';
import 'data/datasources/cafe_detail_remote_datasource.dart';
import 'data/repositories/cafe_repository_impl.dart';
import 'data/repositories/cafe_detail_repository_impl.dart';
import 'domain/repositories/cafe_repository.dart';
import 'domain/repositories/cafe_detail_repository.dart';
import 'domain/usecases/get_cafes_usecase.dart';
import 'domain/usecases/get_cafe_detail_usecase.dart';
import 'presentation/bloc/cafe_list_bloc.dart';
import 'presentation/bloc/cafe_detail_bloc.dart';

final sl = GetIt.instance;

Future<void> initCafeModule({void Function()? onUnauthenticated}) async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient(secureStorage: sl(), onUnauthenticated: onUnauthenticated).dio,
    );
  }

  sl.registerLazySingleton<CafeRemoteDataSource>(() => CafeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CafeRepository>(() => CafeRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCafesUseCase(sl()));
  sl.registerFactory(() => CafeListBloc(getCafesUseCase: sl()));

  sl.registerLazySingleton<CafeDetailRemoteDataSource>(() => CafeDetailRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CafeDetailRepository>(() => CafeDetailRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetCafeDetailUseCase(sl()));
  sl.registerFactory(() => CafeDetailBloc(getCafeDetailUseCase: sl()));
}