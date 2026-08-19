import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cafeapp/core/network/auth_interceptor.dart';
import 'package:cafeapp/core/storage/secure_storage.dart';

class MockSecureStorage extends Mock implements SecureStorage {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late MockSecureStorage mockSecureStorage;
  late AuthInterceptor interceptor;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
  });

  group('onRequest', () {
    test('attaches Authorization header when token exists', () async {
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'my-token');
      interceptor = AuthInterceptor(secureStorage: mockSecureStorage);

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(options)).thenReturn(null);

      interceptor.onRequest(options, handler);
      await Future.delayed(Duration.zero);

      expect(options.headers['Authorization'], 'Bearer my-token');
      verify(() => handler.next(options)).called(1);
    });

    test('does not attach header when token is null', () async {
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => null);
      interceptor = AuthInterceptor(secureStorage: mockSecureStorage);

      final options = RequestOptions(path: '/test');
      final handler = MockRequestInterceptorHandler();
      when(() => handler.next(options)).thenReturn(null);

      interceptor.onRequest(options, handler);
      await Future.delayed(Duration.zero);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('onError', () {
    test('deletes token and calls onUnauthenticated on 401', () async {
      when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async {});
      var callbackCalled = false;

      interceptor = AuthInterceptor(
        secureStorage: mockSecureStorage,
        onUnauthenticated: () => callbackCalled = true,
      );

      final requestOptions = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 401),
      );
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(err)).thenReturn(null);

      interceptor.onError(err, handler);
      await Future.delayed(Duration.zero);

      expect(callbackCalled, isTrue);
      verify(() => mockSecureStorage.deleteToken()).called(1);
    });

    test('does not delete token on non-401 error', () async {
      interceptor = AuthInterceptor(secureStorage: mockSecureStorage);

      final requestOptions = RequestOptions(path: '/test');
      final err = DioException(
        requestOptions: requestOptions,
        response: Response(requestOptions: requestOptions, statusCode: 500),
      );
      final handler = MockErrorInterceptorHandler();
      when(() => handler.next(err)).thenReturn(null);

      interceptor.onError(err, handler);
      await Future.delayed(Duration.zero);

      verifyNever(() => mockSecureStorage.deleteToken());
    });
  });
}