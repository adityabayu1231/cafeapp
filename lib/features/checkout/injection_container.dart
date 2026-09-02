import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import '../cart/presentation/bloc/cart_bloc.dart';
import '../wallet/presentation/bloc/wallet_bloc.dart';
import 'data/datasources/checkout_remote_datasource.dart';
import 'data/repositories/checkout_repository_impl.dart';
import 'domain/repositories/checkout_repository.dart';
import 'domain/usecases/create_order_usecase.dart';
import 'presentation/bloc/checkout_bloc.dart';

final sl = GetIt.instance;

Future<void> initCheckoutModule({void Function()? onUnauthenticated}) async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient(secureStorage: sl(), onUnauthenticated: onUnauthenticated).dio,
    );
  }

  sl.registerLazySingleton<CheckoutRemoteDataSource>(() => CheckoutRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CheckoutRepository>(() => CheckoutRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));

  // Factory: CheckoutBloc dibuat baru tiap kali halaman checkout dibuka,
  // tapi tetap membaca instance CartBloc/WalletBloc singleton yang sama
  // (sudah didaftarkan di modul masing-masing sebelum modul ini di-init).
  sl.registerFactory(() => CheckoutBloc(
    createOrderUseCase: sl(),
    cartBloc: sl<CartBloc>(),
    walletBloc: sl<WalletBloc>(),
  ));
}