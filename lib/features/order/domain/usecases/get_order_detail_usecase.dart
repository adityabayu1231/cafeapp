import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderDetailUseCase {
  final OrderRepository repository;
  GetOrderDetailUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call(int orderId) {
    return repository.getOrderDetail(orderId);
  }
}