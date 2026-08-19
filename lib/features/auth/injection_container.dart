import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initAuthModule() async {
  // Core
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => DioClient().dio);
  }

  // Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(sl()),
  );

  // Domain
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Presentation
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
}