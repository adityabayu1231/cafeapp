import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  @override
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  }) async {
    try {
      await remoteDataSource.login(email: email, password: password);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final token = await remoteDataSource.verifyOtp(email: email, code: code);
      return Right(token);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final data = await remoteDataSource.getCurrentUser();
      return Right(UserEntity(
        id: data['id'] as int,
        name: data['name'] as String,
        email: data['email'] as String,
      ));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return Left(AuthenticationFailure(_extractMessage(e)));
      }
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Tidak dapat terhubung ke server.';
  }
}