import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.secureStorage,
  }) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (_) => emit(AuthOtpRequired(email: event.email)),
    );
  }

  Future<void> _onOtpSubmitted(
      OtpSubmitted event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());

    final result = await verifyOtpUseCase(
      email: event.email,
      code: event.code,
    );

    await result.fold(
          (failure) async => emit(AuthFailure(message: failure.message)),
          (token) async {
        await secureStorage.saveToken(token);
        emit(AuthAuthenticated(token: token));
      },
    );
  }
}