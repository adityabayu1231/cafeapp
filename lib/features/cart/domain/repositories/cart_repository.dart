import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, ({List<CartItemEntity> items, int? cafeId, String? cafeName})>> loadCart();

  Future<Either<Failure, void>> saveCart({
    required List<CartItemEntity> items,
    required int? cafeId,
    required String? cafeName,
  });
}