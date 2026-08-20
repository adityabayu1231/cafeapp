import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/error/failures.dart';
import 'package:cafeapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cafeapp/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('getCurrentUser', () {
    test('returns Left(AuthenticationFailure) on 401', () async {
      final requestOptions = RequestOptions(path: '/me');
      when(() => mockDataSource.getCurrentUser()).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 401,
            data: {'message': 'Unauthenticated.'},
          ),
        ),
      );

      final result = await repository.getCurrentUser();

      expect(result, isA<Left>());
      result.fold(
            (failure) => expect(failure, isA<AuthenticationFailure>()),
            (_) => fail('should not return Right'),
      );
    });

    test('returns Left(ServerFailure), not AuthenticationFailure, on 500', () async {
      final requestOptions = RequestOptions(path: '/me');
      when(() => mockDataSource.getCurrentUser()).thenThrow(
        DioException(
          requestOptions: requestOptions,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 500,
            data: {'message': 'Server error'},
          ),
        ),
      );

      final result = await repository.getCurrentUser();

      result.fold(
            (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure, isNot(isA<AuthenticationFailure>()));
        },
            (_) => fail('should not return Right'),
      );
    });

    test('returns Left(ServerFailure) on network error (no response)', () async {
      final requestOptions = RequestOptions(path: '/me');
      when(() => mockDataSource.getCurrentUser()).thenThrow(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await repository.getCurrentUser();

      result.fold(
            (failure) => expect(failure, isA<ServerFailure>()),
            (_) => fail('should not return Right'),
      );
    });
  });
}