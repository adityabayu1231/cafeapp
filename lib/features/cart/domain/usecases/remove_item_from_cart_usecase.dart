import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class RemoveItemFromCartUseCase {
  final CartRepository repository;
  RemoveItemFromCartUseCase(this.repository);

  Future<Either<Failure, ({List<CartItemEntity> items, int? cafeId, String? cafeName})>> call({
    required List<CartItemEntity> currentItems,
    required int? cafeId,
    required String? cafeName,
    required String mergeKey,
  }) async {
    final updated = currentItems.where((i) => i.mergeKey != mergeKey).toList();
    final resolvedCafeId = updated.isEmpty ? null : cafeId;
    final resolvedCafeName = updated.isEmpty ? null : cafeName;

    final saveResult = await repository.saveCart(
      items: updated,
      cafeId: resolvedCafeId,
      cafeName: resolvedCafeName,
    );

    return saveResult.fold(
          (failure) => Left(failure),
          (_) => Right((items: updated, cafeId: resolvedCafeId, cafeName: resolvedCafeName)),
    );
  }
}