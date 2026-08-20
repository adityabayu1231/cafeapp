import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/auth/domain/entities/user_entity.dart';
import 'package:cafeapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:cafeapp/features/auth/domain/usecases/check_auth_status_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CheckAuthStatusUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckAuthStatusUseCase(mockRepository);
  });

  const user = UserEntity(id: 1, name: 'Budi', email: 'budi@example.com');

  test('returns Right(UserEntity) when token is valid', () async {
    when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => const Right(user));

    final result = await useCase();

    expect(result, const Right(user));
  });

  test('returns Left(Failure) when token invalid/expired', () async {
    when(() => mockRepository.getCurrentUser())
        .thenAnswer((_) async => const Left(ServerFailure('Unauthenticated.')));

    final result = await useCase();

    expect(result, const Left(ServerFailure('Unauthenticated.')));
  });
}