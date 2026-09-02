import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/order_remote_datasource.dart';
import 'data/repositories/order_repository_impl.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/usecases/cancel_order_usecase.dart';
import 'domain/usecases/get_order_detail_usecase.dart';
import 'domain/usecases/get_orders_usecase.dart';
import 'presentation/bloc/order_detail_bloc.dart';
import 'presentation/bloc/order_list_bloc.dart';

final sl = GetIt.instance;

Future<void> initOrderModule({void Function()? onUnauthenticated}) async {
  if (!sl.isRegistered<SecureStorage>()) {
    sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }
  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(
          () => DioClient(secureStorage: sl(), onUnauthenticated: onUnauthenticated).dio,
    );
  }

  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl()));

  sl.registerFactory(() => OrderListBloc(getOrdersUseCase: sl()));
  sl.registerFactory(() => OrderDetailBloc(
    getOrderDetailUseCase: sl(),
    cancelOrderUseCase: sl(),
  ));
}