import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../entities/order_list_result.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderListResult>> getOrders({int page = 1});
  Future<Either<Failure, OrderEntity>> getOrderDetail(int orderId);
  Future<Either<Failure, OrderEntity>> cancelOrder(int orderId);
}