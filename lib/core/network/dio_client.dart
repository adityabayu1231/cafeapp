import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage.dart';

class DioClient {
  final Dio dio;

  DioClient({
    String baseUrl = 'http://auth-api.test/api',
    required SecureStorage secureStorage,
    void Function()? onUnauthenticated,
  }) : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  )) {
    dio.interceptors.add(AuthInterceptor(
      secureStorage: secureStorage,
      onUnauthenticated: onUnauthenticated,
    ));
  }
}