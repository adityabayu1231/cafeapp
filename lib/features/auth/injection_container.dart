import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/check_auth_status_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/verify_otp_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'domain/usecases/register_usecase.dart';
import 'presentation/bloc/register_bloc.dart';

final sl = GetIt.instance;

Future<void> initAuthModule({void Function()? onUnauthenticated}) async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient(secureStorage: sl(), onUnauthenticated: onUnauthenticated).dio,
    );
  }

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl(), sl()));

  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    verifyOtpUseCase: sl(),
    checkAuthStatusUseCase: sl(),
    logoutUseCase: sl(),
    secureStorage: sl(),
  ));

  sl.registerFactory(() => RegisterBloc(registerUseCase: sl()));
}