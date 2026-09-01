import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/wallet_remote_datasource.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'domain/repositories/wallet_repository.dart';
import 'domain/usecases/get_wallet_usecase.dart';
import 'presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> initWalletModule({void Function()? onUnauthenticated}) async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient(secureStorage: sl(), onUnauthenticated: onUnauthenticated).dio,
    );
  }

  sl.registerLazySingleton<WalletRemoteDataSource>(() => WalletRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetWalletUseCase(sl()));

  // WalletBloc harus singleton (bukan factory) — CheckoutBloc di [F]-4 akan
  // membaca/memicu instance yang sama untuk pre-check saldo, sama seperti
  // alasan CartBloc dibuat singleton di [F]-1.
  sl.registerLazySingleton(() => WalletBloc(getWalletUseCase: sl()));
}