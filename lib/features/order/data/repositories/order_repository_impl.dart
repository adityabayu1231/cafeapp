import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_list_result.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, OrderListResult>> getOrders({int page = 1}) async {
    try {
      final data = await remoteDataSource.getOrders(page: page);
      final items = (data['items'] as List)
          .map((e) => OrderEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>;
      return Right(OrderListResult(
        items: items,
        currentPage: pagination['current_page'] as int,
        lastPage: pagination['last_page'] as int,
        total: pagination['total'] as int,
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderDetail(int orderId) async {
    try {
      final data = await remoteDataSource.getOrderDetail(orderId);
      return Right(OrderEntity.fromJson(data));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
    } catch (e) {
      return const Left(ServerFailure('Terjadi kesalahan tidak terduga.'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(int orderId) async {
    try {
      final data = await remoteDataSource.cancelOrder(orderId);
      return Right(OrderEntity.fromJson(data));
    } on DioException catch (e) {
      return Left(ServerFailure(_extractMessage(e)));
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