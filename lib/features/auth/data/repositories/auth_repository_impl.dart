import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.login(email: email, password: password);
      return const Right(null);
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? (e.response?.data['message'] ?? 'Login gagal.')
          : 'Tidak dapat terhubung ke server.';
      return Left(ServerFailure(message.toString()));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }
}