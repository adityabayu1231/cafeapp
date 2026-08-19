import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/pages/login_page.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockSecureStorage = MockSecureStorage();
  });

  Widget buildTestable() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(
          loginUseCase: mockLoginUseCase,
          verifyOtpUseCase: mockVerifyOtpUseCase,
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
}