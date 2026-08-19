import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;

  const email = 'budi@example.com';
  const password = 'password123';

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    authBloc = AuthBloc(loginUseCase: mockLoginUseCase);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitial', () {
    expect(authBloc.state, const AuthInitial());
  });

  group('LoginSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthOtpRequired] when login succeeds',
      build: () {
        when(() => mockLoginUseCase(email: email, password: password))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(email: email, password: password)),
      expect: () => [
        const AuthLoading(),
        const AuthOtpRequired(email: email),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(() => mockLoginUseCase(email: email, password: password)).thenAnswer(
              (_) async => const Left(ServerFailure('Email atau password salah.')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginSubmitted(email: email, password: password)),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'Email atau password salah.'),
      ],
    );
  });
}