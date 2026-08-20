import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';
import 'package:cafeapp/features/auth/domain/entities/user_entity.dart';
import 'package:cafeapp/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockSecureStorage mockSecureStorage;

  const email = 'budi@example.com';
  const password = 'password123';
  const code = '123456';
  const user = UserEntity(id: 1, name: 'Budi', email: email);

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockSecureStorage = MockSecureStorage();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      verifyOtpUseCase: mockVerifyOtpUseCase,
      checkAuthStatusUseCase: mockCheckAuthStatusUseCase,
      logoutUseCase: mockLogoutUseCase,
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
      expect: () => [const AuthLoading(), const AuthOtpRequired(email: email)],
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
      expect: () => [const AuthLoading(), const AuthFailure(message: 'Email atau password salah.')],
    );
  });

  group('OtpSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] and saves token when otp correct',
      build: () {
        when(() => mockVerifyOtpUseCase(email: email, code: code))
            .thenAnswer((_) async => const Right('sample-token'));
        when(() => mockSecureStorage.saveToken('sample-token')).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const OtpSubmitted(email: email, code: code)),
      expect: () => [const AuthLoading(), const AuthAuthenticated(token: 'sample-token')],
      verify: (_) {
        verify(() => mockSecureStorage.saveToken('sample-token')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when otp is expired',
      build: () {
        when(() => mockVerifyOtpUseCase(email: email, code: code))
            .thenAnswer((_) async => const Left(ServerFailure('OTP expired')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const OtpSubmitted(email: email, code: code)),
      expect: () => [const AuthLoading(), const AuthFailure(message: 'OTP expired')],
    );
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no token stored',
      build: () {
        when(() => mockSecureStorage.getToken()).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when token is valid',
      build: () {
        when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'stored-token');
        when(() => mockCheckAuthStatusUseCase()).thenAnswer((_) async => const Right(user));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(token: 'stored-token')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] and clears token when invalid',
      build: () {
        when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'expired-token');
        when(() => mockCheckAuthStatusUseCase())
            .thenAnswer((_) async => const Left(AuthenticationFailure('Unauthenticated.')));
        when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      verify: (_) {
        verify(() => mockSecureStorage.deleteToken()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'keeps AuthAuthenticated (does not force logout) on network/server error',
      build: () {
        when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'stored-token');
        when(() => mockCheckAuthStatusUseCase())
            .thenAnswer((_) async => const Left(ServerFailure('Tidak dapat terhubung ke server.')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthAuthenticated(token: 'stored-token')],
      verify: (_) {
        verifyNever(() => mockSecureStorage.deleteToken());
      },
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      build: () {
        when(() => mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });
}