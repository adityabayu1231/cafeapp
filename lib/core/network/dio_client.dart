import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({String baseUrl = 'http://auth-api.test/api'})
      : dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ));
}