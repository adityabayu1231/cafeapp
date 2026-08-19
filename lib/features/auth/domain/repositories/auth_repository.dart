import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, String>> verifyOtp({
    required String email,
    required String code,
  });
}