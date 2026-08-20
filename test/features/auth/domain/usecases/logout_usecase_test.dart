import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';
import 'package:cafeapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:cafeapp/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockSecureStorage = MockSecureStorage();
    useCase = LogoutUseCase(mockRepository, mockSecureStorage);
  });

  test('deletes local token when API logout succeeds', () async {
    when(() => mockRepository.logout()).thenAnswer((_) async => const Right(null));
    when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async {});

    final result = await useCase();

    expect(result, const Right(null));
    verify(() => mockSecureStorage.deleteToken()).called(1);
  });

  test('still deletes local token when API logout fails', () async {
    when(() => mockRepository.logout())
        .thenAnswer((_) async => const Left(ServerFailure('Network error')));
    when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async {});

    final result = await useCase();

    expect(result, const Left(ServerFailure('Network error')));
    verify(() => mockSecureStorage.deleteToken()).called(1);
  });
}