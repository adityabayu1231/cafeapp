import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:cafeapp/features/auth/domain/usecases/verify_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyOtpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepository);
  });

  const email = 'budi@example.com';
  const code = '123456';

  test('returns Right(token) when otp is correct', () async {
    when(() => mockRepository.verifyOtp(email: email, code: code))
        .thenAnswer((_) async => const Right('sample-token'));

    final result = await useCase(email: email, code: code);

    expect(result, const Right('sample-token'));
  });

  test('returns Left(Failure) when otp is expired', () async {
    when(() => mockRepository.verifyOtp(email: email, code: code))
        .thenAnswer((_) async => const Left(ServerFailure('OTP expired')));

    final result = await useCase(email: email, code: code);

    expect(result, const Left(ServerFailure('OTP expired')));
  });
}