import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_list_result.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);

  Future<Either<Failure, OrderListResult>> call({int page = 1}) {
    return repository.getOrders(page: page);
  }
}