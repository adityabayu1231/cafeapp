import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });
  Future<Either<Failure, String>> verifyOtp({
    required String email,
    required String code,
  });
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> logout();
}