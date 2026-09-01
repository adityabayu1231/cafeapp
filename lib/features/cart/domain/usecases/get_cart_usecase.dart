import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;
  GetCartUseCase(this.repository);

  Future<Either<Failure, ({List<CartItemEntity> items, int? cafeId, String? cafeName})>> call() {
    return repository.loadCart();
  }
}