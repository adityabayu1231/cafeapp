import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.loginUseCase,
    required this.verifyOtpUseCase,
    required this.checkAuthStatusUseCase,
    required this.logoutUseCase,
    required this.secureStorage,
  }) : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await loginUseCase(email: event.email, password: event.password);
    result.fold(
          (failure) => emit(AuthFailure(message: failure.message)),
          (_) => emit(AuthOtpRequired(email: event.email)),
    );
  }

  Future<void> _onOtpSubmitted(OtpSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await verifyOtpUseCase(email: event.email, code: event.code);
    await result.fold(
          (failure) async => emit(AuthFailure(message: failure.message)),
          (token) async {
        await secureStorage.saveToken(token);
        emit(AuthAuthenticated(token: token));
      },
    );
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final token = await secureStorage.getToken();
    if (token == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final result = await checkAuthStatusUseCase();
    await result.fold(
          (failure) async {
        await secureStorage.deleteToken();
        emit(const AuthUnauthenticated());
      },
          (_) async => emit(AuthAuthenticated(token: token)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await logoutUseCase();
    emit(const AuthUnauthenticated());
  }
}