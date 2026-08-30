import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_state.dart';
import 'package:cafeapp/features/auth/presentation/pages/login_page.dart';
import 'package:bloc_test/bloc_test.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockSecureStorage extends Mock implements SecureStorage {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockRegisterBloc extends MockBloc<RegisterEvent, RegisterState> implements RegisterBloc {}

void main() {
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockLoginUseCase mockLoginUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockSecureStorage = MockSecureStorage();

    final registerBloc = MockRegisterBloc();
    when(() => registerBloc.state).thenReturn(const RegisterInitial());
    if (GetIt.instance.isRegistered<RegisterBloc>()) {
      GetIt.instance.unregister<RegisterBloc>();
    }
    GetIt.instance.registerFactory<RegisterBloc>(() => registerBloc);
  });

  tearDown(() {
    if (GetIt.instance.isRegistered<RegisterBloc>()) {
      GetIt.instance.unregister<RegisterBloc>();
    }
  });

  Widget buildTestable() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          loginUseCase: mockLoginUseCase,
          verifyOtpUseCase: mockVerifyOtpUseCase,
          checkAuthStatusUseCase: mockCheckAuthStatusUseCase,
          logoutUseCase: mockLogoutUseCase,
          secureStorage: mockSecureStorage,
        ),
        child: const LoginView(),
      ),
    );
  }

  testWidgets('shows validation error when fields are empty', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('shows snackbar with error message on AuthFailure', (tester) async {
    when(() => mockLoginUseCase(email: 'budi@example.com', password: 'wrongpass'))
        .thenAnswer((_) async => const Left(ServerFailure('Email atau password salah.')));

    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField).first, 'budi@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump(); // trigger AuthLoading
    await tester.pump(); // trigger AuthFailure

    expect(find.text('Email atau password salah.'), findsOneWidget);
  });

  testWidgets('menampilkan field email, field password, dan tombol submit', (tester) async {
    await tester.pumpWidget(buildTestable());

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('menampilkan link "Daftar" dan menavigasi ke RegisterPage saat ditekan', (tester) async {
    await tester.pumpWidget(buildTestable());

    expect(find.textContaining('Daftar'), findsOneWidget);

    await tester.tap(find.textContaining('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Akun Baru'), findsOneWidget);
  });
}