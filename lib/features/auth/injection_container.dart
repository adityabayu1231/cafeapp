import 'package:get_it/get_it.dart';
import 'presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initAuthModule() async {
  // Bloc
  sl.registerFactory(() => AuthBloc());

  // Use cases, repository, datasource akan didaftarkan di F-2 dan F-3
}