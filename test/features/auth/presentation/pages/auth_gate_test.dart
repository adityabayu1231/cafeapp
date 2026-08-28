import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/auth_state.dart';
import 'package:cafeapp/features/auth/presentation/pages/login_page.dart';
import 'package:cafeapp/features/auth/presentation/pages/home_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUp(() {
    authBloc = MockAuthBloc();
  });

  Widget buildTestable(Widget child) {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: child,
      ),
    );
  }

  // Widget minimal yang meniru struktur AuthGate (pakai bloc yang sama
  // seperti LoginPage), supaya kita bisa uji buildWhen tanpa perlu
  // menembak GetIt/sl<AuthBloc>() asli.
  Widget testGate() {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        if (current is AuthOtpRequired || current is AuthFailure) {
          return false;
        }
        if (current is AuthLoading && previous is! AuthInitial) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomePage();
        }
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return const LoginPage();
      },
    );
  }

  group('AuthGate buildWhen behavior', () {
    testWidgets(
      'tetap menampilkan LoginPage (tidak rebuild ke Login kosong baru) '
          'saat state berubah AuthUnauthenticated -> AuthLoading -> AuthOtpRequired',
          (tester) async {
        whenListen(
          authBloc,
          Stream.fromIterable([
            const AuthLoading(),
            const AuthOtpRequired(email: 'test@example.com'),
          ]),
          initialState: const AuthUnauthenticated(),
        );

        await tester.pumpWidget(buildTestable(testGate()));
        await tester.pump();

        // Widget LoginPage TIDAK boleh di-rebuild ulang (masih widget yang sama)
        // meskipun AuthBloc sempat emit AuthLoading dan AuthOtpRequired.
        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'menampilkan loading spinner saat AuthInitial -> AuthLoading (cek status awal)',
          (tester) async {
        whenListen(
          authBloc,
          Stream.fromIterable([const AuthLoading()]),
          initialState: const AuthInitial(),
        );

        await tester.pumpWidget(buildTestable(testGate()));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'menampilkan HomePage saat AuthAuthenticated',
          (tester) async {
        whenListen(
          authBloc,
          Stream.fromIterable([const AuthAuthenticated(token: 'dummy-token')]),
          initialState: const AuthUnauthenticated(),
        );

        await tester.pumpWidget(buildTestable(testGate()));
        await tester.pump();

        expect(find.byType(HomePage), findsOneWidget);
      },
    );
  });
}