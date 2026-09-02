import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;
  CheckoutRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required int cafeId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      final data = await remoteDataSource.createOrder(cafeId: cafeId, items: items, notes: notes);
      return Right(OrderEntity.fromJson(data));
    } on DioException catch (e) {
      final message = _extractMessage(e);
      if (message.toLowerCase().contains('insufficient')) {
        return Left(InsufficientBalanceFailure(message));
      }
      return Left(ServerFailure(message));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return 'Tidak dapat terhubung ke server.';
  }
}