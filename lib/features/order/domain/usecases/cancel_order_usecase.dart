import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository repository;
  CancelOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(int orderId) {
    return repository.cancelOrder(orderId);
  }
}