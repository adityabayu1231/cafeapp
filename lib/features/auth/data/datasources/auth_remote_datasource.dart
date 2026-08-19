import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<void> login({required String email, required String password}) async {
    await dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    // Response body diabaikan di sini — backend cuma balas
    // { success, message: "OTP telah dikirim..." }, tidak ada data terpakai.
    // Kalau request gagal (401/422/dst), Dio otomatis throw DioException,
    // ditangkap di repository impl.
  }
}