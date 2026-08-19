import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String email,
    required String code,
  }) {
    return repository.verifyOtp(email: email, code: code);
  }
}