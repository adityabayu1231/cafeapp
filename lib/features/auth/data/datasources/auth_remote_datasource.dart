import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> login({required String email, required String password});
  Future<String> verifyOtp({required String email, required String code});
  Future<Map<String, dynamic>> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    await dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  @override
  Future<void> login({required String email, required String password}) async {
    await dio.post('/login', data: {'email': email, 'password': password});
  }

  @override
  Future<String> verifyOtp({required String email, required String code}) async {
    final response = await dio.post('/verify-otp', data: {'email': email, 'code': code});
    return response.data['data']['token'] as String;
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await dio.get('/me');
    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    await dio.post('/logout');
  }
}