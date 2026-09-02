import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../order/domain/entities/order_entity.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required int cafeId,
    required List<Map<String, dynamic>> items,
    String? notes,
  });
}