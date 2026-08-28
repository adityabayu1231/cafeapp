import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (previous, current) {
          // AuthGate hanya boleh rebuild untuk keputusan routing awal
          // (authenticated / unauthenticated / loading saat cek status awal).
          // State yang terjadi SELAMA alur Login/OTP berlangsung
          // (AuthLoading dari submit login, AuthOtpRequired, AuthFailure)
          // harus diabaikan di sini supaya tidak menimpa LoginPage/
          // OtpVerificationPage yang sedang menangani alurnya sendiri.
          if (current is AuthOtpRequired || current is AuthFailure) {
            return false;
          }
          if (current is AuthLoading && previous is! AuthInitial) {
            // AuthLoading yang muncul SETELAH state awal (mis. dari submit
            // login) bukan loading pengecekan status awal — abaikan.
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
      ),
    );
  }
}