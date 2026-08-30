import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/auth/domain/usecases/register_usecase.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_bloc.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_event.dart';
import 'package:cafeapp/features/auth/presentation/bloc/register_state.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
  });

  const event = RegisterSubmitted(
    name: 'Budi',
    email: 'budi@example.com',
    password: 'password123',
    passwordConfirmation: 'password123',
  );

  blocTest<RegisterBloc, RegisterState>(
    'emit [RegisterLoading, RegisterSuccess] saat registrasi berhasil',
    build: () {
      when(() => mockRegisterUseCase(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
      )).thenAnswer((_) async => const Right(null));
      return RegisterBloc(registerUseCase: mockRegisterUseCase);
    },
    act: (bloc) => bloc.add(event),
    expect: () => [const RegisterLoading(), const RegisterSuccess()],
  );

  blocTest<RegisterBloc, RegisterState>(
    'emit [RegisterLoading, RegisterFailure] saat registrasi gagal (email sudah terdaftar)',
    build: () {
      when(() => mockRegisterUseCase(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'password123',
        passwordConfirmation: 'password123',
      )).thenAnswer((_) async => const Left(ServerFailure('Email sudah terdaftar.')));
      return RegisterBloc(registerUseCase: mockRegisterUseCase);
    },
    act: (bloc) => bloc.add(event),
    expect: () => [const RegisterLoading(), const RegisterFailure(message: 'Email sudah terdaftar.')],
  );
}