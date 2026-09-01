import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasources/cart_local_datasource.dart';
import 'data/repositories/cart_repository_impl.dart';
import 'domain/repositories/cart_repository.dart';
import 'domain/usecases/add_item_to_cart_usecase.dart';
import 'domain/usecases/clear_cart_usecase.dart';
import 'domain/usecases/get_cart_usecase.dart';
import 'domain/usecases/remove_item_from_cart_usecase.dart';
import 'presentation/bloc/cart_bloc.dart';

final sl = GetIt.instance;

Future<void> initCartModule() async {
  if (!sl.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => prefs);
  }

  sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetCartUseCase(sl()));
  sl.registerLazySingleton(() => AddItemToCartUseCase(sl()));
  sl.registerLazySingleton(() => RemoveItemFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));

  sl.registerLazySingleton(() => CartBloc(
    getCartUseCase: sl(),
    addItemToCartUseCase: sl(),
    removeItemFromCartUseCase: sl(),
    clearCartUseCase: sl(),
  ));
}