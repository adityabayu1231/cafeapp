import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/register_usecase.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterBloc({required this.registerUseCase}) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(const RegisterLoading());
    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );
    result.fold(
          (failure) => emit(RegisterFailure(message: failure.message)),
          (_) => emit(const RegisterSuccess()),
    );
  }
}