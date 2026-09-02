import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/checkout_repository.dart';

class CreateOrderUseCase {
  final CheckoutRepository repository;
  CreateOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required int cafeId,
    required List<CartItemEntity> cartItems,
    String? notes,
  }) {
    final payload = cartItems
        .map((item) => {
      'product_id': item.productId,
      'quantity': item.quantity,
      'option_ids': item.selectedOptions.map((o) => o.optionId).toList(),
    })
        .toList();

    return repository.createOrder(cafeId: cafeId, items: payload, notes: notes);
  }
}