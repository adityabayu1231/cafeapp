import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddItemToCartUseCase {
  final CartRepository repository;
  AddItemToCartUseCase(this.repository);

  /// Jika [newCafeId] beda dari cafe cart saat ini, cart lama dikosongkan
  /// dulu (auto-switch cafe). Item dengan mergeKey sama akan digabung.
  Future<Either<Failure, ({List<CartItemEntity> items, int? cafeId, String? cafeName})>> call({
    required List<CartItemEntity> currentItems,
    required int? currentCafeId,
    required int newCafeId,
    required String newCafeName,
    required CartItemEntity newItem,
  }) async {
    List<CartItemEntity> baseItems =
    (currentCafeId != null && currentCafeId != newCafeId) ? [] : List.of(currentItems);

    final existingIndex = baseItems.indexWhere((i) => i.mergeKey == newItem.mergeKey);
    if (existingIndex >= 0) {
      baseItems[existingIndex] = baseItems[existingIndex]
          .copyWith(quantity: baseItems[existingIndex].quantity + newItem.quantity);
    } else {
      baseItems.add(newItem);
    }

    final saveResult = await repository.saveCart(
      items: baseItems,
      cafeId: newCafeId,
      cafeName: newCafeName,
    );

    return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right((items: baseItems, cafeId: newCafeId, cafeName: newCafeName)),
    );
  }
}