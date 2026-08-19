import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const email = 'budi@example.com';
  const password = 'password123';

  test('returns Right(null) when repository login succeeds', () async {
    when(() => mockRepository.login(email: email, password: password))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(email: email, password: password);

    expect(result, const Right(null));
    verify(() => mockRepository.login(email: email, password: password)).called(1);
  });

  test('returns Left(Failure) when repository login fails', () async {
    when(() => mockRepository.login(email: email, password: password))
        .thenAnswer((_) async => const Left(ServerFailure('Email atau password salah.')));

    final result = await useCase(email: email, password: password);

    expect(result, const Left(ServerFailure('Email atau password salah.')));
  });
}