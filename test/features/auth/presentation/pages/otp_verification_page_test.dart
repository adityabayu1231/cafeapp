import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';
import 'package:cafeapp/features/auth/domain/usecases/login_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:cafeapp/features/auth/domain/usecases/logout_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/pages/otp_verification_page.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockSecureStorage extends Mock implements SecureStorage {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockVerifyOtpUseCase mockVerifyOtpUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockSecureStorage mockSecureStorage;

  const testEmail = 'budi@example.com';
  const testPassword = 'rahasia123';

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockVerifyOtpUseCase = MockVerifyOtpUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockSecureStorage = MockSecureStorage();

    when(() => mockSecureStorage.saveToken(any())).thenAnswer((_) async {});
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
        child: const OtpVerificationPage(email: testEmail, password: testPassword),
      ),
    );
  }

  testWidgets('menampilkan email dan field kode OTP', (tester) async {
    await tester.pumpWidget(buildTestable());

    expect(find.textContaining(testEmail), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Verifikasi'), findsOneWidget);
  });

  testWidgets('menampilkan countdown awal 05:00 dan tombol resend disabled', (tester) async {
    await tester.pumpWidget(buildTestable());

    expect(find.textContaining('05:00'), findsOneWidget);

    final resendButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Kirim ulang dalam 01:00'));
    expect(resendButton.onPressed, isNull);
  });

  testWidgets('countdown berkurang seiring waktu', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.pump(const Duration(seconds: 10));

    expect(find.textContaining('04:50'), findsOneWidget);
  });

  testWidgets('tombol resend aktif setelah 60 detik', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.pump(const Duration(seconds: 60));

    final resendButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Kirim Ulang Kode'));
    expect(resendButton.onPressed, isNotNull);
  });

  testWidgets('menekan resend mendispatch LoginSubmitted dan mereset countdown', (tester) async {
    when(() => mockLoginUseCase(email: testEmail, password: testPassword))
        .thenAnswer((_) async => const Right(null));

    await tester.pumpWidget(buildTestable());
    await tester.pump(const Duration(seconds: 60));

    await tester.tap(find.widgetWithText(TextButton, 'Kirim Ulang Kode'));
    await tester.pump();

    verify(() => mockLoginUseCase(email: testEmail, password: testPassword)).called(1);
    expect(find.textContaining('05:00'), findsOneWidget);
    expect(find.text('Kode OTP baru telah dikirim.'), findsOneWidget);
  });

  testWidgets('field dan tombol verifikasi disabled setelah 5 menit (kadaluarsa)', (tester) async {
    await tester.pumpWidget(buildTestable());

    await tester.pump(const Duration(minutes: 5, seconds: 1));

    expect(find.text('Kode sudah tidak berlaku, silakan kirim ulang.'), findsOneWidget);

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.enabled, isFalse);
  });

  testWidgets('auto-submit terpicu otomatis saat 6 digit terisi (ketik manual)', (tester) async {
    when(() => mockVerifyOtpUseCase(email: testEmail, code: '123456'))
        .thenAnswer((_) async => const Right('dummy-token'));

    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.pump();

    verify(() => mockVerifyOtpUseCase(email: testEmail, code: '123456')).called(1);
  });

  testWidgets('auto-submit terpicu otomatis saat 6 digit terisi via paste', (tester) async {
    when(() => mockVerifyOtpUseCase(email: testEmail, code: '654321'))
        .thenAnswer((_) async => const Right('dummy-token'));

    await tester.pumpWidget(buildTestable());

    // Simulasikan paste: set seluruh teks sekaligus, bukan ketik satu-satu.
    await tester.enterText(find.byType(TextFormField), '654321');
    await tester.pump();

    verify(() => mockVerifyOtpUseCase(email: testEmail, code: '654321')).called(1);
  });

  testWidgets('menampilkan snackbar error saat OTP salah (tanpa perlu tap manual, auto-submit)', (tester) async {
    when(() => mockVerifyOtpUseCase(email: testEmail, code: '999999'))
        .thenAnswer((_) async => const Left(ServerFailure('Kode OTP salah.')));

    await tester.pumpWidget(buildTestable());

    await tester.enterText(find.byType(TextFormField), '999999');
    await tester.pump();
    await tester.pump();

    expect(find.text('Kode OTP salah.'), findsOneWidget);
  });
}