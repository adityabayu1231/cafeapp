import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockSecureStorage mockSecureStorage;

  const email = 'budi@example.com';
  const password = 'password123';
  const code = '123456';

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockSecureStorage = MockSecureStorage();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      verifyOtpUseCase: mockVerifyOtpUseCase,
      secureStorage: mockSecureStorage,
    );
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

  group('OtpSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] and saves token when otp correct',
      build: () {
        when(() => mockVerifyOtpUseCase(email: email, code: code))
            .thenAnswer((_) async => const Right('sample-token'));
        when(() => mockSecureStorage.saveToken('sample-token'))
            .thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const OtpSubmitted(email: email, code: code)),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(token: 'sample-token'),
      ],
      verify: (_) {
        verify(() => mockSecureStorage.saveToken('sample-token')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when otp is expired',
      build: () {
        when(() => mockVerifyOtpUseCase(email: email, code: code)).thenAnswer(
              (_) async => const Left(ServerFailure('OTP expired')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(const OtpSubmitted(email: email, code: code)),
      expect: () => [
        const AuthLoading(),
        const AuthFailure(message: 'OTP expired'),
      ],
    );
  });
}